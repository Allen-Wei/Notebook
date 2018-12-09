# Vue 父子组件通信

在Vue中，子组件向父组件传递数据很简单, 子组件向外部暴露一个事件就可以了. 但是父组件向子组件通信的时候就有点麻烦了, 可以结组官网提供的 `$refs` 属性来获取子组件的引用, 然后调用子组件上的方法来和子组件通信, 但是这种方式封装性不太好, 获取子组件的引用就等于可以破坏子组件的数据了. 下面介绍一种通过 Pub/Sub 时间分发的方式来通信. 
通过对 Pub/Sub  模式进行简单的封装可以让父组件更加优雅的调用子组件的方法和数据, 而子组件未暴露出来的东西父组件是无法访问的.

### `global-singleton.js` 
这个文件主要用于进行全局变量缓存, 快速实现单例模式:

```javascript
let _global = window;
const GLOBAL_KEY_NAME = "_GlobalSingleton";

if (_global[GLOBAL_KEY_NAME] === undefined || _global[GLOBAL_KEY_NAME] === null) {
    _global[GLOBAL_KEY_NAME] = {};
}

export function get(key) {
    if (key === undefined || key === null) {
        return _global[GLOBAL_KEY_NAME];
    }
    return _global[GLOBAL_KEY_NAME][key];
};

export function set(key, value) {
    _global[GLOBAL_KEY_NAME][key] = value;
    return value;
}


```



### `event-hub.js`

依赖 jQuery 类库, 主要借助 jQuery 快速实现 Sub/Pub 模式.

```javascript
import $ from "jquery";
import {get, set} from "./global-singleton";

const PLUGIN_NAME = "event-hub";

/**
 * 事件分发中心
 * @param key
 * @constructor
 */
export function Hub(key) {
    if (typeof(key) !== "string") {
        throw `${PLUGIN_NAME}: 参数key必须是字符串`;
    }

    /**
     * 下面借助 get/set 方法为了对于相同的 key 获取同一个事件分发中心
     *
     */
    key = "hub_" + key;
    var $hub = get(key);
    if ($hub === undefined) {
        $hub = set(key, $({}));
    }

    this.__hub_name = key;

    this.listen = function (name, callback, context, isOnce) {
        if (typeof(name) !== "string") {
            throw `${PLUGIN_NAME}: 参数 name 必须是字符串`;
        }
        if (callback !== undefined && typeof(callback) !== "function") {
            throw `${PLUGIN_NAME}: 参数 callback 必须是函数`;
        }
        var _myself = this;

        var $deferred = $.Deferred();
        var fn = function () {
            var args = Array.prototype.slice.call(arguments, 1, arguments.length);
            $deferred.resolve.apply(context || _myself, args);
            if (callback) {
                callback.apply(context || _myself, args);
            }
        };
        isOnce ? $hub.one(name, fn) : $hub.on(name, fn);
        return $deferred.promise();
    };

    /**
     * 监听事件
     * @param name 事件名
     * @param callback 回调函数
     */
    this.on = function (name, callback, context) {
        return this.listen(name, callback, context, false);
    };

    this.one = function (name, callback, context) {
        return this.listen(name, callback, context, true);
    };

    /**
     * 触发事件
     * @param name
     * @return {Hub}
     */
    this.trigger = function (name) {
        var args = Array.prototype.slice.call(arguments, 1, arguments.length);
        $hub.trigger(name, args);
        return this;
    };
    /**
     * 触发事件
     * @type {(function(*=): Hub)|*}
     */
    this.emit = this.trigger;

    /**
     * 取消监听
     * @param name
     * @param fn
     * @return {Hub}
     */
    this.off = function (name, fn) {
        $hub.off(name, fn);
        return this;
    };

    this.__exposed = {};

    /**
     * 暴露函数
     * @param name
     * @param context
     * @param force
     * @return {Hub}
     */
    this.expose = function (name, context, force) {
        if (typeof (name) !== "string") {
            throw `${PLUGIN_NAME}: 参数 name 必须是字符串`;
        }
        force == !!force;

        //添加统一前缀, 防止和Object对象属性名冲突.
        var exposeKey = "_expose_" + name;

        var expose = this.__exposed[exposeKey];

        if (expose && force === false) {
            return this;
        }
        if (expose) {
            this.off(name, expose.callback);
        }

        expose = {
            callback: function (fn) {
                fn(context);
            }
        };

        this.__exposed[exposeKey] = expose;

        this.on(name, expose.callback);

        return this;
    };

    /**
     * 调用函数
     * @param name
     * @param fn
     * @return {Hub}
     */
    this.call = function (name, fn) {
        this.trigger(name, fn);

        return this;
    };
}

/**
 * 获取 Hub 单例
 * @param key
 * @return {*}
 * @constructor
 */
export function GetHub(key) {
    var hub = get(key);
    if (hub) {
        return hub;
    } else {
        set(key, new Hub(key));
    }
    return GetHub(key);
}

```

`Hub`是个构造函数, 用于实例化一个事件中心, 也就是说对于以下代码中的 `hub1` 和 `hub2`, 他们中的 `$hub` 其实是同一个对象, 这样 `hub1` 触发的事件 `hub2` 同样可以监听接收.
```javascript
var key = "some-key";
var hub1 = new Hub(key); 
var hub2 = new Hub(key);
```


`GetHub` 用于获取事件中心单例, 也就是说 `GetHub("hello") === GetHub("hello")` 返回 `true`.


## 下面是使用示例: 

组件1: 
```javascript
import {GetHub} from "./event-hub";

export default {
	data: function(){
		return {
			firstName: "Alan",
			age: 20
		};
	},
	methods:{
		getAge: function(){
			return this.age;
		},
		expose: function(){
			//在这里执行要暴露的方法和数据
			var hub = GetHub("component1");
			//expose方法可以多次执行, 默认只有第一次调用的起作用, 可通过传递第3个参数强制更新.
			hub.expose("get-age", this.getAge);
		}
	},
	mounted: function(){
		this.expose(); 
	}
};
```

使用: 
```javascript
import Component1 from "./component1";
import {GetHub} from "./event-hub";

new Vue({
	el: "#mount",
	data: {
		hub: GetHub("component1"),
		age: null
	},
	methods: {
		getComponent1AgeValue: function(){
			this.hub.call("get-age", fn => {
				this.age = fn();
			});
		}
	},
	components: {
		Component1
	}
});
```
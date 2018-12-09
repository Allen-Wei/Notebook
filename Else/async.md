# Async
## JavaScript
### Promise
#### 简述Promise发展历程
Promise 一词最早由一个C++工程师用在Xanadu项目中, 随后Promise被用在E语言当中, 这又激发了Python开发人员的灵感, 将它实现成了Twisted框架的`Deferred`对象. 2007年, JavaScript框架Dojo借鉴Twisted新增了`dojo.Deferred`对象. 2009年, Kris Zyp提出了CommonJS中的Promises/A规范.<sup>1<sup>

Q.js是Promises/A规范比较著名的实现. jQuery在1.5版本基于Promises／A规范加入了Promise实现, 不过和Promises/A有一些细微的差别.
主要区别是Deferred和Promise之间的区别, 在Q.js中deferred有一个`promise`属性作为唯一接口监听状态变化, 使用deferred对象上的`resolve`和`reject`函数改变状态. 而在jQuery中`$.Deferred`对象既是promise也是deferred, 能监听状态变化, 也能改变状态. 不过jQuery在`$.Deferred`对象上提供了`promise()`方法可以返回一个promise.<sup>2</sup>.

```javascript
function foo() {
    var result = Q.defer();
    result.resolve(10);
    return result.promise;
}
```
```javascript
function foo() {
    var result = $.Deferred();
    result.resolve(10);
    return result; // or
    return result.promise();
}
```
另外在ES6标准中定义了原生Promise对象<sup>3</sup>.

#### 展示Promise在Ajax请求上的应用
```javascript
//Callback
$.get(url, {
    success: function() { 
        renderPage();
        startAnimation();
        ...
    },
    fail: function() {
        alertError();
        ...
    }
})

//Promise
let promise = $.get(url);
promise.fail(function(){
     alertError();
     ...
});
....//do other
renderPage(promise);
startAnimation(promise);
...
```
Promise相对于传统的回调函数方式最大的优势就是封装, 可以把一个异步任务当成一个参数进行传递. 因此我们可以很轻松从一个Promise对象派生出来一个Promise:
```javascript
//ref: http://api.jquery.com/deferred.then/
var defer = $.Deferred();
var filtered = defer.then(function(value){
    return value * 2;
});

defer.resolve(10);
filtered.then(function(value){
    console.log(value);  //value => 20
});

//ref: https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch
fetch('flowers.jpg').then(function(response) {
  return response.blob();
}).then(function(myBlob) {
  var objectURL = URL.createObjectURL(myBlob);
  myImage.src = objectURL;
});
```
也可以将多个并行的Promise合并成一个Promise, 由后者负责通知前面的任务都已经完成:
```javascript
$.when($.get("/users"), $.get("/roles"))
.then((data) => {
    let users = data[0];
    let roles =  data[1]
});

Promise.all([fetch("/users").then(data => data.json()), fetch("/roles").then(data => data.json())])
.then(data => { 
    let users = data[0];
    let roles = data[1];sa
}); 
```

#### 简述Promise和Pub/Sub的区别
* Promise一般用于一次性事件, 事件的结果有两种. 比如Ajax请求, 文件读取.
```javascript
fetch(url).then(response => {}, error => {});
readFile(path).then(data => {}, error => {});
```
* Pub/Sub 模式一般用于需要多次触发, 有多种结果. 比如HTTP服务器: 
```javascript
let server = require("http").createServer((req, res) => {
    res.end();
});
server.on("connection", socket => {
    //new connection
});
server.on("error", error => { });
server.on("close", () => { });
server.listen(3001, () => {
    console.log("listen 3001");
});
```
或者Web组件之间的通信, 比如Angular 1.X中父子控制器通过事件传播通信.
另外使用 $({}) 可以快速实现一个 Pub/Sub 模式:
```javascript
let $pubSub = $({});
$pubSub.on("message", (e, message) => {
    console.log(message); //=> Hello
});
$pubSub.trigger("message", ["Hello"]);
```

### Generator
ES6除了内置Promise函数, 也增加了生成器特性. 
利用生成器可以模仿C#代码中的async/await模式, 让异步代码编写起来更像同步代码.
#### 一个简单的生成器函数例子
```javascript
function* generator(){
    console.log(yield "hello"); 
    console.log("continue");
    console.log(yield "world");
}
let gen = generator(); 
console.log(gen.next()); 
console.log(gen.next("first")); 
console.log(gen.next("second")); 

/* output:
{ value: 'hello', done: false }
first
continue
{ value: 'world', done: false }
second
{ value: undefined, done: true } //undfined 是因为函数没有返回值
*/
```
可以利用生成器的`yield async()`让函数暂停, 再使用`next(data)`异步将结果传递出去来模拟async/await特性: 
```javascript
let fs = require("fs");
function readFile(path){
    fs.readFile(__dirname + path, (error, data) => {
        gen.next(data.toString());
    });
    return path;
}

function* generator(){
    let pkg = yield readFile("/package.json");
    let index = yield readFile("/index.html");
}
let gen = generator();
gen.next(); //=> { value: '/package.json', done: false }
```
进一步封装
```javascript
let fs = require("fs");
function runAsync(generator) {
    let it = generator(), yieldValue;

    function recurise(value) {
        yieldValue = it.next(value);
        if (yieldValue.done) { return; }

        yieldValue.value.then(response => {
            recurise(response);
        }, error => {
            it.throw(error);
        });
    }
    recurise();
}
function readFile(path) { //读取文件
    return new Promise((resolve, reject) => {
        fs.readFile(__dirname + path, (error, data) => {
            if (error) reject(error);
            else resolve(data.toString());
        });
    });
}
runAsync(function* () { //使用
    let pkg = yield readFile("/package.json");
    let index = yield readFile("/index.html");
});
```
### async/await
从ES7开始, JavaScript内置了async/await特性, 可以更方便编写异步代码.

> The async and await keywords first hit the scene way back in 2010, when it was introduced in FSharp, CSharp, and VB followed fairly quickly in 2012, with Python and TypeScript adopting them in 2015.
[Async JavaScript](https://blog.stephencleary.com/2017/06/async-javascript.html)


## CSharp
* 上下文捕获 导致异常 
* 闭包 和 JS 闭包变量捕获的区别

```csharp
/// <summary>
/// 迭代子部门
/// </summary>
/// <param name="departments">所有部门</param>
/// <param name="root">根部门</param>
/// <returns></returns>
public static IEnumerable<Department> IterateDepartments(IEnumerable<Department> departments, Department root)
{
    if (departments == null) throw new ArgumentNullException("departments");
    if (root == null) throw new ArgumentNullException("root");
    if (String.IsNullOrWhiteSpace(root.DeptID)) throw new ArgumentNullException("DeptId", "部门Id不能为空");

    foreach (Department child in departments.Where(dept => dept.ParentID == root.DeptID))
    {
        yield return child;
        foreach (var iterator in IterateDepartments(departments, child))
        {
            yield return iterator;
        }
    }
}

public IEnumerator<IEnumerator<Foo>> GetEnumerator()
{
    yield return Database[id].GetEnumerator();
}
```

RxJS


* [1](https://en.wikipedia.org/wiki/Futures_and_promises)
* [2](https://github.com/kriskowal/q/wiki/Coming-from-jQuery)
* [3](http://www.ecma-international.org/ecma-262/6.0/#sec-promise-objects)
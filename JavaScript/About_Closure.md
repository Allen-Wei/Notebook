# 关于闭包

昨天面试, 被技术主管问到一个什么是闭包的问题, 我当时的理解是函数在被返回之前记住了它所定义时的作用域的变量, 而这些变量在函数的外面是无法访问到的. 举了一个简单的类似于下面的例子:

	var outer = function(){
		var name = "Alan";
		var inner = function(){
			return name;
		};
	};

	var getName = outer();
	var name = getName();

假设这是在浏览器里执行的, 那个outer函数所在的作用域是全局作用域. 全局作用域是无法访问到`name`变量的, 但是通过闭包访问到了.

我一直认为, JS的函数有一个行为是在函数定义的时候, 函数记住了函数的作用域链上的自由变量. 正是有了这个行为, JS才有了闭包的特性(当然了还有很多因素决定了闭包, 比如匿名函数, 不过我觉得JS函数定义的行为对闭包起了最大的作用.)

技术主管问了一个问题, 是他实际项目中遇到的, 大概代码如下:

	function Outer(){
		
		this.greet = function(name){
			return "Hello " + name + ".";
		};

		this.iteral = function(){
			var names = ["Allen", "Alan"];
			$.each(names, function(index, name){
				console.log(this.greet(name));	//在这里出现问题了, 在这里是无法访问到外部的`this.greet`;
			});
		};
	}

我当时给出的解决方案是定义一个临时变量引用`this`:

	this.iteral = function(){
		var context = this;
		$.each(names, function(index, name){
			console.log(context.greet(name));
		});
	};

当时主管说我这样写还是不行(也可能我当时表述有问题, 他听错了.), 我当时也犹豫了,以为这样不行.(毕竟大牛都说不对了. 他说的这个问题, 我以前也遇到过类似的, 我记得当时jQuery那个函数允许传额外的参数来修改回调函数的`this`, 忘记具体是哪个问题, 不过后来我查到了`$.proxy`这个方法可以实现.)

后来回家搜了一下相关问题([类似于这个](http://stackoverflow.com/questions/14212414/jquery-change-callback-context)), 也自己试了一下, 证明自己是对的. 

下面是我写的几种解决这个问题的方案:

	function Outer() {
		var names = ["Alan", "Allen"];

		this.greet = function (name) {
			return "Hello " + name + ".";
		};

		this.tempRef = function () {
			var context = this;
			$.each(names, function (index, item) {
				console.info(context.greet(item));
			});
		};
		this.selfFn = function () {
			$.each(names, (function (context) {
				return function (index, item) {
					console.info(context.greet(item));
				};
			})(this));

		};
		this.proxy = function () {
			$.each(names, $.proxy(function (index, item) {
				console.info(this.greet(item));
			}, this));

		};
	}
	var instance = new Outer();
	instance.tempRef();
	instance.selfFn();
	instance.proxy();

`instance.tempRef()`, `instance.selfFn()`, `instance.proxy` 三种方式都能解决这个问题.

`tempRef`比较好理解, 就正常的闭包解决的, 其实这不是闭包的问题, 是`this`的问题, jQuery的`each`函数里, 第二个参数是回调函数, 而回调函数里的`this`, 是那个item对象, 不行你试试如下代码:
	
	$.each(["Alan", "Allen"], function(){
		console.log(this);
	});

这里会一次输出 `Alan` 和 `Allen`. 你可以看 `jQuery-2.1.4.js` 源码第 `354`, `362`, `374`, `382`行源码, 如下:
	
	for ( ; i < length; i++ ) {
		value = callback.call( obj[ i ], i, obj[ i ] );
		if ( value === false ) {
			break;
		}
	}

源码里的 `callback` 就是那个回调函数, `callback.call` 则更改了回调函数里的`this`对象. 所以XX所遇到的问题最主要的原因还是`this`的上下文变了. 除了利用闭包将外部(`Outer`)的`this`传递赋值给一个变量, 回调函数定义时捕获那个变量, 就可以间接引用到`Outer`的`this`了. 实际上, 回调函数捕获了`Outer`的`this`上下文了, 为什么回调函数里还是访问不到`this.greet`呢? 是因为`this`在回调函数里被重新指向了`obj[i]`了, 而第三个解决方案 `instance.proxy()` 就是改变回调函数的`this`, 使得回调函数的`this`重新指向`Outer`实例. PS: 第一种和第二种方式比较类似.

要是让我给闭包下一个准确的定义, 我还真说不出, 所以下面[摘录](http://www.ibm.com/developerworks/cn/linux/l-cn-closure/index.html)一下别人的别人的定义:

	什么是闭包？
	闭包并不是什么新奇的概念，它早在高级语言开始发展的年代就产生了。闭包（Closure）是词法闭包（Lexical Closure）的简称。对闭包的具体定义有很多种说法，这些说法大体可以分为两类：
	一种说法认为闭包是符合一定条件的函数，比如参考资源中这样定义闭包：闭包是在其词法上下文中引用了自由变量(注1)的函数。
	另一种说法认为闭包是由函数和与其相关的引用环境组合而成的实体。比如参考资源中就有这样的的定义：在实现深约束(注2)时，需要创建一个能显式表示引用环境的东西，并将它与相关的子程序捆绑在一起，这样捆绑起来的整体被称为闭包。
	这两种定义在某种意义上是对立的，一个认为闭包是函数，另一个认为闭包是函数和引用环境组成的整体。虽然有些咬文嚼字，但可以肯定第二种说法更确切。闭包只是在形式和表现上像函数，但实际上不是函数。函数是一些可执行的代码，这些代码在函数被定义后就确定了，不会在执行时发生变化，所以一个函数只有一个实例。闭包在运行时可以有多个实例，不同的引用环境和相同的函数组合可以产生不同的实例。所谓引用环境是指在程序执行中的某个点所有处于活跃状态的约束所组成的集合。其中的约束是指一个变量的名字和其所代表的对象之间的联系。那么为什么要把引用环境与函数组合起来呢？这主要是因为在支持嵌套作用域的语言中，有时不能简单直接地确定函数的引用环境。这样的语言一般具有这样的特性：
	函数是一阶值（First-class value），即函数可以作为另一个函数的返回值或参数，还可以作为一个变量的值。
	函数可以嵌套定义，即在一个函数内部可以定义另一个函数。
	
上述提到的`词法上下文`, 就是我提到的函数定义时的上下文.


下面再写一个更好的闭包的例子:

	var outer = function(){
		var name = "Alan";

		return {
			get: function(){ return name; },
			set: function(val){ name = val; }
		};
	};

再写一个完全等价的C#代码:

	Func<Tuple<Func<string>, Action<string>>> Closure = () =>
	{
		var name = "Alan";
		Func<string> get = () => name;
		Action<string> set = (newVal) => name = newVal;
		return Tuple.Create(get, set);
	};

	var closure = Closure();
	Console.WriteLine(closure.Item1()); // => Alan
	closure.Item2("Allen");             
	Console.WriteLine(closure.Item1);   // => Allen
		
对, 上面那个就是C#代码. C#大部分情况下是Capture by reference, 捕获的是变量的引用. (推荐一篇关于C#闭包的[文章](http://csharpindepth.com/Articles/Chapter5/Closures.aspx).)

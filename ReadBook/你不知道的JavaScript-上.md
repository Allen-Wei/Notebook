# Chapter 2

## 2.2 欺骗词法

### 2.2.1 eval

JavaScript 中的 `eval(..)` 函数可以接受一个字符串为参数，并将其中的内容视为好像在书写时就存在于程序中这个位置的代码。换句话说，可以在你写的代码中用程序生成代码并运行，就好像代码是写在那个位置的一样: 

```javascript

function foo(str, a) { 
  eval( str ); 
}
var b = 2;
foo( "var b = 3;", 1 ); // 1, 3
```

在严格模式的程序中，`eval(..)` 在运行时有其自己的词法作用域，意味着其中的声明无法修改所在的作用域: 

```javascript
function foo(str) { 
  "use strict"; 
  eval( str ); 
  console.log( a ); // ReferenceError: a is not defined 
}
foo( "var a = 2" );
```

JavaScript中还有其他一些功能效果和`eval(..)`很 相 似。`setTimeout(..)`和 `setInterval(..)` 的第一个参数可以是字符串，字符串的内容可以被解释为一段动态生成的函数代码。这些功能已经过时且并不被提倡。不要使用它们!

`new Function(..)` 函数的行为也很类似，最后一个参数可以接受代码字符串，并将其转化为动态生成的函数(前面的参数是这个新生成的函数的形参)。这种构建函数的语法比 `eval(..)` 略微安全一些，但也要尽量避免使用。

# 函数作用域和块作用域

函数作用域的含义是指，属于这个函数的全部变量都可以在整个函数的范围内使用及复 用(事实上在嵌套的作用域中也可以使用)。

匿名函数表达式如果没有函数名，当函数需要引用自身时只能使用已经过期的`arguments.callee`引用， 比如在递归中。另一个函数需要引用自身的例子，是在事件触发后事件监听器需要解绑自身:
```html
<div id="button">button</div>
<script>
  document.querySelector("#button").addEventListener("click", function listener(e) {
    var remove = !!e.target.getAttribute("has-clicked");
    if (remove) {
      console.log("remove listen");
      document.querySelector("#button").removeEventListener("click", listener);
    } else {
      console.log("onclick");
      e.target.setAttribute("has-clicked", true);
    }
  })
</script>
```


由于函数被包含在一对 `( )` 括号内部，因此成为了一个函数表达式，通过在末尾加上另外一个 `( )` 可以立即执行这个函数，比如 `(function foo(){ .. })()`。第一个 `( )` 将函数变成表达式，第二个 `( )` 执行了这个函数。

IIFE模式的另外一个应用场景是解决 `undefined` 标识符的默认值被错误覆盖导致的异常 (虽然不常见)。将一个参数命名为 `undefined`，但是在对应的位置不传入任何值，这样就可以保证在代码块中 `undefined` 标识符的值真的是 `undefined`:
```javascript
undefined = true; // 给其他代码挖了一个大坑!绝对不要这样做! 
(function IIFE( undefined ) { 
  var a; 
  if (a === undefined) { 
    console.log( "Undefined is safe here!" ); 
    }
})();
```

IIFE 还有一种变化的用途是倒置代码的运行顺序，将需要运行的函数放在第二位，在 IIFE 执行之后当作参数传递进去。这种模式在 __UMD(Universal Module Definition)__ 项目中被广 泛使用。尽管这种模式略显冗长，但有些人认为它更易理解:
```js
var a = 2;
(function IIFE( def ) { 
  def( window );
})(function def( global ) { 
  var a = 3; 
  console.log( a ); // 3 
  console.log( global.a ); // 2
});
```
函数表达式 `def` 定义在片段的第二部分，然后当作参数(这个参数也叫作 `def`)被传递进 IIFE 函数定义的第一部分中。最后，参数 `def`(也就是传递进去的函数)被调用，并将 `window` 传入当作 `global` 参数的值。

JavaScript 的 ES3 规范中规定 try/catch 的 `catch` 分句会创建一个块作用域，其中声明的变量仅在 `catch` 内部有效: 
```js
try { 
  undefined(); // 执行一个非法操作来强制制造一个异常
} catch (err) { 
  console.log( err ); // 能够正常执行! 
} 
console.log( err ); // ReferenceError: err not found
```

`let` 关键字可以将变量绑定到所在的任意作用域中(通常是 `{` 为其声明的变量隐式地劫持了所在的块作用域。


# 5 作用域闭包

当函数可以记住并访问所在的词法作用域时，就产生了闭包，即使函数是在当前词法作用域之外执行。

```js
function foo() { 
  var a = 2; 
  function bar() { 
    console.log( a ); 
  } 
  return bar;
}
var baz = foo();

baz(); // 2 这就是闭包的效果
```
拜 `bar()` 所声明的位置所赐，它拥有涵盖 `foo()` 内部作用域的闭包，使得该作用域能够一 直存活，以供 `bar()` 在之后任何时间进行引用。
`bar()` 依然持有对该作用域的引用，而这个引用就叫作闭包。


如果将(访问它们各自词法作用域的)函数当作第一 级的值类型并到处传递，你就会看到闭包在这些函数中的应用。在定时器、事件监听器、 Ajax 请求、跨窗口通信、Web Workers 或者任何其他的异步(或者同步)任务中，只要使 用了回调函数，实际上就是在使用闭包!


## 5.4 循环和闭包

```js
for (var i=1; i<=5; i++) { 
  setTimeout( function timer() { 
    console.log( i ); 
  }, i*1000 );
}
```
我们试图假设循环中的每个迭代在运行时都会给自己“捕获”一个 `i` 的副本。但是根据作用域的工作原理，实际情况是尽管循环中的五个函数是在各个迭代中分别定义的，但是它们都被封闭在一个共享的全局作用域中，因此实际上只有一个 `i`, 所有函数共享一个 `i` 的引用, 然后最终输出五个6. 解决办法就是让每个timer捕获一个`i`变量,而不是共享一个`i`变量. 一种方案是使用`let`代替`var`. 或者使用IIFE: 

```js
for (var i=1; i<=5; i++) { 
  (function() { 
    var j = i;  // 这里必须重新将i赋值到一个当前函数作用域的一个变量上, 如果作用域是空的，那么仅仅将它们进行封闭是不够的
    setTimeout( function timer() { 
      console.log( j ); 
    }, j*1000 ); 
  })(); 
}
```
或者使用以下方式: 
```js
for (var i=1; i<=5; i++) { 
  (function(j) { 
    setTimeout( function timer() { 
      console.log( j ); 
    }, j*1000 ); 
  })(i); 
}
```
在迭代内使用 IIFE 会为每个迭代都生成一个新的作用域，使得延迟函数的回调可以将新的作用域封闭在每个迭代内部，每个迭代中都会含有一个具有正确值的变量供我们访问。
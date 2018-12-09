
# 关于JavaScript里的 `==` 比较规则 - Alan Wei


在JavaScript的按真假划分数据, 有两种类型的值: 真值(truly), 假值(fasly).
fasly包括: `0`, `""`(空字符串), `false`, `NaN`, `undefined`, `null`等(我知道的就这些). 除了这些fasly就都是truly了.
所以一下代码都会输出 `false value`:

	if(0) { } else { console.log("false vlaue"); }
	if("") { } else { console.log("false vlaue"); }
	if(false) { } else { console.log("false vlaue"); }
	if(NaN) { } else { console.log("false vlaue"); }

但是在执行`==`比较的时候, 下面的比较是`true`:

	0 == false
	"" == false

但下面的代码比较是`false`:

	undefined == false
	null == false

(在这里没有提到 `NaN == false` 是因为很明显这个返回的是`false`).

这是为什么呢? 很多时候我以为JavaScript里`===`执行的是类型和值比较(只有类型和值都相等的时候才是`true`), 而`==`只是执行值比较. 对于`==`的认知是错误的, `==`不是简单地进行值比较, 会进行一定类型转换.
在 [ECMA-262 5th](http://ecma262-5.com/ELS5_HTML.htm#Section_11.9.3) 文档中提到的`x == y`的比较逻辑:
	
	1. 这里省略, 因为这里是类型相同的规则, 和本次讨论的无关.
	2. If x is null and y is undefined, return true. 
	3. If x is undefined and y is null, return true.
	4. If Type(x) is Number and Type(y) is String, return the result of the comparison x == ToNumber(y).
	5. If Type(x) is String and Type(y) is Number, return the result of the comparison ToNumber(x) == y.
	6. If Type(x) is Boolean, return the result of the comparison ToNumber(x) == y.
	7. If Type(y) is Boolean, return the result of the comparison x == ToNumber(y).
	8. If Type(x) is either String or Number and Type(y) is Object, return the result of the comparison x == ToPrimitive(y).
	9. If Type(x) is Object and Type(y) is either String or Number, return the result of the comparison ToPrimitive(x) == y.
	10. Return false.

文档里提到的 `ToNumber(x)` 是执行 `Number(x)`转换, `ToPrimitive(x)` 是转换成原始值.
简单表述如下: 

	如果是`undefined`和`null`, 则返回`true`. 
	如果一个是String类型, 一个是Number类型, 将String转换成Number再执行比较.
	如果其中一个是Boolean类型, 将Boolean转换成Number再比较.
	如果其中一个是Object类型, 将Object类型转换成原始值(ToPrimitive)再比较.

这里基本上涉及两种类型转换, `ToNumber(x)` 和 `ToPrimitive(x)`. 在JS的实现里`ToNumber(x)`执行的是`Number(x)`, 而对于`Object`类型, `ToPrimitive(x)`会执行`x.toString()`或者`x.valueOf()` ([9.1 ToPrimitive](http://www.ecma-international.org/ecma-262/5.1/#sec-9.1)).
在上面提到的 `undefiend == false` 适用于第10条.
但是为什么`!undefined == true` 会返回`true`? 因为在`undefined`前面加上`!`会执行类型转换, 所以是true.
所以在执行`==`比较时并不是简单的进行truly和fasly的比较, 而是进行类型转换后进行比较的. 对于`0 == false`实际执行的是`0 == Number(false)`, 而`"" == false`执行的是`Number("") == Number(false)`.

对于以下代码:

	if([]){
		console.log("[] is truly");
	}

	if([] == false){
		console.log("[] == false");
	}

	[] == false 	//=> true


因为`[]`是truly值, `[] == false`返回`true`, 所以上面两条if语句都会执行打印. 实际上 `[] == false` 执行的比较流程如下:

先是遵循第9条:

	[].toString() == true

得到

	"" == true

然后第7条:

	"" == Number(true)

得到

	"" == 0

然后第5条
	
	Number("") == 0

得到
	
	0 == 0

返回 `true`


简而言之, `if`括号里表达式返回值是truly值, 就判断为真, 但truly值在和`true`执行`==`比较的时候却未必都返回true. 执行比较要符合规范里的那10条规则.


下面回归到最初的问题

	undefined == false
	null == false

这个问题太简单, 直接看规范第10条, 返回`false`.


> 关于JavaScript里的 == 比较规则
> -Alan Wei
## 第一章块级作用域绑定

### 临时死区 Temporal Dead Zone

与`var`不同, `let`和`const`声明的变量不会被提升到作用域顶部, 如果在声明之前访问这些变量, 即使是相对安全的`typeof`操作符也会出发引用错误:

```javascript
if(condition){
    console.log(typeof vlaue); //抛出引用错误异常
    let value = "blue";
}
```

JavaScript引擎在扫描代码发现变量声明时, 要么将他们提升至作用域顶部(遇到`var`声明), 要么将声明放到TDZ中(遇到`let`和`const`声明). 访问TDZ中的变量会触发运行时错误. 只有执行过变量声明语句后, 变量才会从TDZ中移出, 然后方可正常访问.
但在`let`声明的作用域外对该变量使用`typeof`则不会报错: 

```javascript
console.log(typeof value); // undefined
if(condition){
    let value = "hello";
}
```

`typeof`是在声明变量`value`的代码块外执行的, 此时`value`并不在TDZ中. 这也就意味着不存在`value`这个绑定, `typeof`操作最终返回`undefined`. TDZ 只是块级绑定的特色之一.

## 第二章字符串和正则表达式

### codePointAt, String.fromCOdePoint

//String.fromCodePoint(134071);
在UTF-16中, 前2^16个码位均以16位的编码单元表示, 这个范围被称作*基于多文种平面(BMP, Basic Multilingual Plane)*. 超出这个范围的码位则要归属于某个辅助平面(*supplementary plane*), 其中的码位仅用16位就无法表示了. 为此UTF-16引入了*代理对(surrogate pair)*, 其规定用两个16位编码单元表示一个码位. 也就是说, 字符串里的字符有两种, 一种是由一个编码单元16表示的BMP字符, 另一种是由两个编码单元32位表示的辅助平面字符.

在ECMAScript 5中, 所有字符串的操作都基于16位编码单元. 如果采用同样的方式处理包含代理对的UTF-16编码字符, 得到的结果可能与预期不符, 就像这样: 

```javascript
"AB".charAt(0) // A
"AB".charAt(1) // B
"AB".charCodeAt(0) // 65
"AB".charCodeAt(1) // 66

let text = "𠮷";

console.log(text.length);           // text的长度事实上是1, 但它的length属性值却为 2
console.log(/^.$/.test(text));      // false, text被判定为两个字符, 因此匹配单一字符的正则表达式会失效
//前后两个16位编码单元都不表示任何可打印字符, 因此charAt()方法不会返回合法的字符串
console.log(text.charAt(0));        // "" 
console.log(text.charAt(1));        // ""
//charCodeAt()方法同样不能正确识别字符, 它返回每个16位编码单元对应的数值.
console.log(text.charCodeAt(0));    // 55362
console.log(text.charCodeAt(1));    // 55362
```

ECMAScript 6新增了完全支持UTF16的`codePointAt()`方法, 这个方法接受编码单元的位置而非字符位置作为参数, 返回与字符串中给定位置对应的码位, 即一个整数值. 对于BMP字符集的字符(*1 -> 2^16*), `codePointAt()`和`charCodeAt()`返回值相同. 而对于非BMP字符集来说返回值不同. `charCodeAt(0)`方法返回的只是位置0处的第一个编码单元, 而`codePointAt(0)`方法返回完整的码位:

```javascript
let text = "𠮷A";

console.log(text.charCodeAt(0)); // 55362
console.log(text.charCodeAt(1)); // 57271
console.log(text.charCodeAt(2)); // 65

console.log(text.codePointAt(0)); // 134071
console.log(text.codePointAt(1)); // 57271
console.log(text.codePointAt(2)); // 65
```

要检测一个字符占用的编码单元的数量(BMP字符占用一个编码单元, 非BMP字符占用两个编码单元, 一个编码单元用16位表示.), 最简单的方法是调用字符的`codePointAt()`方法: 

```javascript
//检测是否不是BMP字符集里的字符
function is32Bit(c){
    return c.codePointAt(0) > 0xFFFF;
    // or
    //return c.codePointAt(0) > (Math.pow(2, 16) - 1);
}

is32Bit("𠮷") //true
is32Bit("a") //false
is32Bit(String.fromCodePoint(Math.pow(2, 16))) //true
is32Bit(String.fromCodePoint(Math.pow(2, 16) - 1)) //true
```

`String.fromCodePoint()` 和 `codePointAt()` 执行相反的操作, 返回指定码位的字符.

注意`for`循环遍历32bit字符串可能遇到的问题: 

```javascript
let text = "𠮷";
/**
 * 因为 text.length 返回 2, 所以下面的循化会输出两个字符, 分别是: 
 *  String.fromCharCode("𠮷".charCodeAt(0))
 *  String.fromCharCode("𠮷".charCodeAt(1)) 
 */ 
for(let i = 0; i <= text.length; i++){
    console.log(text[i])
}

/**
 * 下面的循环符合预期输出 𠮷
 * 因为 text[Symbole.iterator] 是按照字符计算; 而 text.length, 包括 text[i], 按照编码单元计算.
 */ 
for(let c of text){
    console.log('out: ', c);
}
```

### 正则表达式 u 修饰符

当一个正则表达式添加了`u`修饰符时, 就从默认的编码单元操作模式切换为字符模式, `u`修饰符的表达式就不会视*代理对(surrogate pair)*为两个字符, 从而完全按照预期执行: 

```javascript
let text = "𠮷";

text.length         // 2
/^.$/.test(text)    //false, 没有u修饰符会匹配编码单元
/^.$/u.test(text)   //true, 使用u修饰符后进行字符匹配
```

### 计算码位数量

虽然在ES6中字符串的`length`依然返回字符串编码单元的数量, 但是借助`u`修饰符, 可以通过正则表达式解决这个问题: 

```javascript
function codePointLength(text){
    let result = text.match(/[\s\S]/gu);
    return result ? result.length : 0;
}
codePointLength("abc")  // 3
codePointLength("𠮷bc") // 3
```
这个方法尽管有效, 但是统计长字符串中的码位数量时, 运行效率很低. 因此也可以使用字符串迭代器解决低效率的问题: 

```javascript
Array.from("𠮷bc"[Symbol.iterator]()).length // 3
```

### 检测u修饰符支持

```javascript
function hasRegExpU(){
    try {
        let pattern = new RegExp(".", "u");
        return true;
    } catch (e){
        return false;
    }
}
```

### 其他字符串变更

* `String.prototype.includes(String)` 检测字符串是否包含指定文本
* `String.prototype.repeat(Number)` 返回当前字符串重复指定次数的新字符串

### 正则表达式的复制

```javascript
let re1 = /ab/i,
    re2 = new RegExp(re1), //此处的`re2`只是变量`re1`的一份拷贝, re1 和 re2 有相同的修饰符
    re3 = new RegExp(re1, "g"); //此行代码在ES5中会抛出一个错误, ES6中正常运行, 并把 re1 的修饰符从 i 变成了 g
```

### flags 属性

在ES5中, 通过`source`属性获取正则表达式的文本, 但是如果获取修饰符需要如下代码格式化`toString()`方法输出的文本:

```javascript
function getFlagss(reg){
    var raw = reg.toString();
    return raw.substring(raw.lastIndexOf("/") + 1, raw.length);
}

getFlags(/ab/g) // g
```

在ES6中, 新增了一个属性`flags`属性, 返回正则表达式的修饰符.

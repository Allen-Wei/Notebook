# `\p{name}`对Unicode字符匹配

在.Net中, `\p{}` 用于匹配Unicode类别的字符或Unicode字符块(Unicode Category or Unicode Block)[2]. Unicode标准化组织为每个字符设置了一个通用分组. 比如一部分可以大写的字母(用`Lu`标识此分组), 十进制数字分组(`Nd`组), 数学符号(`Sm`组)或者是文章段落分隔符(`Z1`组). 在Unicode标准中特定的字符集占有特定的连续Unicode码区间块. 比如基本的拉丁字符集是从`\u0000`开始到`\u007f`介绍, 而阿拉伯字符集从`\u0600`到`\u06ff`.

## `\w` 匹配字符需要注意的地方

	Regex.IsMatch("你好", @"^\w+$")									// true
	Regex.IsMatch("你好", @"^\w+$", RegexOptions.CultureInvariant)	// true 
	Regex.IsMatch("你好", @"^\w+$", RegexOptions.ECMAScript)		//false
	Regex.IsMatch("你好hello", @"^\p{L}+$")							// true

`\w`在MSDN里解释: `\w`匹配任意单字字符(word character), 包括下表列出的任意Unicode类别下的字符[1]:
* `Ll` 小写字母(Letter, Lowercase)
* `Lu` 大写字母(Letter, Uppercase)
* `Lt` Letter, Titlecase(不明白匹配哪一类字符)
* `Lo` 其它字符(Letter, Other, 这个会匹配中文)
* `Lm` 修饰符(Letter, Modifier)
* `Mn` 标记字符, 非空(Mark, Nonspacing)
* `Nd` 数字, 小数(Number, Decimal Digit)
* `Pc` 标点符号, 连接符. 这个分类包括了十个字符, 其中最常用的是下划线字符(_) `\u+005f`.(Punctuation, Connector. This category includes ten characters, the most commonly used of which is the LOWLINE character (_), u+005F.)

如果指定了ECMAScript兼容(`RegexOptions.ECMAScript`)行为, `\w`等价于`[a-zA-Z_0-9]`. 

## 关于中文(CJK[3])的匹配

下面摘述自[StackOveflow](http://stackoverflow.com/questions/1366068/whats-the-complete-range-for-chinese-characters-in-unicode)
> May be you would find a complete list through the [CJK Unicode FAQ](http://www.unicode.org/faq/han_cjk.html) (which does include "Chinese, Japanese, and Korean" characters)
> The [East Asian Script](http://www.unicode.org/versions/Unicode5.0.0/ch12.pdf#G12159) document does mention:

> > Blocks Containing Han Ideographs 
> > Han ideographic characters are found in five main blocks of the Unicode Standard, as shown in Table 12-2

> Table 12-2. Blocks Containing Han Ideographs

	Block                                   Range       Comment
	CJK Unified Ideographs                  4E00-9FFF   Common
	CJK Unified Ideographs Extension A      3400-4DBF   Rare
	CJK Unified Ideographs Extension B      20000-2A6DF Rare, historic
	CJK Unified Ideographs Extension C      2A700–2B73F Rare, historic
	CJK Unified Ideographs Extension D      2B740–2B81F Uncommon, some in current use
	CJK Unified Ideographs Extension E      2B820–2CEAF Rare, historic
	CJK Compatibility Ideographs            F900-FAFF   Duplicates, unifiable variants, corporate characters
	CJK Compatibility Ideographs Supplement 2F800-2FA1F Unifiable variants

> Note: the block ranges can evolve over time: latest is in [CJK Unified Ideographs](https://en.wikipedia.org/wiki/CJK_Unified_Ideographs).
> See also Wikipedia:
> * [CJK Unified Ideographs Extension A](https://en.wikipedia.org/wiki/CJK_Unified_Ideographs_Extension_A)
> * [CJK Unified Ideographs Extension B](https://en.wikipedia.org/wiki/CJK_Unified_Ideographs_Extension_B)
> * [CJK Unified Ideographs Extension C](https://en.wikipedia.org/wiki/CJK_Unified_Ideographs_Extension_C)
> * [CJK Unified Ideographs Extension D](https://en.wikipedia.org/wiki/CJK_Unified_Ideographs_Extension_D)
> * [CJK Unified Ideographs Extension E](https://en.wikipedia.org/wiki/CJK_Unified_Ideographs_Extension_E)

如果要匹配常用的中文汉字(实际上可能包括韩文和日文)可以用以下表达式
	
	Regex.IsMatch("你好世界", @"^[\u4E00-\u9FFF]+$")	// true


[1] [Word Character: \w](https://msdn.microsoft.com/en-us/library/20bw873z(v=vs.110).aspx#Word%20Character:%20\w)

[2] [Unicode Category or Unicode Block: \p{}](https://msdn.microsoft.com/en-us/library/20bw873z(v=vs.110).aspx#Unicode%20Category%20or%20Unicode%20Block:%20\p{});

[3] [Chinese and Japanese](http://www.unicode.org/faq/han_cjk.html)
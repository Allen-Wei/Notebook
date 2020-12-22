# JavaScript编程全解

# 第9章 DOM

## Live 对象的特征
`NodeList` 对象的一大特征就是它是一个 Live 对象: 

```html
<div id="foo">
    <span>first</span>
    <span>second</span>
</div>
<script>
    var elems = document.getElementsByTagName('span');  // getElementsByTagName 返回一个 NodeList 对象
    alert(elems.length); // => 2
    var newSpan = document.createElement('span'); 
    newSpan.appendChild(document.createTextNode('third')); 
    var foo = document.getElementById('foo'); foo.appendChild(newSpan);
    alert(elems.length); // => 3 
</script>
```

在上面的代码中，最初取得的 elems.length 值为 2，这是很显然的。之后，通过 JavaScript 新增了一 个 span 元素。再一次显示 elems.length 时其值变为了 3。

如果是在新增了 span 之后再执行 getElementsByTagName()，自然不会觉得有什么问题，但这里明明 是一个在新增 span 之前就已经取得的 NodeList 对象，却能够知道新增了 span 之后的状态，是不是觉得 有点奇怪?而这就是 Live 对象的一个特征。
Live 对象始终具有 DOM 树实体的引用。因此，对 DOM 树做出的变更也会在 Live 对象中得到体现。

在使用 Live 对象时，必须对 for 循环多加注意: 

```html
<div>sample text</div>
<script>
    var divs = document.getElementsByTagName('div');
    var newDiv;
    for (var i = 0; i < divs.length; i++){
        newDiv = document.createElement('div');
        newDiv.appendChild(document.createTextNode('new div'));
        divs[i].appendChild(newDiv);
    }
</script>
```
在上面的代码中，将会首先取得所有的 div 元素，然后在 for 循环中创建新的 div 元素并添加至这些 div 元素中。于是，作为循环条件的 divs.length 的值将会不断地增加 1，而无法离开循环。对于这种情况， 只要在开始时对 divs.length 进行求值，就可以避免无限循环.

`Array.prototype.slice()` 方法将一个 NodeList 对象转换为一个 Array: `Array.prototype.slice.call(nodeList)`.

除了 NodeList 外，还有其他的 Live 对象。HTMLCollection 也是一个 Live 对象.

### 9.3.5  父节点、子节点、兄弟节点

* `parentNode`: 父节点
* `childNodes`: 子节点列表
* `firstChild`: 第一个子节点
* `lastChild`: 最后一个子节点
* `nextSibling`: 下一个兄弟节点
* `previousSibling`: 上一个兄弟节点

空白符也会作为文本节点处理。换行符也包含在这种情况之中。在书写 HTML 的过程中为了 确保可读性，通常会在标签之间加入一些换行符。然而，这样一来在换行处就会存在一些空白节点。于是，在使用 firstChild 等获取节点的时候就会首先取得这些空白节点。在通过 firstChild 等属性引用元素时，请务必对此加以注意. 

由于上面所介绍的 firstChild 等属性也会包含空白节点，因此最终取得的节点并不一定就是直 观上所以为的那个。如果在取得了节点之后要修改节点，则还须判断节点是否为空白节点，很不方便。 因此，另外还制定了一些用于获取不包含空白节点与注释节点的元素的 API，它们在一些浏览器中已经实现: 

* `children`: 子元素节点列表
* `firstElementChild`: 第一个子元素
* `lastElementChild`: 最后一个子元素
* `nextElementSibling`: 下一个元素
* `previousElementSibling`: 上一个元素
* `childElementCount`: 子元素的数量
# 数据结构与算法：JavaScript描述

## 第2章 数组

`every()`，该方法接受一个返回值为布尔类型的函数，对数组中的每个元素使用该函数。如果对于所有的元素，该函数均返回 `true`，则该方法返回 `true`，否则返回 `false`。

`some() `方法也接受一个返回值为布尔类型的函数，只要有一个元素使得该函数返回 true，该方法就返回 true。

`reduce()`方法接受一个函数，返回一个值。该方法会从一个累加值开始，不断对累加值和数组中的后续元素调用该函数，直到数组中的最后一个元素，最后返回得到的累加值。以下是[Polyfill](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/Reduce#Polyfill)

```javascript
// Production steps of ECMA-262, Edition 5, 15.4.4.21
// Reference: https://es5.github.io/#x15.4.4.21
// https://tc39.github.io/ecma262/#sec-array.prototype.reduce
if (!Array.prototype.reduce) {
    Object.defineProperty(Array.prototype, 'reduce', {
        value: function (callback /*, initialValue*/) {
            if (this === null) {
                throw new TypeError('Array.prototype.reduce called on null or undefined');
            }
            if (typeof callback !== 'function') {
                throw new TypeError(callback + ' is not a function');
            }

            // 1. Let O be ? ToObject(this value).
            var thisObj = Object(this);

            // 2. Let len be ? ToLength(? Get(O, "length")).
            var len = thisObj.length >>> 0;

            // Steps 3, 4, 5, 6, 7
            var k = 0;
            var value;

            if (arguments.length >= 2) {
                value = arguments[1];
            } else {
                while (k < len && !(k in thisObj)) {
                    k++;
                }

                // 3. If len is 0 and initialValue is not present, throw a TypeError exception.
                if (k >= len) {
                    throw new TypeError('Reduce of empty array with no initial value');
                }
                value = thisObj[k++];
            }

            // 8. Repeat, while k < len
            while (k < len) {
                // a. Let Pk be ! ToString(k).
                // b. Let kPresent be ? HasProperty(O, Pk).
                // c. If kPresent is true, then
                //    i.  Let kValue be ? Get(O, Pk).
                //    ii. Let accumulator be ? Call(
                //          callbackfn, undefined,
                //          « accumulator, kValue, k, O »).
                if (k in thisObj) {
                    value = callback(value, thisObj[k], k, thisObj);
                }

                // d. Increase k by 1.
                k++;
            }

            // 9. Return accumulator.
            return value;
        }
    });
}
```

JavaScript 还提供了 `reduceRight()` 方法，和 `reduce()` 方法不同，它是从右到左执行。下面的程序使用 `reduceRight() `方法将数组中的元素进行翻转：

```javascript
var words = ["the ", "quick ","brown ", "fox "];
var sentence = words.reduceRight(function concat(accumulatedString, item) {
    return accumulatedString + item;
});
print(sentence); // 显示 "fox brown quick the"
```
# 获取对象的所有属性(包括原型链上的)

```javascript
function getAllPropertyNames(obj) {
    const props = [];
    do {
        if (obj === Object.prototype)
            break;
        Object.getOwnPropertyNames(obj).forEach(prop => {
            if (!props.includes(prop)) {
                props.push(prop);
            }
        })
    } while (obj = Object.getPrototypeOf(obj));
    return props;
}

let parent = {
    firstName: "alan"
};

let child = {
    lastName: "Wei"
};
Object.setPrototypeOf(child, parent);

console.log(getAllPropertyNames(child)); //=> [firstName, lastName]
```

来源: [Is it possible to get the non-enumerable inherited property names of an object?
](https://stackoverflow.com/questions/8024149/is-it-possible-to-get-the-non-enumerable-inherited-property-names-of-an-object)

## Question

In JavaScript we have a few ways of getting the properties of an object, depending on what we want to get.

1. `Object.keys()`, which returns all own, enumerable properties of an object, an ECMA5 method.

2. a `for...in` loop, which returns all the enumerable properties of an object, regardless of whether they are own properties, or inherited from the prototype chain.

3. `Object.getOwnPropertyNames(obj)` which returns all own properties of an object, enumerable or not.

We also have such methods as `hasOwnProperty(prop)` lets us check if a property is inherited or actually belongs to that object, and `propertyIsEnumerable(prop)` which, as the name suggests, lets us check if a property is enumerable.

With all these options, there is no way to get a non-enumerable, non-own property of an object, which is what I want to do. Is there any way to do this? In other words, can I somehow get a list of the inherited non-enumerable properties?

Thank you.

## Answer

Since `getOwnPropertyNames` can get you non-enumerable properties, you can use that and combine it with walking up the prototype chain.

```javascript
function getAllProperties(obj){
    var allProps = []
      , curr = obj
    do{
        var props = Object.getOwnPropertyNames(curr)
        props.forEach(function(prop){
            if (allProps.indexOf(prop) === -1)
                allProps.push(prop)
        })
    }while(curr = Object.getPrototypeOf(curr))
    return allProps
}
```

I tested that on Safari 5.1 and got

```bash
> getAllProperties([1,2,3])
["0", "1", "2", "length", "constructor", "push", "slice", "indexOf", "sort", "splice", "concat", "pop", "unshift", "shift", "join", "toString", "forEach", "reduceRight", "toLocaleString", "some", "map", "lastIndexOf", "reduce", "filter", "reverse", "every", "hasOwnProperty", "isPrototypeOf", "valueOf", "__defineGetter__", "__defineSetter__", "__lookupGetter__", "propertyIsEnumerable", "__lookupSetter__"]
```

Update: Refactored the code a bit (added spaces, and curly braces, and improved the function name):

```javascript
function getAllPropertyNames( obj ) {
    var props = [];

    do {
        Object.getOwnPropertyNames( obj ).forEach(function ( prop ) {
            if ( props.indexOf( prop ) === -1 ) {
                props.push( prop );
            }
        });
    } while ( obj = Object.getPrototypeOf( obj ) );

    return props;
}
```

And to simply get everything..(enum/nonenum, self/inherited.. Please confirm..

```
function getAllPropertyNames( obj ) {
    var props = [];

    do {
        props= props.concat(Object.getOwnPropertyNames( obj ));
    } while ( obj = Object.getPrototypeOf( obj ) );

    return props;
}
```

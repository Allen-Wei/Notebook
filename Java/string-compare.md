# String compare


不要使用 `==` 操作符比较字符串: 

	location == "World" //错误示例

上面的代码, 当`location`和`"World"`在内存中是同一个对象时, 返回真. **在Java虚拟机中每个字符串只有一个实例**, 因此 `"World" == "World"` 返回 `true`. 但是如下代码: 

	String location = greeting.substring(7, 12);

**如果`location`是计算得来的, 那么结果就要放到一个单独的String对象中**, 并且 `location == "World"` 这种比较就返回`false`了.

在Java中 `==` 比较的是两个对象的引用是否相同, 而`Object`对象里定义的`equal(Object)`也是进行引用比较, 但是类可以重写这个方法, 在`String`类中`equal`方法如下: 

```java
    /**
     * Compares this string to the specified object.  The result is {@code
     * true} if and only if the argument is not {@code null} and is a {@code
     * String} object that represents the same sequence of characters as this
     * object.
     *
     * @param  anObject
     *         The object to compare this {@code String} against
     *
     * @return  {@code true} if the given object represents a {@code String}
     *          equivalent to this string, {@code false} otherwise
     *
     * @see  #compareTo(String)
     * @see  #equalsIgnoreCase(String)
     */
    public boolean equals(Object anObject) {
        if (this == anObject) {
            return true;
        }
        if (anObject instanceof String) {
            String anotherString = (String)anObject;
            int n = value.length;
            if (n == anotherString.value.length) {
                char v1[] = value;
                char v2[] = anotherString.value;
                int i = 0;
                while (n-- != 0) {
                    if (v1[i] != v2[i])
                        return false;
                    i++;
                }
                return true;
            }
        }
        return false;
    }
```

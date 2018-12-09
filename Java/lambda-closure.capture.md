# Lambda闭包

```java
for(int i = 0; i < n; i++){
	new Thread(() -> System.out.println(n));
}
```

Lambda表达式试图获取`i`, 但是这样不合法的, 因为`i`会发送变化.


增强的`for`训话中的变量是有效的`final`变量, 因为整个作用域是单个迭代, 每个迭代都会创建(声明)一个新的`arg`变量, 并且从`args`数组中将下一个值赋值给`arg`. 相比之下, 上一个例子中的变量`i`的作用域是整个循环, 因为`i`变量只声明了一次(`int i = 0;`), 然后在整个循环的每次迭代被共享使用(`i++`).

```java
for(String arg : args){
	new Thread(() -> System.out.println(arg));
}
```


# Core Java for the impatient

## Object.finalize() 

[`finalize` is marked as deprecated in Java 9](https://www.infoq.com/news/2017/03/Java-Finalize-Deprecated).

可以在程序结束之前调用`Runtime`的`addShutdownHook`方法来注册程序结束的钩子:

```java
Runtime.getRuntime().addShutdownHook(new Thread(() -> {
	System.out.println("addShutdownHook");
}));
```

### 2.4.2 静态常量

使用 `static final`声明静态常量
* 最好在类字段(静态字段)共享一个随机数生成器, 相对于实例字段的随机数生成器更节省资源和安全.(随机数生成器最好共用一个)

### 2.4.3 静态初始化块

```java
public class Employee{
	private static final String hello;
	static {
		hello = "world";
	}
}
```

### 2.4.5 工厂方法

静态方法常见的使用就是工厂方法, 也就是返回一个累的新实例的静态方法.

* 获取类实例, 构造函数只能通过参数类型和数量来区分, 而静态方法还可以使用不同的方法名来区分.
* 构造函数只能返回类实例, 静态方法可以返回一个子类实例.
* 静态方法可以返回共享实例(比如单例).

### 2.5.1 包的声明

* 当从文件系统读取类文件时, 路径名称必须匹配包名称, 例如文件`Employee.class`必须在子目录`com/horstmann/corejava`.

### 2.5.2 类路径

你可以使用JAR文件将程序打包: 

	> jar cvfe com.company.MainClass com/company/*.class

然后运行程序:

	> java -jar program.jar

`javac`和`java`命令都有`-classpath`选项, 可以缩写为`-cp`, 用于指定引用的类库文件的jar和目录: 

	> java -classpath .:../libs/lib1.jar:../libs/lib2.jar com.company.MainClass

> 在Windows系统中将`:`替换成`;`.

### 2.6.2 

静态嵌套类使用`static`进行修饰: 

```java
public class Network {
    public static class Member {}

    private List<Member> members = new ArrayList<>();
}
```

内部类不使用`static`修饰, 而且内部类知道自己属于哪个父类的实例, 也就是能够访问父类的实例字段和方法: 
```java
public class Network {
    public class Member {
        //除了编译时常量外, 内部类不能声明静态成员.
        public static final String constant_variable = "is ok";
        public static String static_variable = "error code";
        
        private String name;

        public Member(String name) {
            this.name = name;
        }

        public void remove() {
            members.remove(this);
            //OR
            Network.this.members.remove(this);
        }

        //检查Member对象是否属于某个特定网络(Network)
        public boolean belongsTo(Network n) {
            return Network.this == n;
        }
    }

    private List<Member> members = new ArrayList<>();

    public void add(String name) {
        this.members.add(new Member(name));
        //OR
        this.members.add(this.new Member(name));
    }
}
```

## 接口和lambda表达式

### 3.1.7 常量

* 在接口中无法拥有实例变量, 接口定义行为而不是状态.
* 之前所有的接口方法必须是抽象的(abstract), 现在可以添加两种有具体实现的方法: 静态方法和默认方法.
* 定义在接口中的任何变量自动为`public static final`.
* 工厂方法在接口中非常有意义, 调用接口的工厂方法返回实现接口的实例, 可以让调用者无需关心它是哪个类.

### 3.7.2 访问来自闭合作用域的变量

```java
int index = 0;
List<String> names = Arrays.asList("Alan", "Wei");
Consumer<String> lambda = name -> {
    //index 是自由变量
    System.out.println(name.toLowerCase());
};
names.stream().forEach(lambda);
```
lambda表达式有三个部分: 

1. 代码块
2. 参数(`name` 是参数)
3. 自由变量的值(既不是参数变量, 也不是代码内部定义的变量, 对于lambda表达式, index就是自由变量.)

描述带有自由变量值的技术名词是闭包.

在`lambda`的代码块中无法修改index的值: 
```java
int index = 0;
Consumer<String> lambda = name -> {
	index++; //无法编译
};
```
可以通过使用长度为1的数组绕过这个限制: 
```java
int[] index = new int[1];
Consumer<String> lambda = name -> {
	index[0]++;
};
```
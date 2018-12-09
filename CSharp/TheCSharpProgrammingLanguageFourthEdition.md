## The C# Programming Language Fourth Edition
[CSharp 5.0 Language Specification](https://doc.co/J6cqv8)

[CSharp 5.0 语言规范](https://doc.co/5Vu56y)

[CSharp 4.0 语言规范](https://doc.co/H6vZLM)

[CSharp ECMA Specification](http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-334.pdf)

[C# Programming Guide](https://msdn.microsoft.com/en-us/library/67ef8sbd(v=vs.100).aspx)

### P76 3.5.2 可访问域
一个基类的所有成员(除实例构造函数, 析构函数和静态构造函数之外)都会被子类型继承, 它甚至还包括了基类的私有成员. 但是一个私有成员的可访问域只包含生命那个成员的类的程序文本. Example: 

	public class A 
	{
		private int x;
		static void F(B b)
		{
			b.x = 1;		//It's okay.
		}
	}
	public class B
	{
		static void F(B b)
		{
			b.x = 1;		//Error: x not accessible
		}
	}

B类从A类里继承了私有成员x. 因为这个成员私有的, 所以它只能在A的类主体里访问到. 因此, 访问b.x在A.F方法里是成功的, 但是在B.F方法里却失败了.

### P16 1.6.2 访问控制
`protected internal` 修饰符表示 "只有这个程序或这个类的子类可以访问", 表示的是一种更宽松的组合. 记住这种关系的方法是记住一个成员的 `natural` 状态是 `private`, 每个用于修饰可访问性的修饰符都会使访问范围变大.

有一点需要注意的是, `protected` 修饰符所拥有的限制,	`protected internal` 同样有这些限制, 很好理解, 基于短板效应, 为了肯定不会出现问题, `protected internal` 修饰符是 `protected` 和 `internal` 限制的并集. 比如 *P73* 页提到的, `protected` 或者 `protected internal` 修饰密封类, 编译器会发出警告(因为这么做是没有意义的, 密封类不可以被继承.); 静态类不可以使用 `protected` 和 `protected internal` 修饰符.

### P80 3.6  函数签名
虽然out和ref参数修饰符被认为是函数签名的一部分, 但是在一个类型中生命的成员不可以在签名里仅仅依据ref和out来区分. 入宫在同一个类型中生命的两个成员方法除了将参数里的out修饰符替换成ref修饰符之外其他的都一样的话, 就会发生编译期错误. 对于其他的签名匹配(如隐藏或重写), ref和out都被认为是签名的一部分而不会相互匹配. 这个限制是为了使C#可以轻易地被翻译并运行在CLI之上, CLI并没有提供仅靠ref和out区别定义方法的方式. PS: 实际上在CLI层面只有ref.

就签名而言, object类型和dynamic类型被认为是相同的.

params也不属于签名的一部分.

	interface ITest
	{
		void F(int x);	
		void F(ref int x);
		void F(out int x);		//error
		void F(string[] a);
		void F(params string[] a);		//error 
		void F(object a);
		void F(dynamic a);			//error
	}

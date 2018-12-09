
# 原文

[原文地址](https://blogs.msdn.microsoft.com/ericlippert/2011/09/19/inheritance-and-representation/)

(Note: Not to be confused with [Representation and Identity](https://blogs.msdn.microsoft.com/ericlippert/2009/03/19/representation-and-identity/))

Here’s a question I got this morning:

	class Alpha<X> 
	  where X : class 
	{}
	class Bravo<T, U> 
	  where T : class 
	  where U : T 
	{
	  Alpha<U> alpha;
	}

This gives a compilation error stating that U cannot be used as a type argument for Alpha’s type parameter X because U is not known to be a reference type. But surely U is known to be a reference type because U is constrained to be T, and T is constrained to be a reference type. Is the compiler wrong?

Of course not. Bravo<object, int> is perfectly legal and gives a type argument for U which is not a reference type. All the constraint on U says is that U must inherit from T (1). int inherits from object, so it meets the constraint. All struct types inherit from at least two reference types, and some of them inherit from many more. (Enum types inherit from System.Enum, many struct types implement interface types, and so on.)

The right thing for the developer to do here is of course to add the reference type constraint to U as well.

That easily-solved problem got me thinking a bit more deeply about the issue. I think a lot of people don’t have a really solid understanding of what “inheritance” means in C#. It is really quite simple: a derived type which inherits from a base type implicitly has all inheritable members of the base type. That’s it! If a base type has a member M, then a derived type has a member M as well. (2)

People sometimes ask me if private members are inherited; surely not! What would that even mean? But yes, private members are inherited, though most of the time it makes no difference because the private member cannot be accessed outside of its accessibility domain. However, if the derived class is inside the accessibility domain then it becomes clear that yes, private members are inherited:

	class B
	{
	  private int x;
	  private class D : B 
	  {

D inherits x from B, and since D is inside the accessibility domain of x, it can use x no problem.

I am occasionally asked “but how can a value type, like int, which is 32 bits of memory, no more, no less, possibly inherit from object?  An object laid out in memory is way bigger than 32 bits; it’s got a sync block and a virtual function table and all kinds of stuff in there.”  Apparently lots of people think that inheritance has something to do with how a value is laid out in memory. But how a value is laid out in memory is an implementation detail, not a contractual obligation of the inheritance relationship! When we say that int inherits from object, what we mean is that if object has a member — say, ToString — then int has that member as well. When you call ToString on something of compile-time type object, the compiler generates code which goes and looks up that method in the object’s virtual function table at runtime. When you call ToString on something of compile-time type int, the compiler knows that int is a sealed value type that overrides ToString, and generates code which calls that function directly. And when you box an int, then at runtime we do lay out an int the same way that any reference-typed object is laid out in memory.

But there is no requirement that int and object be always laid out the same in memory just because one inherits from the other; all that is required is that there be some way for the compiler to generate code that honours the inheritance relationship.


(1) or be identical to T, or possibly to inherit from a type related to T by some variant conversion.

(2) Of course that’s not quite it; there are some odd corner cases. For example, a class which “inherits” from an interface must have an implementation of every member of that interface, but it could do an explicit interface implementation rather than exposing the interface’s members as its own members. This is yet another reason why I’m not thrilled that we chose the word “inherits” over “implements” to describe interface implementations. Also, certain members like destructors and constructors are not inheritable.



# 译文

今儿中午我碰到一个问题

	class Alpha<X> 
	  where X : class 
	{}
	class Bravo<T, U> 
	  where T : class 
	  where U : T 
	{
	  Alpha<U> alpha;
	}

这段代码给出一个编译期错误，表明U不能够用作Alpha的类型参数X。但是很明显U是引用类型，因为U是被T约束，而T被约束为一个引用类型。是编译器错了吗？

当然不是。Bravo<object, int>就是一个给出类型参数U不是引用类型的完美合法的例子。U的所有约束说明U必须继承子T，int继承自object，所以例子符合约束。所有的struct类型至少继承了两个引用类型，有一些继承了更多个（枚举类型继承了Sustem.Enum, 许多结构类型继承了引用类型，等等。）

对于开发者来说，在这里正确的做法当然是给U也加上引用类型约束。

这个很容易解决的问题让我进行了更深层次的思考。我想很多开发者并不真正地理解了C#里的继承意味着什么。继承是非常简单的：一个从基类型继承过来的子类型拥有基类型所有的可继承成员。就是这么简单！如果基类型有成员M，子类型也会有成员M。

人们有时候会问我私有成员是否会被挤成，当然不会。私有成员总是不会被继承吗？但也不总是。私有成员被继承，虽然大部分时候这和没继承没有什么区别，因为私有成员在它的可访问域的外面是不能够被访问的。但是，如果子类型在可访问域的里面，这个回答就是：可以。

私有成员被继承

	class B
	{
	  private int x;
	  private class D : B 
	  {

D从B那里继承了成员x，而且因为D是在x可访问域的内部，所以D使用x是没问题的。

我偶尔会疑惑：值类型，比如int，使用32字节的内存空间，不多不少，是怎么可能继承自object呢？一个内存中的object 是大于32字节的。它需要一个同步的块和虚函数表以及在上面的所有东西。很明显很多人认为继承要做一些事情，以便让值存储在内存里。但是值如何存储在内存中是实现细节，而不是继承关系契约。当我们说int继承object时，我们的意思是如果object拥有的成员，比如说ToString，int也會拥有。当你在编译时的object调用ToString时，编译器生成代码，在运行时的对象的虚函数表中查找方法。当你编译时期的int类型上调用ToString方法时，编译器知道是重写了ToString方法的密封值类型，然后生成直接调用函数的代码。当你将一个int类型装箱，在运行时，我们我们像任何其他引用类型存储在内存中一样来存储int。

int和object总是同样存储在内存中没有特别的要求，仅仅因为一个继承自另外一个。所有的这些要求编译器必须有一种方式来生成代码来保证继承关系。

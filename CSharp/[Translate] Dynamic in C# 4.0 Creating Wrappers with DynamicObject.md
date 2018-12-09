## Dynamic in C# 4.0: Creating Wrappers with DynamicObject
*[原文](http://blogs.msdn.com/b/csharpfaq/archive/2009/10/19/dynamic-in-c-4-0-creating-wrappers-with-dynamicobject.aspx)*

In the [previous post](http://blogs.msdn.com/csharpfaq/archive/2009/10/01/dynamic-in-c-4-0-introducing-the-expandoobject.aspx) I showed how you can use the new dynamic feature and the ExpandoObject class to add and remove properties at run time, and how this can make your code more readable and flexible than code written with LINQ to XML syntax.

在上一篇文章, 我展示了如何使用 `dynamic`特性 和 `ExpandoObject`类 在运行时添加和删除属性, 而且让你的代码相比较 LINQ to XML 语法更加可读和可扩展.

But there were some obvious flaws in that example: While ExpandoObject provided better syntax, LINQ to XML provided a lot of useful library methods that helped you to work with XML files. So, is it possible to combine those two advantages, to have better syntax and still get all those methods? The answer is yes, but you need another type from the System.Dynamic namespace: DynamicObject.

但是在这个例子里有一个很明显的缺陷: 虽然 `ExpandoObject` 提供了更好的语法, 但是 LINQ to XML 提供了大量有用的类库方法来帮助你处理XML文件. 因此, 有没有可能合并两个优点, 即拥有更好的语法而且能获得LINQ to XML的所有方法? 答案是可(zhuang)以(bi)的, 不过你需要另外一个来自 `System.Dynamic` 命名空间的类型 `DynamicObject`.

The DynamicObject class enables you to override operations like getting or setting a member, calling a method, or performing any binary, unary, or type conversion operation. To illustrate the issue, let’s create a very simple object that overrides the "get property" operation, so that whenever you access a property it returns the property’s name as a string. This example has no practical value.

`DynamicObject`类 能够让你重写像 获取/设置成员, 方法调用, 或者执行一元/二元/类型转换 的操作. 为了演示这些问题(这里应该是feature吧, 不明白为什么博文里是issue), 让我们创建一个很简单的对象来重写	`get property` 操作, 无论你什么时候访问属性, 它都已字符串的形式返回属性的名字 . 这个例子没有实际的值.

	public class SampleObject : DynamicObject
	{
	    public override bool TryGetMember(
	        GetMemberBinder binder, out object result)
	    {
	        result = binder.Name;
	        return true;
	    }
	}

As with ExpandoObject, we must use the dynamic keyword to create an instance of this class.

就像 `ExpandoObject` 一样, 我们必须使用 `dynamic` 关键字来创建类的实例.

	dynamic obj = new SampleObject();
	Console.WriteLine(obj.SampleProperty);
	//Prints "SampleProperty".

Let’s see what’s going on in this example. When you call obj.SampleProperty, the dynamic language runtime (DLR) uses the language binder to look for a static definition of this property in the SampleObject class. If there is no such property, the DLR calls the TryGetMember method. This method gets information about what property it was called for through the binder parameter. As you can see, the binder.Name contains the actual name of the property.

让我们一探究竟. 当你调用 `obj.SampleProperty`, 动态语言运行时(DLR)使用语言绑定去查找这个属性在 `SampleObject`类 中的静态定义. 如果没有这个属性 DLR 调用 `TryGetMember` 方法, 这个方法通过 `binder` 参数获取被调用参数的信息. 就像你能看到的, `binder.Name` 包含了这个属性的确切名称.

The TryGetMember method returns true if the operation is successful. But the actual result of the operation must be assigned to the out parameter result. In this example, TryGetMember returns true, but obj.SampleProperty returns "SampleProperty".

如果操作成功, `TryGetMember` 方法返回 `true`. 但是执行得到的真实结果必须赋值给输出参数`result`. 在这个例子里面, `TryGetMember` 返回true, 不过 `obj.SampleProperty` 返回 "SampleProperty".


Now let’s move to a more complex example and create a wrapper for the XElement object. Once again, I’ll try to provide better syntax for the following LINQ to XML sample.

现在我们移步来看一个更复杂的例子, 创建一个嵌套的XElement对象. 再次强调, 哥要试着提供一个比下面的 LINQ to XML 更好的语法.

	XElement contactXML =
	    new XElement("Contact",
	    new XElement("Name", "Patrick Hines"),
	    new XElement("Phone", "206-555-0144"),
	    new XElement("Address",
	        new XElement("Street1", "123 Main St"),
	        new XElement("City", "Mercer Island"),
	        new XElement("State", "WA"),
	        new XElement("Postal", "68042")
	    )
	);

First of all, I need to create an analog of ExpandoObject. I still want to be able to dynamically add and remove properties. But since I am essentially creating a wrapper for the XElement type, I’ll use XElement instead of the dictionary to maintain the properties.

首先, 我需要创建一个模拟`ExpandoObject`的对象. 我需要能够动态添加和删除属性. 不过其实我本质上是创建一个包裹`XElement`对象的一个类型, 我将使用`XElement`对象来代替字典去维护属性.

	public class DynamicXMLNode : DynamicObject
	{
	    XElement node;
	    public DynamicXMLNode(XElement node)
	    {
	        this.node = node;
	    }
	    public DynamicXMLNode()
	    {
	    }
	    public DynamicXMLNode(String name)
	    {
	        node = new XElement(name);
	    }
	    public override bool TrySetMember(
	        SetMemberBinder binder, object value)
	    {
	        XElement setNode = node.Element(binder.Name);
	        if (setNode != null)
	            setNode.SetValue(value);
	        else
	        {
	            if (value.GetType() == typeof(DynamicXMLNode))
	                node.Add(new XElement(binder.Name));
	            else
	                node.Add(new XElement(binder.Name, value));
	        }
	        return true;
	    }
	    public override bool TryGetMember(
	        GetMemberBinder binder, out object result)
	    {
	        XElement getNode = node.Element(binder.Name);
	        if (getNode != null)
	        {
	            result = new DynamicXMLNode(getNode);
	            return true;
	        }
	        else
	        {
	            result = null;
	            return false;
	        }
	    }
	}

And here is how you can use this class.

这里是如何使用这个类.
	
	dynamic contact = new DynamicXMLNode("Contacts");
	contact.Name = "Patrick Hines";
	contact.Phone = "206-555-0144";
	contact.Address = new DynamicXMLNode();
	contact.Address.Street = "123 Main St";
	contact.Address.City = "Mercer Island";
	contact.Address.State = "WA";
	contact.Address.Postal = "68402";

Let’s look at the contact object. When this object is created, it initializes its inner XElement. If you set a property value, like in contact.Phone = "206-555-0144", the TrySetMember method checks whether an element with the name Phone exists in its XElement. If it does not exist, the method creates the element.

让我们看看`contact`这个对象. 当这个对象被创建, 它会初始化内部的`XElement`对象. 如果你设置属性值, 比如 `contact.Phone = "206-555-0144"`, `TrySetMember` 方法会检查是否存在一个名为`Phone`的XElenent元素. 如果没有存在就创建它.


The next interesting line is contact.Address = new DynamicXMLNode(). Basically, in this particular example this line means that I want to create a node that has subnodes. For this property, the TrySetMember method creates an XElement without a value.

下一个有趣的是 `contact.Address = new DynamicXMLNode()`. 本质上, 在这个特定的例子, 这一行的意思是我想创建一个拥有子节点的节点. 对于这个属性, `TrySetMember` 方法创建一个不包含值的XElement.


The most complex case here is a line such as contact.Address.State = "WA". First, the TryGetMember method is called for contact.Address and returns a new DynamicXMLNode object, which is initialized by the XElement with the name Address. (Theoretically, I could have returned the XElement itself, but that would make the example more complicated.) Then the TrySetMember method is called. The method looks for the State element in contact.Address. If it doesn’t find one, it creates it.

这里最复杂的情况是 `contact.Address.State = "WA"` 这一行. 首先, `TryGetMember` 方法被 `contact.Address` 调用, 然后返回一个新的 `DynamicXMLNode` 对象, 它被名为Address的XElement初始化. (从理论上说, 我可以返回`XElement` 本身, 但是这将会让例子变得更加难懂.) 接着 `TrySetMember` 方法被调用. 这个方法从 `contact.Address` 查找 `State` 元素, 如果不存在, 创建一个.



So I have successfully created the required XML structure. But TryGetMember always returns an instance of DynamicXMLNode. How do I get the actual value of the XML node? For example, I want the following line to work, but now it throws an exception.

至此, 我成功创建了需要的XML结构. 但是 `TryGetMember` 总是返回一个 `DynamicXMLNode` 实例. 我要如何才能获取XML节点的真实的值呢? 比如, 我想让下面的一行代码运行, 但现在它抛出一个异常.


	String state = contact.Address.State;

I have several options here. I can modify the TryGetMember method to return actual values for leaf nodes, for example. But let’s explore another option: override type conversion. Just add the following method to the DynamicXMLNode class.

在这里我有数个选项可以解决. 比如, 我可以修改 `TryGetMember` 方法来返回左侧节点真实的值. 但是让我们来尝试另一个选择: 重写类型转换. 仅仅添加下面的方法到 `DynamicXMLNodel` 类.


	public override bool TryConvert(
	    ConvertBinder binder, out object result)
	{
	    if (binder.Type == typeof(String))
	    {
	        result = node.Value;
	        return true;
	    }
	    else
	    {
	        result = null;
	        return false;
	    }
	}


Now whenever I have an explicit or implicit type conversion of the DynamicXMLNode type, the TryConvert method is called. The method checks what type the object is converted to and, if this type is String, the method returns the value of the inner XElement. Otherwise, it returns false, which means that the language should determine what to do next (in most cases it means that you’re going to get a run-time exception).

现在无论 `TryConvert` 何时被调用, 我都有一个对 `DynamicXMLNOde`类型 的显示或隐式的类型转换. 这个方法检查对象被转换成什么类型, 如果这个类型是 `String`, 这个方法返回XElement里的值. 否则, 它返回 `false`. 返回 `false` 意味着语言(运行时)需要决定接下来做什么(在大部门情况下, 这意味着你将会获得一个运行时异常.) (Alan: 在这里的意思就是如果你要将节点转换成不是 `String` 类型的其他类型, 会抛出异常.)


The last thing I’m going to show is how to get access to the XElement methods. Let’s override the TryInvokeMember method so that it will redirect all the method calls to its XElement object. Of course, I’m using the System.Reflection namespace here.

最后我将展示如果访问 `XElement` 方法. 我们现在重写 `TryInvokeMember` 方法, 这将会把所有的方法调用重定向到 `XElement` 对象上. 当然, 这里我需要使用 `System.Reflection` 命名空间.


	public override bool TryInvokeMember(InvokeMemberBinder binder, object[] args, out object result)
	{
	    Type xmlType = typeof(XElement);
	    try
	    {
	        result = xmlType.InvokeMember(
	                  binder.Name,
	                  BindingFlags.InvokeMethod |
	                  BindingFlags.Public |
	                  BindingFlags.Instance,
	                  null, node, args);
	        return true;
	    }
	    catch
	    {
	        result = null;
	        return false;
	    }
	}


This method enables you to call XElement methods on any node of the DynamicXMLNode object. The most obvious drawback here is absence of IntelliSense.

这个方法允许你在 `DynamicXMLNode` 对象上调用 `XElement` 的所有方法. 这里最大的缺点是缺少智能感知.


I’m not even going to pretend that this example is a ready-to-use wrapper for the LINQ to XML library. It doesn’t support attributes, doesn’t allow you to create a collection of nodes (for example, multiple contacts), and it is probably missing other features. Creating a library is a difficult task, and creating a good wrapper is too. But I hope that after reading this blog post you can create a fully functioning wrapper with DynamicObject yourself.

我没有打算将这个例子编程一个对 LINQ to XML 包装的类库. 这里不支持属性, 不允许你创建集合节点(比如, 多个联系人), 而且它可能缺失了其他的特性. 创建一个类库是一个艰难的任务, 一个好的包装器也是如此. 但是我希望阅读完这篇博文, 你可以自己创建一个完全的功能的 `DynamicObject` 包装器.

--end

So, if you routinely use a library with complicated syntax that crawls XML files or works with script objects, or if you are creating such a library yourself, you should probably consider writing a wrapper. Doing this might make you more productive and the syntax of your library much better.

All the examples provided in this blog post work in the just released Visual Studio 2010 Beta 2. If you have any comments or suggestions, you are welcome to post them here or contact the DLR team at http://www.codeplex.com/dlr. You can also send an e-mail to the DLR team at dlr@microsoft.com.

Documentation for DynamicObject is also available on MSDN (check out our new MSDN design and don’t forget to take a look at the lightweight view.) In documentation, you can read about other useful methods of this class, such as TryBinaryOperation, TryUnaryOperation, TrySetIndex, and TryGetIndex.


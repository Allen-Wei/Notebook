
# 反射获取`dynamic`类型的属性值

## Type.GetProperties()

通常使用 `obj.GetType().GetProperties()`来反射对象

	obj.GetType().GetProperties().ToList().ForEach(p => Console.WriteLine("{0}: {1}", p.Name, p.GetValue(obj, null)));

## PropertyDescriptor.GetProperties(obj)

现在可以使用 `PropertyDescriptor.GetProperties(obj)` 来反射获取对象的属性

	dynamic dict = new { FirstName = "Alan", LastName = "Wei" };
    foreach (PropertyDescriptor p in TypeDescriptor.GetProperties(dict))
    {
		Console.WriteLine("{0} {1} {2}", p.DisplayName, p.PropertyType.Name, p.GetValue(dict));
    }

如果类型不是`dynamic`, `PropertyDescriptor.GetProperties(obj)` 也可以采用 `obj.GetType().GetProperties()` 的写法:

	TypeDescriptor.GetProperties(obj).OfType<PropertyDescriptor>().ToList().ForEach(p => Console.WriteLine("{0} {1} {2}", p.DisplayName, p.PropertyType.Name, p.GetValue(obj)));


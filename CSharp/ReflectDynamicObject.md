
# �����ȡ`dynamic`���͵�����ֵ

## Type.GetProperties()

ͨ��ʹ�� `obj.GetType().GetProperties()`���������

	obj.GetType().GetProperties().ToList().ForEach(p => Console.WriteLine("{0}: {1}", p.Name, p.GetValue(obj, null)));

## PropertyDescriptor.GetProperties(obj)

���ڿ���ʹ�� `PropertyDescriptor.GetProperties(obj)` �������ȡ���������

	dynamic dict = new { FirstName = "Alan", LastName = "Wei" };
    foreach (PropertyDescriptor p in TypeDescriptor.GetProperties(dict))
    {
		Console.WriteLine("{0} {1} {2}", p.DisplayName, p.PropertyType.Name, p.GetValue(dict));
    }

������Ͳ���`dynamic`, `PropertyDescriptor.GetProperties(obj)` Ҳ���Բ��� `obj.GetType().GetProperties()` ��д��:

	TypeDescriptor.GetProperties(obj).OfType<PropertyDescriptor>().ToList().ForEach(p => Console.WriteLine("{0} {1} {2}", p.DisplayName, p.PropertyType.Name, p.GetValue(obj)));


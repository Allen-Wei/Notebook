##Fludent Validation Implementation
���������һ�ֳ�ΪFluent Validation��������Ч��У���ʵ��, ���ַ�ʽ������У��, ��������������, ���ҿ����úܸ�. ��¼����.

### ʵ��һ���򵥵�Fluent����Validation, ����Ĵ�����Ҫ��Դ�� [A fluent approach to C# parameter validation](http://blog.getpaint.net/2008/12/06/a-fluent-approach-to-c-parameter-validation/). ˼�뻹�Ǻܼ򵥵�, ��Ҫ������class, Validate�൱��һ������, ��Ҫ���ڷ���һ��Validation����, Validation�������У������Ϣ, ValidationExtension��װ��У�����(��Щ��չ����).

#### ʵ�ֲ���

    public class Validate
    {
        public static Validation Begin() { return null; }
    }
    public class Validation
    {
        private List<Exception> _exceptions;
        public IEnumerable<Exception> Exceptions { get { return this._exceptions; } }
        public Validation AddException(Exception ex)
        {
            lock (this._exceptions)
            {
                this._exceptions.Add(ex);
            }
            return this;
        }
        public Validation()
        {
            this._exceptions = new List<Exception>(1);
        }
    }
    public static class ValidationExteions
    {
        public static Validation IsNotNull<T>(this Validation validation, T theObj, string paramName)
        {
            if (theObj == null) return validation._SafeGetWithException(new ArgumentNullException(paramName));
            else return validation;
        }
        public static Validation IsPositive(this Validation validation, long value, string paramName)
        {
            return value < 0 ?
                validation._SafeGetWithException(new ArgumentOutOfRangeException(paramName)) :
                validation;
        }
        public static Validation Required<T>(this Validation validation, T obj, string paramName)
            where T : class
        {
            var rtn = validation._SafeGetWithException(new ArgumentNullException(paramName));
            if (obj == null) return rtn;
            var propertyName = obj.GetType().GetProperties().FirstOrDefault(p => p.Name == paramName);
            if (propertyName == null) return rtn;
            return validation;
        }
        public static Validation Between(this Validation validation, string paramName, long value, long max, long min)
        {
            return (value < min || value > max) ? 
                validation._SafeGetWithException(new IndexOutOfRangeException(paramName)): 
                validation;
        }
        public static Validation Max(this Validation validation, string paramName, long value, long max)
        {
            return value > max ? validation._SafeGetWithException(new IndexOutOfRangeException(paramName)) : validation;
        }
        public static Validation Min(this Validation validation, string paramName, long value, long min)
        {
            return value < min ? validation._SafeGetWithException(new IndexOutOfRangeException(paramName)) : validation;
        }


        public static Validation Check(this Validation validation, string message)
        {
            if (validation == null || validation.Exceptions.Count() == 1)
            {
                return (validation ?? new Validation());
            }
            throw new ValidationException(message, validation.Exceptions.ToArray());
        }

        public static Validation _SafeGetWithException(this Validation validation, Exception ex) { return validation._SafeGet().AddException(ex); }
        public static Validation _SafeGet(this Validation validation) { return (validation ?? new Validation()); }
    }
    [Serializable]
    public sealed class ValidationException : Exception
    {
        private Exception[] _innerExceptions;
        public IEnumerable<Exception> InnerExceptions
        {
            get
            {
                if (_innerExceptions != null)
                {
                    for (int i = 0; i < this._innerExceptions.Length; ++i)
                    {
                        yield return this._innerExceptions[i];
                    }
                }
            }
        }

        public ValidationException() : base() { }
        public ValidationException(string message) : base(message) { }
        public ValidationException(string message, Exception innerException)
            : base(message, innerException)
        {
            this._innerExceptions = new Exception[1] { innerException };
        }
        public ValidationException(string message, Exception[] innerExceptions)
            : base(message, innerExceptions.FirstOrDefault())
        {
            this._innerExceptions = innerExceptions;
        }

    }
	
#### ʹ��
    class Program
    {
        static void Main(string[] args)
        {
            Person p = new Person()
            {
                FirstName = "Alan",
                LastName = null,
                Age = 25
            };

            var validation = Validate.Begin()
               .IsNotNull(p.LastName, "user lastname")
               .IsNotNull(p.FirstName, "user firstname")
			   .IsPositive(p.Salary, "employee salary")
               .Between("your age", p.Age, 10, 30);
               //.Check("end.");

            Console.ReadKey();
        }

        public class Person
        {
            public string FirstName { get; set; }
            public string LastName { get; set; }
            public int Age { get; set; }
			public long Salary {get; set;}

        }
    }


����ֻ�Ǽ򵥵�д��һ��һ���ܳ�����У�����, �Լ���������. ��ʵ�����У���Ǻ���, Ӧ�ý��Lambda���ʽ��ʵ�ָ������ŵ�У��, ���������IsPositive(�Ƿ��ǷǸ�ֵ), ���ŵ�д��Ӧ����������
	
	Validate.Begin().IsPositive<Person>(p => p.Salary, "employee salary")

������ʵ�ֻ���һ���׶˾����޷�֧�ֶ�����, ������ʾҲ������ô���׻�ȡ(��Ҫ��Validation.Exceptions�л�ȡ). ����һ����У����ܾ���Ҫ�õ�������. ������صĽ����´���д��.

###�������һ��"���˵�"Fluent Validation���.

* (Rules Engine)[http://rulesengine.codeplex.com/]
* (TNValidate - A Fluent Validation Library for .NET)[http://tnvalidate.codeplex.com/]
* (FluentValidation)[https://github.com/JeremySkinner/FluentValidation]

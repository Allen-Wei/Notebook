##Fludent Validation Implementation
最近看到了一种称为Fluent Validation的数据有效性校验的实践, 这种方式的数据校验, 看起来更加清晰, 而且可重用很高. 记录如下.

### 实现一个简单的Fluent风格的Validation, 下面的代码主要来源于 [A fluent approach to C# parameter validation](http://blog.getpaint.net/2008/12/06/a-fluent-approach-to-c-parameter-validation/). 思想还是很简单的, 主要有三个class, Validate相当于一个工厂, 主要用于分配一个Validation对象, Validation类包含了校验结果信息, ValidationExtension封装了校验规则(那些扩展方法).

#### 实现部分

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
	
#### 使用
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


上面只是简单的写了一下一个很常见的校验规则, 自己可以扩充. 其实上面的校验是很弱, 应该结合Lambda表达式来实现更加优雅的校验, 比如上面的IsPositive(是否是非负值), 优雅的写法应该是这样的
	
	Validate.Begin().IsPositive<Person>(p => p.Salary, "employee salary")

上述的实现还有一个弊端就是无法支持多语言, 错误提示也不是那么容易获取(需要从Validation.Exceptions中获取). 更进一步的校验可能就需要用到反射了. 反射相关的介绍下次再写吧.

###下面介绍一个"别人的"Fluent Validation类库.

* (Rules Engine)[http://rulesengine.codeplex.com/]
* (TNValidate - A Fluent Validation Library for .NET)[http://tnvalidate.codeplex.com/]
* (FluentValidation)[https://github.com/JeremySkinner/FluentValidation]

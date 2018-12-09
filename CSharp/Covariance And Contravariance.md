


## 协变性(Covariance)和逆变性(Contravariance)

可变性只能用于接口和泛型.
out 输出参数代表逆变性, in 输入参数代表协变性.

    public static void Run()
    {
        Child c = new Child();
        Contravariance<Child> contra = null;
        Parent p = contra.Output();

        Convariance<Parent> convar = null;
        convar.Print(c);
    }

    public interface Contravariance<out TOut>
    {
        TOut Output();
    }

    public interface Convariance<in TIn>
    {
        void Print(TIn var);
    }

    public class Parent { }
    public class Child : Parent { }

可变性实际上是类型的隐式转换.

对于高阶函数(嵌套委托, 参数包含其他委托), 可以认为内嵌的逆变性反转了之前的可变性, 而协变性不会如此. 因此 `Action<Action<T>>` 对T来说是协变的, `Action<Action<Action<T>>>` 是逆变的. 相比之下, 对于 `Func<T>` 的可变性来说, 你可以编写 `Func<Func<Func<... Func<T>...>>>`, 嵌套任意多个级别, 得到的仍然是协变性. 协变性很好理解, 对于逆变性反转之前的可变性, 是因为一个逆变性的委托(out输出)会返回一个输出类型作为他的使用者(将它作为参数的委托)的一个输入参数, 所以对于 `Action<Action<T>>` 实际上的效果是 `Action<in Action<out T>>`


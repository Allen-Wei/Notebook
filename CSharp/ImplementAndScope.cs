namespace ConsoleApp
{
    class Program
    {
        static void Main(string[] args)
        {
            B b = new B();
            A.F(b);
        }


        public class A
        {
            private int x;
            public static void F(B b)
            {
                b.x = 10;
            }
            public class Inner { }
        }
        public class B : A
        {
            public new static void F(B b) { }
        }
    }
}


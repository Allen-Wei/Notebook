
## 2016-02-05 14:28:21

Asp.Net Web �����м�¼������־, ���� Web Forms �� MVC ���ּܹ�, ��¼ȫ�ֵĴ�����Ϣ��Ҫ��ȡ��ͬ��ʽ.
���� Web Forms ����, ������ `Global.asax` ����� ���´���:

	protected void Application_Error(object sender, EventArgs e)
	{
		var app = sender as HttpApplication;
		var ex = app.Server.GetLastError();
	}

����ע��һ�� `IHttpModule`, ���� `Error` �¼�:

    public class MyModule : IHttpModule
    {
        public void Dispose() { }

        public void Init(HttpApplication context)
        {
            context.Error += context_Error;
        }

        void context_Error(object sender, EventArgs e)
        {
            var app = sender as HttpApplication;
			var ex = app.Server.GetLastError();
        }
    }


����MVC����, ��Ҫע��һ��������

    public class MyExceptionFilter : System.Web.Http.Filters.ExceptionFilterAttribute
    {
        public override void OnException(System.Web.Http.Filters.HttpActionExecutedContext actionExecutedContext)
        {
            var ex = actionExecutedContext.Exception;
        }
    }

Ȼ�����ӵ�ȫ�ֹ�����:

    public class WebApiApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            GlobalConfiguration.Configure(WebApiConfig.Register);
            GlobalConfiguration.Configuration.Filters.Add(new MyExceptionFilter());
        }
    }


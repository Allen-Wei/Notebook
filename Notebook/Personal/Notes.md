
## 2016-02-05 14:28:21

Asp.Net Web 开发中记录错误日志, 对于 Web Forms 和 MVC 两种架构, 记录全局的错误消息需要采取不同方式.
对于 Web Forms 程序, 可以在 `Global.asax` 中添加 如下代码:

	protected void Application_Error(object sender, EventArgs e)
	{
		var app = sender as HttpApplication;
		var ex = app.Server.GetLastError();
	}

或者注册一个 `IHttpModule`, 监听 `Error` 事件:

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


对于MVC程序, 需要注册一个过滤器

    public class MyExceptionFilter : System.Web.Http.Filters.ExceptionFilterAttribute
    {
        public override void OnException(System.Web.Http.Filters.HttpActionExecutedContext actionExecutedContext)
        {
            var ex = actionExecutedContext.Exception;
        }
    }

然后给添加到全局过滤器:

    public class WebApiApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            GlobalConfiguration.Configure(WebApiConfig.Register);
            GlobalConfiguration.Configuration.Filters.Add(new MyExceptionFilter());
        }
    }


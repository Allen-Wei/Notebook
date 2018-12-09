##获取网站所有的Controllers

### 1: 继承
写一个基类 `BaseController`, 基类里定义一个公共的无参构造函数:  

	public class BaseController : Controller
    {
        public BaseController()
        {
			//在这里获取客户端请求的路径
            var requestPath = System.Web.HttpContext.Current.Request.CurrentExecutionFilePath;	
        }
    }


然后所有的Controller都继承它:

	public class ProjectController : BaseController
    {
        public ActionResult Index()
        {
            return View();
        }
    }
	
在 `BaseControl` 的无参构造函数里通过 `System.Web.HttpContext.Current.Request.CurrentExecutionFilePath` 获取执行路径, 然后基于此判断请求的Controller.
然后收集起来, 存储到一个集合里.

### 2: 反射

via: http://stackoverflow.com/questions/21583278/getting-all-controllers-and-actions-names-in-c-sharp

	Assembly.GetExecutingAssembly().GetTypes().Where(t => typeof(Controller).IsAssignableFrom(t)).Select(t => t.Name).ToList()

可以通过反射获取所有的Controller. 把上面的代码写到 `Global.asax` 的 `Application_Start` 里, 就可以获取所有的Controller了.


### 3: 全局过滤器

写一个过滤器: 

    public class LogActionFilterAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            base.OnActionExecuting(filterContext);
            var ctrlName = filterContext.Controller.GetType().Name;
        }
    }

在 `Global.asax` 的 `Application_Start` 里注册全局过滤器:

	GlobalFilters.Filters.Add(new LogActionFilterAttribute())

这样每一次请求过滤器都会被执行.


### Summary

第二种反射的方法最好, 因为另外两种都有两个个缺陷: 每次请求Controller都要执行一次, 还有只有请求了Controller, BaseController和过滤器才执行, 也就是说如果网站有HomeController和ProjectController两个Controller, 用户永远不请求ProjectController的话, 第一种和第三种方法永远不知道ProjectController的存在.

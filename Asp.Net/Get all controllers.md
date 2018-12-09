##��ȡ��վ���е�Controllers

### 1: �̳�
дһ������ `BaseController`, �����ﶨ��һ���������޲ι��캯��:  

	public class BaseController : Controller
    {
        public BaseController()
        {
			//�������ȡ�ͻ��������·��
            var requestPath = System.Web.HttpContext.Current.Request.CurrentExecutionFilePath;	
        }
    }


Ȼ�����е�Controller���̳���:

	public class ProjectController : BaseController
    {
        public ActionResult Index()
        {
            return View();
        }
    }
	
�� `BaseControl` ���޲ι��캯����ͨ�� `System.Web.HttpContext.Current.Request.CurrentExecutionFilePath` ��ȡִ��·��, Ȼ����ڴ��ж������Controller.
Ȼ���ռ�����, �洢��һ��������.

### 2: ����

via: http://stackoverflow.com/questions/21583278/getting-all-controllers-and-actions-names-in-c-sharp

	Assembly.GetExecutingAssembly().GetTypes().Where(t => typeof(Controller).IsAssignableFrom(t)).Select(t => t.Name).ToList()

����ͨ�������ȡ���е�Controller. ������Ĵ���д�� `Global.asax` �� `Application_Start` ��, �Ϳ��Ի�ȡ���е�Controller��.


### 3: ȫ�ֹ�����

дһ��������: 

    public class LogActionFilterAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            base.OnActionExecuting(filterContext);
            var ctrlName = filterContext.Controller.GetType().Name;
        }
    }

�� `Global.asax` �� `Application_Start` ��ע��ȫ�ֹ�����:

	GlobalFilters.Filters.Add(new LogActionFilterAttribute())

����ÿһ��������������ᱻִ��.


### Summary

�ڶ��ַ���ķ������, ��Ϊ�������ֶ���������ȱ��: ÿ������Controller��Ҫִ��һ��, ����ֻ��������Controller, BaseController�͹�������ִ��, Ҳ����˵�����վ��HomeController��ProjectController����Controller, �û���Զ������ProjectController�Ļ�, ��һ�ֺ͵����ַ�����Զ��֪��ProjectController�Ĵ���.


<html>
</html>
JavaScript
 
1. 利用原型继承使得 `Student` 继承 `People` 的属性和方法. (原型继承在信销系统 `YsdCredit\YSD_Credit\Scripts\Services\service.Utils.js`利用到.)

	function People(fn, ln){
		this.firstName = fn;
		this.lastName = ln;
		this.getFullName = function(){
			return this.firstName + " " + this.lastName;
		};
	}

	function Student(){ }


	//原型继承

	Student.prototype = new People("Alan", "Wei");
	Student.prototype.constructor = Student;



2. 关于JavaScript的`this`和闭包: 

	var scope = function(){
		this.print = function(ele){
			console.info(ele);
		};

		this.iteral = function(){
			$.each(["Alan", "Allen", "Tom", "Lucy"], function(index, name){
				//在这里如果调用 `this.print` 方法 ?
			});
		};
	};

这个解决方式有好几种, 描述一个简单的方式:

	this.iteral = function(){
		var context = this;
		$.each(...., function(index, name)({
			//在这里直接使用 `this.print` 是不正确的.
			context.print(name);
		});
	}

其他方式参考[这里](https://github.com/Allen-Wei/GitBlog/blob/master/JavaScript/About_Closure.md)。


3. 为什么下面代码无法正确打印出名字列表? 在`setTimeout`的回调函数里如何正确地打印出名字列表? 

	var names = ["Alan", "Allen", "Annr"];
	for(var i = 0; i < names.length; i++){
		setTimeout(function(){
			console.log(names[i]);
		});
	}

	//利用闭包可以解决这个问题: 
	var names = ["Alan", "Allen", "Annr"];
	for(var i = 0; i < names.length; i++){
		(function(name){
			setTimeout(function(){
				console.log(name);
			});
		})(names[i]);
	}


4. 利用原生JS写一个Ajax请求. 
	
ajax([引用](https://developer.mozilla.org/en-US/docs/AJAX/Getting_Started)): 

	var ajax = function(method, url, contentType, data, success, fail){
		var xhr = new XMLHTTPRequest();
		xhr.oepn(method, url);
		xhr.setRequestHeader("Content-Type", "application/json");
		xhr.onreadystatechange = function(){
			if(xhr.readyState === 4 && xhr.status === 200){
				success(xhr.responseText);
			}else{
				fail();
			}
		};
		xhr.send(data);
	}


5. 简述jQuery的Promise实现中`$.when`, `deferred.pipe`几个方法的用途, 并将上述用原生JS写的ajax方法用jQuery的Promise(`$.Deferred`)进行封装.

`$.when(promise1, promise2, promise3, ...)` when函数的每一个参数都是一个 `$.Deffered` 对象, 只有当所有的deffered都成功时, `$.when`返回的deferred对象才成功.
`defered.pipe` jQuery的deffered对象的管道连接, 依次执行. `$.when`是并行执行, `deferred.pip` 是依次顺序执行.

利用jQuery的Promise实现`ajax()`封装: 

	var ajaxDeferred = function(method, url, contentType, data){

		var deferred = $.Deferred();

		ajax(method, url, contentType, data, function(data){
			deferred.resolve(data);
		}, function(){
			deferred.reject();
		});

		return deferred.promise();
		
	}

## CSharp

1. 如何在全局记录Web API的异常信息? 如何在全局记录Web Forms网站的异常信息?

记录Web API的异常信息需要继承 `ExceptionFilterAttribute` 或者 `IExceptionFilter`. 之后需要注册全局过滤器

	GlobalConfiguration.Configuration.Filters.Add(...)

信销系统 `YsdCredit\Ysd.ApplicationInterface\Library\YsdWebApiExceptionFilter.cs` 就是一个异常消息过滤器, `YsdCredit\Ysd.ApplicationInterface\App_Start\WebApiConfig.cs` 注册了一个全局过滤器.

Web Forms网站的记录全局的异常消息需要借助 HTTP Module, 信销系统 `YsdCredit\Ysd.BusinessLogicLayer\Library\CommonHttpModule.cs` 的 `content_Error` 就注册了监听了网站的异常信息.
HTTP Module需要在 `web.config` 里配置才能生效.

2. 如何在网站里实现认证模块?

可以监听 HTTP Module 的 `AuthenticateRequest` 事件, 修改 `app.Context.User` 来实现, 可以参考[这里](https://github.com/Allen-Wei/Alan.Authentication.Old/blob/master/Alan.Authentication/AuthModule.cs). 信息系统里的认证模块就是使用这种方式.

对于 MVC 和 Web API 项目可以通过继承 `AuthorizationFilterAttribute` 或者实现 `IAuthenticationFilter` 来实现.



## 14 HttpClient
## 14.2 客户端消息处理程序

```csharp
HttpClient client = new HttpClient(new MyHandler());
HttpResponseMessage response = await client.GetAsync("http://www.ietf.org/rfc/rfc2616.txt");
String data = await response.Content.ReadAsStringAsync();

public class MyHandler : DelegatingHandler
{
    protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        //在这里可以对 request 和 response 做一些自定义处理
        this.InnerHandler = new HttpClientHandler();
        HttpResponseMessage response = await base.SendAsync(request, cancellationToken).ConfigureAwait(false);
        return response;
    }
}
```

# 15 安全
## 15.3 身份验证
### 15.3.1　声明模型 

.NET 框架也提供 IPrincipal 和 IIdentity 接口的一组具体实现: 
* GenericPrincipal, WindowsPrincipal 和 RolePrincipal 类实现了 IPrincipal 接口
* GenericIdentity, WindowsIdentity 和 FormsIdentity 类实现了 IIdentity 接口

在 ASP.NET Web API 1.0 中, 托管方式决定了应该如何在消息处理程序管道中设置当前用 户对象. 如果你使用的是自托管, 给 Thread.CurrentPrincipal 赋值即可. 但是, 如果使用 的是 Web 托管, 你必须给 Thread.CurrentPrincipal 和 HttpContext.Current.User 都赋值.  一个常用的技巧是检查 HttpContext.Current 不为 null: 

```csharp
IIdentity identity = new GenericIdentity("alan", "Base");
IPrincipal principal = new GenericPrincipal(identity, new[] { "Admin" });
Thread.CurrentPrincipal = principal;
if (HttpContext.Current != null)
{
    HttpContext.Current.User = principal ;
}
```

在 ASP.NET Web API 2.0 中, 你可以使用新的 HttpRequestContext 类, 解决这一问题. 首先, 你必须获得当前用户对象, 将其赋给当前的请求对象, 而不是设置静态属性. 其次,  不同的托管方式可以使用不同的 HttpRequestContext 实现: 
* 自托管使用 SelfHostHttpRequestContext, 直接给 Thread.CurrentPrincipal 属性赋值; 
* Web 托管使用 WebHostHttpRequestContext, 给 Thread.CurrentPrincipal 和 HttpContext. Current.User 属性都赋值; 
* OWIN 托管使用 OwinHttpRequestContext, 给 Thread.CurrentPrincipal 和当前的 OWIN 上下文对象赋值. 

### 15.3.7 实现基于HTTP的身份验证 

实现身份验证可以使用 Web API 消息处理程序, 也可以使用 Web API 筛选器, 在管道中实现身份验证, 或者在托管层进行身份验证.

如果在 Web API 筛选器上实现身份验证, 你可以访问更多的请求信息, 其中有: 

* 所选的控制器和路由
* 路由参数
* 操作参数(如果使用操作筛选)

如果你的身份验证逻辑依赖这些信息, 就可以使用 Web API 筛选器实现身份验证. 而且,  Web API 筛选器还可以选择性地应用于一部分控制器或者操作. 
但是, 在筛选器层进行身份验证也有一些很严重的缺点: 

* 在管道后端才能检测到未经认证的请求, 增加了拒绝请求的计算开销. 
* 在管道后端才能使用请求者的身份信息. 这意味着其他的中间层组件, 如缓存中间件, 可能无法访问这些身份信息. 如果使用私有缓存(即: 按用户进行缓存), 那么这种方式会产生严重的限制. 

另外一个选项是, 在消息处理程序层实现身份验证功能, 我们之前就是使用的这种方式.  消息处理程序在托管适配层之后立刻运行, 因此拒绝请求的开销会比较小. 而且, 之后的 所有处理程序都可以使用请求者的身份信息. 如果你使用 HttpClient, 消息处理程序在客 户端也可使用, 因此这种方式使得系统呈现一种有趣的对称性. 

 

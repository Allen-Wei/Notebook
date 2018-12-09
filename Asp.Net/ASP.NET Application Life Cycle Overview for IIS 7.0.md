# ASP.NET Application Life Cycle Overview for IIS 7.0

[原文](https://msdn.microsoft.com/en-us/library/bb470252.aspx)

## Architectural Overview 

A request in IIS 7.0 Integrated mode passes through stages that are like the stages of requests for ASP.NET resources in IIS 6.0. However, in IIS 7.0, these stages include several additional application events, such as the MapRequestHandler, LogRequest, and PostLogRequest events. 

The main difference in processing stages between IIS 7.0 and IIS 6.0 is in how ASP.NET is integrated with the IIS server. In IIS 6.0, there are two request processing pipelines. One pipeline is for native-code ISAPI filters and extension components. The other pipeline is for managed-code application components such as ASP.NET. In IIS 7.0, the ASP.NET runtime is integrated with the Web server so that there is one unified request processing pipeline for all requests. For ASP.NET developers, the benefits of the integrated pipeline are as follows:

* The integrated pipeline raises all the events that are exposed by the HttpApplication object, which enables existing ASP.NET HTTP modules to work in IIS 7.0 Integrated mode.
* Both native-code and managed-code modules can be configured at the Web server, Web site, or Web application level. This includes the built-in ASP.NET managed-code modules for session state, forms authentication, profiles, and role management. Furthermore, managed-code modules can be enabled or disabled for all requests, regardless of whether the request is for an ASP.NET resource like an .aspx file.
* Managed-code modules can be invoked at any stage in the pipeline. This includes before any server processing occurs for the request, after all server processing has occurred, or anywhere in between.
* You can register and enable or disable modules through an application’s Web.config file. 

The following illustration shows the configuration of an application's request pipeline. The example includes the following:

* The Anonymous native-code module and the Forms managed-code module (which corresponds to FormsAuthenticationModule). These modules are configured, and they are invoked during the Authentication stage of the request.
* The Basic native-code module and the Windows managed-code module (which corresponds to WindowsAuthenticationModule). They are shown, but they are not configured for the application.
* The Execute handler stage, where the handler (a module scoped to a URL) is invoked to construct the response. For .aspx files, the PageHandlerFactory handler is used to respond to the request. For static files, the native-code StaticFileModule module responds to the request. 
* The Trace native-code module. This is shown, but it is not configured for the application.
* The Custom module managed-code class. It is invoked during the Log request stage. 

![Request Pipeline in IIS 7.0](https://i-msdn.sec.s-msft.com/dynimg/IC142724.png)

For information about known compatibility issues with ASP.NET applications that are being migrated from earlier versions of IIS to IIS 7.0, see the "Known Differences Between Integrated Mode and Classic Mode" section of Upgrading ASP.NET Applications to IIS 7.0: Differences between IIS 7.0 Integrated Mode and Classic mode.

## Life Cycle Stages 

The following table lists the stages of the ASP.NET application life cycle with Integrated mode in IIS 7.0.

### Stage: A request is made for an application resource.

The life cycle of an ASP.NET application starts with a request sent by a browser to the Web server. 

In Classic mode in IIS 7.0 and in IIS 6.0, the ASP.NET request pipeline is separate from the Web server pipeline. Modules apply only to requests that are routed to the ASP.NET ISAPI extension. If the file-name extension of the requested resource type is not explicitly mapped to ASP.NET, ASP.NET functionality is not invoked for the request because the request is not processed by the ASP.NET runtime.

In integrated mode in IIS 7.0, a unified pipeline handles all requests. When the integrated pipeline receives a request, the request passes through stages that are common to all requests. These stages are represented by the RequestNotification enumeration. All requests can be configured to take advantage of ASP.NET functionality, because that functionality is encapsulated in managed-code modules that have access to the request pipeline. For example, even though the .htm file-name extension is not explicitly mapped to ASP.NET, a request for an HTML page still invokes ASP.NET modules. This enables you to take advantage of ASP.NET authentication and authorization for all resources.

### Stage: The unified pipeline receives the first request for the application.

When the unified pipeline receives the first request for any resource in an application, an instance of the ApplicationManager class is created, which is the application domain that the request is processed in. Application domains provide isolation between applications for global variables and enable each application to be unloaded separately. In the application domain, an instance of the HostingEnvironment class is created, which provides access to information about the application, such as the name of the folder where the application is stored. 

During the first request, top-level items in the application are compiled if required, which includes application code in the App_Code folder. You can include custom modules and handlers in the App_Code folder as described in Managed-code Modules in IIS 7.0 later in this topic.

### Response objects are created for each request.

After the application domain has been created and the HostingEnvironment object has been instantiated, application objects such as HttpContext, HttpRequest, and HttpResponse are created and initialized. The HttpContext class contains objects that are specific to the current application request, such as the HttpRequest and HttpResponse objects. The HttpRequest object contains information about the current request, which includes cookies and browser information. The HttpResponse object contains the response that is sent to the client, which includes all the rendered output and cookies.

The following are some key differences between IIS 6.0 and IIS 7.0 running in Integrated mode and with the .NET Framework 3.0 or later:

* The SubStatusCode property of the HttpResponse object is available for setting codes that are useful for failed-request tracing. For more information, see Troubleshooting Failed Requests Using Failed Request Tracing in IIS 7.0.
* The Headers property of the HttpResponse object provides access to response headers for the response.
* Two properties of the HttpContext object, IsPostNotification and CurrentNotification, are used when one event handler handles several HttpApplication events.
* The Headers and ServerVariables property of the HttpRequest object are write-enabled.

### An HttpApplication object is assigned to the request

After all application objects have been initialized, the application is started by creating an instance of the HttpApplication class. If the application has a Global.asax file, ASP.NET instead creates an instance of the Global.asax class that is derived from the HttpApplication class. It then uses the derived class to represent the application.

Which ASP.NET modules are loaded (such as the SessionStateModule) depends on the managed-code modules that the application inherits from a parent application. It also depends on which modules are configured in the configuration section of the application's Web.config file. Modules are added or removed in the application's Web.config modules element in the system.webServer section. For more information, see How to: Configure the [`<system.webServer>`](https://msdn.microsoft.com/en-us/library/bb763179.aspx) Section for IIS 7.0. 

### The request is processed by the HttpApplication pipeline.

The following tasks are performed by the HttpApplication class while the request is being processed. The events are useful for page developers who want to run code when key request pipeline events are raised. They are also useful if you are developing a custom module and you want the module to be invoked for all requests to the pipeline. Custom modules implement the IHttpModule interface. In Integrated mode in IIS 7.0, you must register event handlers in a module's Init method.

0. Validate the request, which examines the information sent by the browser and determines whether it contains potentially malicious markup. For more information, see ValidateRequest and Script Exploits Overview.
0. Perform URL mapping, if any URLs have been configured in the UrlMappingsSection section of the Web.config file.
0. Raise the BeginRequest event.
0. Raise the AuthenticateRequest event.
0. Raise the PostAuthenticateRequest event.
0. Raise the AuthorizeRequest event.
0. Raise the PostAuthorizeRequest event.
0. Raise the ResolveRequestCache event.
0. Raise the PostResolveRequestCache event.
0. Raise the MapRequestHandler event. An appropriate handler is selected based on the file-name extension of the requested resource. The handler can be a native-code module such as the IIS 7.0 StaticFileModule or a managed-code module such as the PageHandlerFactory class (which handles .aspx files). 
0. Raise the PostMapRequestHandler event.
0. Raise the AcquireRequestState event.
0. Raise the PostAcquireRequestState event.
0. Raise the PreRequestHandlerExecute event.
0. Call the ProcessRequest method (or the asynchronous version IHttpAsyncHandler.BeginProcessRequest) of the appropriate IHttpHandler class for the request. For example, if the request is for a page, the current page instance handles the request. 
0. Raise the PostRequestHandlerExecute event.
0. Raise the ReleaseRequestState event.
0. Raise the PostReleaseRequestState event.
0. Perform response filtering if the Filter property is defined.
0. Raise the UpdateRequestCache event.
0. Raise the PostUpdateRequestCache event.
0. Raise the LogRequest event.
0. Raise the PostLogRequest event.
0. Raise the EndRequest event.
0. Raise the PreSendRequestHeaders event.
0. Raise the PreSendRequestContent event.


    The MapRequestHandler, LogRequest, and PostLogRequest events are supported only if the application is running in Integrated mode in IIS 7.0 and with the .NET Framework 3.0 or later.
# ASP.Net 身份模块介绍

[原文](http://www.asp.net/identity/overview/getting-started/introduction-to-aspnet-identity)

### 前言(Preface)

ASP.Net 会员系统在2005年发布ASP.Net 2.0的时候同时发布(介绍), 而且从那以后Web应用在处理认证和授权方面已经发生了很多改变.对于会员系统应该是什么样子的, ASP.Net Identity是一个新的尝试, 当你为Web, Phone, Tablet(平板)创建现代应用的时候.
这篇文章是由Pranav Rastogi, Jon Galloway, Tom Dykstra, and Rick Anderson所写.


## 背景: ASP.Net会员系统(ASP.Net Membership)

在2005年, 为了解决大部分网站对会员功能的需求, ASP.Net Membership被设计出来, 它需要表单认证和包含用户名,密码和个人信息的SQL Server数据库. 现在对于Web应用, 有更加广泛(broader)的可供选择数据存储方式, 而且大部分开发者想使他们的站点使用社交登录来提供认证和授权功能. 下面介绍的ASP.Net Membership的设计限制使上述的需求实现变得很困难:

* 数据库架构被设计成使用SQL Server, 而且你不可以改变. 你可以添加配置信息, 但是其他数据被放在了其他表中, 使用任何手段(means)访问这些信息都是困难的, 除非通过Profile Provider API(配置提供器API).
* 提供器系统能够让你改变背后的数据存储方式, 但是系统被设计成假设你使用的是关系型数据库. 你可以实现在非关系型存储机制存储会员信息的提供器, 比如 Azure Storage Tables, 但是之后你就不得不围绕着关系型设计来写大量的代码, 而且对于不适用于非关系型数据库的方法需要写大量的System.NotImplementationException异常抛出.
* 自从登陆/登出功能是基于表单认证的, 会员系统就不能够使用OWIN, OWIN包含了对于认证的中间件, 也包括了对于外部身份系统(像Micrsoft Account, Facebook, Google, Twitter)登陆的支持, 而且log-ins可以从活动目录或者Azure活动目录使用组织账号. OWIN也包括了对于OAuth 2.0， JWT(JSON Web Token)和CORS(Corss Origin Request Source)的支持.  (Alan: [Using JWT to implement Authentication on Asp.net web api](http://stackoverflow.com/questions/23674613/using-jwt-to-implement-authentication-on-asp-net-web-api))

### ASP.Net Simple Membership

ASP.net simple membership 被开发成ASP.Net Web Pages的会员系统. 它随同WebMatrix和Visual Studio 2010 SP1一起发布. Simple Membership的目标是使Web Pages应用添加会员功能更加容易.
Simple Membership 使自定义用户配置信息更加容易, 但是在和ASP.Net Membership共享(Alan: 应该是共存的意思)有一些其他问题, 而且有一些限制:

* 很难在非关系型数据存储中持久化会员系统.
* 你不可以使用OWIN.
* 他不能和现有已经存在的ASP.Net Mebership实现(provider)很好地工作, 而且它不可扩展.

### ASP.Net Universal Providers

为了能够在Microsoft Azure SQL Database中持久化会员信息, ASP.Net Universal Provider(通用提供器)被开发出来(Alan: 艹, 这句话被翻译的最准确), 而且它也可以和SQL Server Compact一起工作. Universal Providers 依赖于EF Code First, 这意味着Universal Providers可以在任何支持EF的存储方式上持久化数据(Alan: 也就是使用). 使用Universal Provider, 数据库架构也变的非常简洁.
Universal Providers是基于ASP.Net Membership基础设施, 因此, 作为SQLMembership Provider, Universal Provider也带来了同样的限制. 那就是他们都被设计成针对关系型数据库, 而且很难自定义配置和用户信息. 这些提供器也一直使用表单认证的登入/登出功能.

### ASP.Net Identity

ASP.Net的会员系统经过这么多年的进化, ASP.Net团队从客户那里获得了并吸收了很多反馈.
如果用户使用它们注册时填写的用户名和密码来登陆的假设不再有效(Alan: 大概意思应该是用户都不再通过注册然后登陆的形式来访问网站). Web就变得更加社交(社会化). 用户通过社交频道(比如FB, Twitter, 或者其他社交网站)实时与他人交流. 开发者系统用户能够使用它们的社交账号来登陆, 这样用户在他们(开发者)的网站上能够获得更加丰富的体验. 一个现代的应用必须拥有基于跳转-登陆的认证提供器(比如FB, Twitter或者其他)(Alan: 就是第三方登陆).
因为Web开发的演进, Web开发出现了一些设计模式/网站架构.(Alan: 大概是这个意思) 应用代码的单元测试变成了应用开发者的核心部分. 在2008年, ASP.Net添加了基于MVC模式的新框架, 作为帮助开发者开发可进行单元测试的ASP.Net应用的部分. 希望能够对应用程序的逻辑进行单元测试的开发者同样也希望能够对会员系统进行单元测试.
考虑到Web应用开发中的这些改变, Asp.Net Identity为了实现一下目标被开发出来:

* 一统江湖的ASP.Net Identity系统
	* ASP.Net Identity 可以应用于所有的ASP.Net框架, 比如ASP.Net MVC, Web Forms, Web Pages, Web API和SignalR。
	* 当你创建Web, Phone, Store或者混合应用的时候也可以使用ASP.Net Identity.

* 用户个人信息数据易于扩展(Ease of plugging in profile data about the user)
	* 你可以控制用户和配置信息的架构(Alan: 一般指表结构). 比如, 当用户在你的应用中注册时, 你可以很容易存储用汉语的生日.

* 持久化控制(Alan: 其实就是数据存储方案的选择, 比如关系型数据库, 非关系型数据库, 甚至XML)
	* 默认情况下, ASP.Net Identity将所有的用户信息存储在数据库中. ASP.Net Identity使用EF Code First来实现所有的持久化机制.
	* 你可以控制数据架构和常见的任务, 比如改变表名或者改变主键数据类型.
	* 很容就能替换成其他的存储机制， 比如SharePoint, Azure Storage Table Service, NoSQL数据库等等, 而且不需要必须抛出System.NotImplementedException异常.

* 可单元测试
	* ASP.Net Identity 使Web应用可单元测试. 你可以写ASP.Net Identity部分的单元测试.

* 角色提供器
	* 有一个角色提供器能够让你限制访问你的应用的某个部分. 你可以很容易的创建角色, 比如"Admin" 然后添加用户到角色.

* 基于Claims (Alan: claims是ASP.Net很底层的一个东西了, HttpContext.Current中的[User](https://msdn.microsoft.com/en-us/library/system.web.httpcontext.user.aspx)返回的就是实现了IPrincipal的一个对象. [Note](http://stackoverflow.com/questions/1064271/asp-net-mvc-set-custom-iidentity-or-iprincipal/10524305#10524305))
	* ASP.Net Identity支持claims-base的认证, 用户的身份被表示成一个claims集合. Claims允许开发者描述角色允许的用户身份. 而角色仅仅是一个布尔值(是角色成员或不是), claim可以包括用户身份和关系的丰富信息.

* 社交登录提供器
	* 你可以很容易添加社交登录功能使用Azure活动目录, 然后在你的应用里存储用户特殊数据.

* 集成OWIN
	* ASP.Net Identity 认证现在是基于OWIN中间件, 可以被使用在任何基于OWIN的宿主上. ASP.Net Identity在System.Web上没有任何依赖. 它完全兼容OWIN框架, 并可以被使用在任何基于OWIN的宿主应用中.

* NugGet包管理
	* ASP.Net Identity使用NuGet包管理进行分发. 而NuGet工具被安装在VS 2013中. 你可以从NuGet上下载.
	* 将ASP.Net Identity发布在NuGet上, 可使ASP.Net团队很容易迭代新特性和修复bug, 而且可以更快捷地分发到开发者手里.


### ASP.Net Identity起步

ASP.Net Identity被用在VS 2013 的MVC, Web Forms, Web API和SPA模板里. 在这个演练里, 我们将说明项目模板如果使用ASP.Net Identity的注册, 登陆和登出功能的.
ASP.Net Identity被实现使用下面步骤. 这篇文章的目的是让你对ASP.Net Identity有一个概览; 你可以跟着一步一步的操作或者仅仅阅读详细信息. 像获得使用ASP.Net Identity创建应用的更详细的介绍, 包括使用新的API来添加用户, 角色和配置信息, 可以查看文章底部的下一步节.

+ 使用独立账号(Individual User Accounts)创建ASP.Net MVC应用.你可以使用ASP.Net Identity在ASP.Net MVC, Web Forms, Web API, SignalR等等项目中. 在这篇文章中我们开始创建一个ASP.Net MVC应用. [图片](http://i2.asp.net/media/4459035/mvc.PNG?cdn_id=2015-05-22-001)
+ 创建的项目包含以下三个ASP.Net Identity相关的包
	* *Microsoft.AspNet.Identity.EntityFramework*
	这个包有ASP.Net Identity的EF实现, 它将会持久化ASP.Net Identity数据和架构在SQL Server里.
	* *Microsoft.AspNet.Identity.Core*
	这个包包含ASP.Net Identity的核心接口. 这个包可以被用来实现不同的持久化存储, 比如Azure Table Storage, NoSQL数据库等.
	* *Microsoft.AspNet.Identity.OWIN*
	这个包包含将ASP.Net Identity的OWIN认证插入到ASP.Net应用的功能. 这被用来给你的应用添加登陆功能并调用OWIN Cookie Authentication中间件来生成Cookie的功能.

+ 创建用户
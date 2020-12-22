
# 精通 Spring MVC 4

通过实现 `WebMvcConfigurer`, 可以对 Spring MVC 进行自定义配置, 它提供了很多的扩展点. 之前的 `WebMvcConfigurerAdapter` 和 `WebMvcConfigurerAdapter` 都已经不建议使用, 参考 [The type WebMvcConfigurerAdapter is deprecated](https://stackoverflow.com/questions/47552835/the-type-webmvcconfigureradapter-is-deprecated).

#### 4.1.3 展现上传的图片

`DefaultResourceLoader` 类, 因此可以使用像`file:`或 `classpath:` 这样的前缀来指定查找资源的位置, 这分别等价于创建 `FileSystemResource` 和 `ClassPathResource` 类: 

```properties
upload.pictures.uploadPath=file:./pictures
upload.pictures.anonymousPicture=classpath:/images/anonymous.png
```

```java
@Controller
@RequestMapping("/page")
public class PageController {

    @RequestMapping("/pic")
    public void picture(HttpServletResponse response) throws IOException {
        ClassPathResource res = new ClassPathResource("/static/egg.jpeg");
        response.setHeader("Content-Type", URLConnection.guessContentTypeFromName(res.getFilename()));
        InputStream in = res.getInputStream();
        IOUtils.copy(in, response.getOutputStream()); //org.apache.tomcat.util.http.fileupload.IOUtils
    }

}
```

#### 4.1.4 处理文件上传的错误

在 Spring 中处理错误的两种方式:

1. 在控制器的本地方法中使用`@ExceptionHandler`注解: 

```java
// 只处理当前控制器的异常
// 只处理 IOException 异常
@ExceptionHandler(IOException.class)
public ModelAndView handleIOException(IOException exception) {
    ModelAndView modelAndView = new ModelAndView("profile/uploadPage");
    modelAndView.addObject("error", exception.getMessage());
    return modelAndView;
}

// 处理所有异常
@ExceptionHandler
public Object whenError(Exception ex) {
    Map<String, String> maps = new HashMap<>();
    maps.put("error", ex.getMessage());
    maps.put("stack", ex.toString());
    return maps;
}
```
或者使用`@ControllerAdvice`来给控制器增加错误处理方法.

2. 在`Servlet`容器级别定义全局的异常处理器

有一些异常需要在 `Servlet` 容器级别(也就是 Tomcat 级别)来进行, 因为这个异常不会由控制器直接抛出.

```java
@Bean
public EmbeddedServletContainerCustomizer containerCustomizer() {
  // 这段代码创建了一个新的错误页面,当 MultipartException 出现的时候就会调用该页面 /error
  return container -> container.addErrorPages(new ErrorPage(MultipartException.class, "/error"));
}
```

In Spring Boot 2, the `EmbeddedServletContainerCustomizer` interface is replaced by `WebServerFactoryCustomizer`, while the `ConfigurableEmbeddedServletContainer` class is replaced with `ConfigurableServletWebServerFactory`. [via](https://www.baeldung.com/embeddedservletcontainercustomizer-configurableembeddedservletcontainer-spring-boot): 

```java
// 设置
@Component
public class CustomContainer implements WebServerFactoryCustomizer<ConfigurableServletWebServerFactory> {
    @Override
    public void customize(ConfigurableServletWebServerFactory factory) {
        factory.setPort(8099); // 设置应用监听的端口号
        ErrorPage error = new ErrorPage(Exception.class, "/error"); // 发生任何错误的时候都跳转到 /error 页面
        factory.addErrorPages(error);
    }
}

// 错误页面
@RequestMapping("/error")
public Object globalError(HttpServletRequest request) {
    Map<String, Object> maps = new HashMap<>();
    maps.put("url", request.getAttribute(WebUtils.ERROR_REQUEST_URI_ATTRIBUTE));
    maps.put("name", request.getAttribute(WebUtils.ERROR_SERVLET_NAME_ATTRIBUTE));
    maps.put("message", request.getAttribute(WebUtils.ERROR_MESSAGE_ATTRIBUTE));
    return maps;
}
```

#### 4.3 将基本信息放到会话中

在 Spring 中, 将内容放到会话中的另外一种流行方式就是为 bean 添加`@Scope ("session")`注解:

```java
@Component
@Scope(value = "session", proxyMode = ScopedProxyMode.TARGET_CLASS) 
public class UserProfileSession implements Serializable {
  /// ...
}
```

如果不算默认值的话, Spring 有 3 个可用的 `proxyMode` 参数:

* `TARGET_CLASS`: 这将会使用CGLib代理
* `INTERFACES`: 这会创建JDK代理
* `NO`: 这样不会创建任何代理

当我们将一些内容注入到长期存活的组件之中时, 例如单例的 bean, 那代理的好处就体现出来了. 因为注入只会发生一次, bean 创建之后, 对被注入 bean 的后续调用不一定能够反应它的实际状态. 

在我们的场景中, 会话 bean 的实际状态存储在会话之中, 并没有直接反应在 bean 上. 这就阐明了 Spring 为什么需要创建代理: 它需要拦截对 bean 方法的调用, 并监听它的变化. 通过这种方式, bean 状态的存储和获取, 就对底层 HTTP 会话完全透明了. 

对于会话 bean, 我们必须要使用代理模式. CGLib 代理会对字节码进行 instrument 操作, 能够用在任意的类上, 而 JDK 的方式可能会更加轻量级, 但是需要你实现一个接口. 

#### 5.9.2 使用异常来处理状态码

`@ControllerAdvice` 注解, 我们能够为一组控制器添加额外的行为:

```java
/**
* 当控制器发生 EntityNotFoundException 异常时
* 页面响应的状态码为 404
* 而且响应的页面内容为: test not found
*/
@ControllerAdvice
public class ExceptionAdvice {
    @ExceptionHandler(EntityNotFoundException.class)
    @ResponseStatus(value = HttpStatus.NOT_FOUND)
    public void handleNotFoundException(HttpServletResponse response) throws IOException {
        response.getOutputStream().println("test not found"); 
    }
}
```

## 第6章 保护应用

### 6.1 基本认证

```java
@Configuration
@EnableGlobalMethodSecurity(securedEnabled = true)
public class SecurityConfiguration extends WebSecurityConfigurerAdapter {
    @Autowired
    public void configureAuth(AuthenticationManagerBuilder auth) throws Exception { 
      auth.inMemoryAuthentication() "ADMIN"); 
    } 
}
.withUser("user").password("user").roles("USER").and()
.withUser("admin").password("admin").roles("USER",
```

`@EnableGlobalMethodSecurity` 注解将会允许我们为应用中的类和方法添加注解，从而定义它们的安全级别。
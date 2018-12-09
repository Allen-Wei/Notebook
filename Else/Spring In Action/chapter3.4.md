## 3.4 bean 的作用域

Spring定义了多种作用域: 

* **单例(Singleton, `ConfigurableBeanFactory.SCOPE_SINGLETON`)**: 在整个应用中, 只创建bean的一个实例。
* **原型(Prototype, `ConfigurableBeanFactory.SCOPE_PROTOTYPE`)**: 每次注入或者通过Spring应用上下文获取的时候，都会创建一个新的bean实例。 
* **会话(Session, `WebApplicationContext.SCOPE__SESSION`)**: 在Web应用中，为每个创建一个bean实例。
* **请求(Request)**: 在Web应用中，为每个请求创建一个bean实例。

单例是默认作用域, 要更改作用域需要使用`@Scope`注解, 它可以与`@Compoent`或`@Bean`一起使用。

### Session and Request Scope

假设一个购物车 bean: 

```java
@Component
@Scope(value=WebApplicationContext.SCOPE_SESSION, proxyMode=ScopedProxyMode.INTERFACES)
public ShoppingCart cart(){ }
```

`value=WebApplicationContext.SCOPE_SESSION` 表示这是一个会话bean.

`proxyMode=ScopedProxyMode=INTERFACES` 是为了解决将会话或请求作用域的bean注入到单例bean中遇到的问题.

假设我们要将 `ShoppingCart` bean 注入到单例 `StoreService` bean 的 `Setter` 方法中: 

```java
@Component
public class StoreService {
	@Autowired
	public void setShoppingCart(ShoppingCart cart){
		//...
	}
}
```

因为`StoreService`是一个单例bean, 会在应用上下文家在的时候创建, 当它创建的时候, Spring会试图将`ShoppingCart` 注入到 `setShoppingCart`, 但是 `ShoppingCart` 只有在创建会话之后才会出现实例, 另外系统将会有多个`ShoppingCart`实例, 并不想让某个特定的实例注入到 `StoreService` 中. 加上`ScopedProxyMode.INTERFACES`之后, Spring并不会将实际的 `ShoppingCart` bean注入到 `StoreService`中, Spring会注入一个到 `ShoppingCart` bean的代理. 这个代理会暴露和 `ShoppingCart` 接口相同的方法, 当 `StoreService` 调用 `ShoppingCart` 的方法时, 代理会对其进行懒解析, 并将调用委托给会话作用域中真正的`ShoppingCart` bean. 如果`ShoppingCart` 是接口而不是一个具体类的话, Spring就没有办法创建基于接口的代理了, 此时它必须使用CGLib来生成基于类的代理, 所以 bean类型是具体类的话, 必须将 `proxyMode` 属性设置为`ScopedProxyMode.TARGET_CLASS`.

## 运行时值注入

*src/main/java/chapter3/ResourcesSample.java*: 

```java
package chapter3;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

@Component
@PropertySource("classpath:/chapter3/app.properties")
public class ResourcesSample {

    @Autowired
    private Environment env;

    public void print() {

        String firstName = this.env.getProperty("firstName");
        System.out.println("first name: " + firstName);

        Integer age = this.env.getProperty("age", Integer.class);
        System.out.println("age: " + age);

        String notExisted = this.env.getProperty("notExisted", "default");
        System.out.println("not existed: " + notExisted);
    }

}
```

*src/main/resources/chapter3/app.properties*:

```
firstName=alan
lastName=wei
age=28
```

* String getProperty(String key)
* String getProperty(String key, String defaultValue)
* T getProperty(String key, Class<T> type)
* T getProperty(String key, Class<T> type, T defaultValue)

在使用 `getProperty` 方法时如果没有指定默认值(`defaultValue`), 并且这个属性没有定义的话, 获取到的值是null. 如果你希望这个属性必须要定义, 可以使用 `getRequiredProeprty()` 方法(如果未定义抛出`IllegalStateException`异常).

如果想检查属性是否存在, 可以调用 `boolean Environment.containsProperty(String key)`.

如果想将属性解析为类的话, 可以使用 `getPropertyAsClass()`方法: 

```java
Class<Foo> foo = env.getPropertyAsClass("foo.class", Foo.class);
```

#### 解析属性占位符



```java
package temporary;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.context.support.PropertySourcesPlaceholderConfigurer;

@Configuration
@PropertySource("classpath:/chapter3/app.properties")
public class AppConfig {

	//这里执行值注入
    @Value("${db.driver}")
    private String driver;

	//为了使值注入生效, 必须配置一个 PropertySourcesPlaceholderConfigurer, 
	//因为它能够基于 Spring Environment 及其属性源来解析占位符.
    @Bean
    public static PropertySourcesPlaceholderConfigurer propertyConfigInDev() {
        return new PropertySourcesPlaceholderConfigurer();
    }
}
```


### 3.5.2 使用 Spring 表达式语言进行装配

Spring 3引入了 SpEL(Spring Expression Language, SpEL), 能够将值装配到bean属性和构造器参数中: 

* 使用 bean 的ID来饮用bean
* 调用方法和访问对象的属性
* 对值进行算数、关系和逻辑运算
* 正则表达式匹配
* 集合操作



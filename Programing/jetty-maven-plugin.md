# Jetty Maven 插件使用示例

Ref: [Maven Jetty Plugin Examples](https://www.mkyong.com/maven/maven-jetty-plugin-examples/)

Few Maven Jetty 8.x and 9.x plugin examples, just for quick reference.
 
## Maven Jetty Plugin 9.x

> You need to use Maven 3 and Java 1.7 for Maven Jetty 9.x plugin.

The `groupId` is `org.eclipse.jetty`, by default, it runs on port `8080`, in root context `/`.

_pom.xml_:
```xml
<plugin>
    <groupId>org.eclipse.jetty</groupId>
    <artifactId>jetty-maven-plugin</artifactId>
    <!-- version 配置节可省略 -->
    <version>9.2.11.v20150529</version>
</plugin>
```

To run the Maven Jetty plugin

```bash
$ mvn jetty:run
```

Deployed URL: _http://localhost:8080/_

To stop the running Jetty instance

```
$ ctrl + c
```

Change a context path.

_pom.xml_:

```xml
<plugin>
    <groupId>org.eclipse.jetty</groupId>
    <artifactId>jetty-maven-plugin</artifactId>
    <version>9.2.11.v20150529</version>
    <configuration>
    	<scanIntervalSeconds>10</scanIntervalSeconds>
    	<webApp>
    	     <contextPath>/abc</contextPath>
    	</webApp>	 
    </configuration>
</plugin>
```

Deployed URL : _http://localhost:8080/abc_

Change a different port.

_pom.xml_: 

```xml
  <plugin>
	<groupId>org.eclipse.jetty</groupId>
	<artifactId>jetty-maven-plugin</artifactId>
	<version>9.2.11.v20150529</version>
	<configuration>
		<scanIntervalSeconds>10</scanIntervalSeconds>
		<webApp>
		     <contextPath>/abc</contextPath>
		</webApp>
		<httpConnector>
          	     <port>8888</port>
        	</httpConnector>
	</configuration>
  </plugin>
 ```

Deployed URL : _http://localhost:8888/abc_

Or you can pass a system property `jetty.port` manually :

```bash
$ mvn -Djetty.port=8888 jetty:run
```

`jetty.xml` example.

_pom.xml_:

```xml
	<plugin>
	 	<groupId>org.eclipse.jetty</groupId>
		<artifactId>jetty-maven-plugin</artifactId>
		<version>9.2.11.v20150529</version>
		<configuration>
			<scanIntervalSeconds>10</scanIntervalSeconds>
			<webApp>
			      <contextPath>/abc</contextPath>
			 </webApp>
			 <jettyXml>jetty.xml</jettyXml>
		</configuration>
	</plugin>
```

_jetty.xml_: 

```xml
<?xml version="1.0"?>
<!DOCTYPE Configure PUBLIC "-//Jetty//Configure//EN" "http://www.eclipse.org/jetty/configure_9_3.dtd">
<Configure id="Server" class="org.eclipse.jetty.server.Server">
  <Call name="addConnector">
    <Arg>
      <New id="httpConnector" class="org.eclipse.jetty.server.ServerConnector">
        <Arg name="server"><Ref refid="Server" /></Arg>
        <Set name="host"><Property name="jetty.http.host" deprecated="jetty.host" /></Set>
        <Set name="port"><Property name="jetty.http.port" deprecated="jetty.port" default="1234" /></Set>
        <Set name="idleTimeout"><Property name="jetty.http.idleTimeout" deprecated="http.timeout" default="30000"/></Set>
      </New>
    </Arg>
  </Call>
</Configure>
```

Deployed URL : _http://localhost:1234/abc_

> More [Jetty Maven Plugin 9.x Examples](http://www.eclipse.org/jetty/documentation/current/jetty-maven-plugin.html)

## Maven Jetty Plugin 8.x

The `groupId` is `org.mortbay.jetty`, by default, it runs on port `8080`, in root context `/`.

_pom.xml_:

```xml
  <plugin>
	<groupId>org.mortbay.jetty</groupId>
	<artifactId>jetty-maven-plugin</artifactId>
	<version>8.1.16.v20140903</version>
  </plugin>
```

Change a different context path, set seconds to check for changes and automatically hot redeploy.

_pom.xml_:

```xml
  <plugin>
	<groupId>org.mortbay.jetty</groupId>
	<artifactId>jetty-maven-plugin</artifactId>
	<version>8.1.16.v20140903</version>
	<configuration>
		<scanIntervalSeconds>10</scanIntervalSeconds>
		<webApp>
			<contextPath>/abc</contextPath>
		</webApp>
	</configuration>
  </plugin>
```

Deployed URL : _http://localhost:8080/abc_

Change a different port to start.

_pom.xml_:

```xml
  <plugin>
	<groupId>org.mortbay.jetty</groupId>
	<artifactId>jetty-maven-plugin</artifactId>
	<version>8.1.16.v20140903</version>	
	<configuration>
		<scanIntervalSeconds>10</scanIntervalSeconds>
		<webApp>
			<contextPath>/abc</contextPath>
		</webApp>
		<connectors>
			<connector implementation="org.eclipse.jetty.server.nio.SelectChannelConnector">
			<port>8888</port>
			</connector>
		</connectors>
	</configuration>
  </plugin>
```

Deployed URL : _http://localhost:8888/abc_

Alternatively, you can pass a system property `jetty.port` manually: `mvn -Djetty.port=8888 jetty:run`

P.S The class `SelectChannelConnector` is the default Jetty connector.
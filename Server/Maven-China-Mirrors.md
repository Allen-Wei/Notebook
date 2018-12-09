# Maven Mirrors in China

## Configurate `settings.xml`

	<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
	  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
	                      https://maven.apache.org/xsd/settings-1.0.0.xsd">
	  <localRepository>
	    ${user.home}/.m2/repository
	  </localRepository>
	  <interactiveMode>true</interactiveMode>
	  <usePluginRegistry>false</usePluginRegistry>
	  <offline/>
	  <pluginGroups/>
	  <servers/>
	  <mirrors>
	    <mirror>  
	      <id>maven-aliyun</id>  
	      <name>Maven Aliyun Mirror</name>  
	      <url>http://maven.aliyun.com/nexus/content/groups/public/</url>  
	      <mirrorOf>central</mirrorOf>  
	    </mirror>  
	    <mirror>  
	      <id>maven-net-cn</id>  
	      <name>Maven China Mirror</name>  
	      <url>http://maven.NET.cn/content/groups/public/</url>  
	      <mirrorOf>central</mirrorOf>  
	    </mirror>  
	  </mirrors>
	  <proxies/>
	  <profiles/>
	  <activeProfiles/>
	</settings>

## `settings.xml` Location
1. Unix `~/.m2`
2. Windows `C:\Users\UserName\.m2`

## Reference
[Maven Settings Reference](http://maven.apache.org/settings.html)
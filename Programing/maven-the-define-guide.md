# Maven: Then Define Guide

```bash
# 显示插件(archetype)帮助信息
$ mvn help:describe -Dplugin=archetype -Dfull 
$ mvn archetype:help -Ddetail=true -Dgoal=generate
# 创建一个maven项目
$ mvn archetype:generate -DgroupId=net.alanwei -DartifactId=demo -DinteractiveMode=false 
# 创建一个maven项目
$ mvn archetype:generate -DgroupId=net.alanwei -DartifactId=webapp-demo -DarchetypeArtifactId=maven-archetype-webapp -DinteractiveMode=false
```

Jetty 插件使用参考 [jetty-maven-plugin](./jetty-maven-plugin.md).

获取一个插件的帮助文档:
```bash
$ mvn help:describe -Dplugin=help -Dfull # 获取 maven-help-plugin 的帮助信息
$ mvn help:describe -Dplugin=compiler -Dfull # 获取 maven-compiler-plugin 的帮助信息
$ mvn assembly:help # 获取 maven-assembly-plugin 插件的帮助信息
```

通过帮助文档获取到以下常用命令: 
```bash
$ mvn help:effective-pom  #显示当前构建的实际POM, 包含活动的Profile
```

配置`maven-compiler-plugin`JDK编译和输出使用1.8版本:
```xml
<plugin>
  <artifactId>maven-compiler-plugin</artifactId>
  <configuration>
    <source>1.8</source>
    <target>1.8</target>
  </configuration>
</plugin>
```
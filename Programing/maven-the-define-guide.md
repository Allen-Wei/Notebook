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
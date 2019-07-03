# Exec Maven Plugin 

ref
* [Running Java programs with the exec goal](http://www.mojohaus.org/exec-maven-plugin/examples/example-exec-for-java-programs.html)
* [Using Maven 'exec:exec' with Arguments](https://stackoverflow.com/questions/15013651/using-maven-execexec-with-arguments)

## 查看用法

```bash
mvn help:describe -Dplugin=exec -Dfull
```

## Command Line 命令行执行

```bash
mvn exec:java -Dexec.mainClass="net.alanwei.App" -Dexec.args="arg1 arg2"
```

## pom.xml 配置

```xml
<build>
    <plugins>
        <!-- 编译插件 -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <configuration>
                <source>1.8</source>
                <target>1.8</target>
            </configuration>
        </plugin>
        <!-- 执行插件 -->
        <plugin>
            <groupId>org.codehaus.mojo</groupId>
            <artifactId>exec-maven-plugin</artifactId>
            <version>1.6.0</version>
            <configuration>
                <executable>java</executable>
                <arguments>
                    <argument>-classpath</argument>
                    <classpath/>
                    <argument>net.alanwei.App</argument>
                </arguments>
            </configuration>
        </plugin>
    </plugins>
```
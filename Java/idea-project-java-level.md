## 设置IDEA Java项目的JDK级别

来源: [Error:java: javacTask: source release 8 requires target release 1.8
](https://stackoverflow.com/questions/29888592/errorjava-javactask-source-release-8-requires-target-release-1-8)

1. 找到设置**File > Settings > Build, Execution, Deployment > Compiler > Java Compiler**
2. 把你使用的module的 **Target bytecode** 改为 **1.8** .

如果你还使用了maven, 添加以下编译插件到项目顶级的 `pom.xml` 文件:

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd"> 
    <!-- 其他配置节 -->
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                </configuration>
            </plugin>
        </plugins>
    </build>
    <properties>
        <java.version>1.8</java.version>
    </properties>
    <!-- 其他配置节 -->
</project>

```

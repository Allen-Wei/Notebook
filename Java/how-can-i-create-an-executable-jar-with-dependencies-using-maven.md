# How can I create an executable JAR with dependencies using Maven?

[使用Maven打包可执行JAR程序](https://stackoverflow.com/questions/574594/how-can-i-create-an-executable-jar-with-dependencies-using-maven)

## Answer 1
```xml
<build>
  <plugins>
    <plugin>
      <artifactId>maven-assembly-plugin</artifactId>
      <configuration>
        <archive>
          <manifest>
            <mainClass>fully.qualified.MainClass</mainClass>
          </manifest>
        </archive>
        <descriptorRefs>
          <descriptorRef>jar-with-dependencies</descriptorRef>
        </descriptorRefs>
      </configuration>
    </plugin>
  </plugins>
</build>
```

and you run it with

```bash
mvn clean compile assembly:single
```

## Answer 2

You can use the dependency-plugin to generate all dependencies in a separate directory before the package phase and then include that in the classpath of the manifest:

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-dependency-plugin</artifactId>
    <executions>
        <execution>
            <id>copy-dependencies</id>
            <phase>prepare-package</phase>
            <goals>
                <goal>copy-dependencies</goal>
            </goals>
            <configuration>
                <outputDirectory>${project.build.directory}/lib</outputDirectory>
                <overWriteReleases>false</overWriteReleases>
                <overWriteSnapshots>false</overWriteSnapshots>
                <overWriteIfNewer>true</overWriteIfNewer>
            </configuration>
        </execution>
    </executions>
</plugin>
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-jar-plugin</artifactId>
    <configuration>
        <archive>
            <manifest>
                <addClasspath>true</addClasspath>
                <classpathPrefix>lib/</classpathPrefix>
                <mainClass>theMainClass</mainClass>
            </manifest>
        </archive>
    </configuration>
</plugin>
```

Alternatively use `${project.build.directory}/classes/lib` as OutputDirectory to integrate all jar-files into the main jar, but then you will need to add custom classloading code to load the jars.

## Method 3

[Uber JAR with Maven](https://robert-reiz.com/2011/10/19/uber-jar-with-maven/)

By default maven is generating a small JAR file, which just contains your compiled classes and other project files. If you want to have a single JAR file which also includes all dependent JAR files, you have to create a uber JAR. You can do that with the maven shade plugin. Just put this lines of xml into your pom.xml.

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-shade-plugin</artifactId>
            <version>1.4</version>
            <executions>
                <execution>
                    <phase>package</phase>
                    <goals>
                        <goal>shade</goal>
                    </goals>
                    <configuration>
                        <shadedArtifactAttached>true</shadedArtifactAttached>
                        <shadedClassifierName>all</shadedClassifierName>
                    </configuration>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

In Maven you can solve every problem. You just need enough XML code for that. If you still have problems, than probably your pom.xml is to short.

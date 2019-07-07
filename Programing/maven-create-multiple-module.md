#  How to Create Maven Multi Module using Command Line

如何使用命令行创建带有多个子模块的Maven项目

In this guide, we learn how to create __Maven Multi-Module__ using Command Line with very easy steps. A multi-module project is defined by a parent POM referencing one or more sub-modules. In this example, we will create a blogger web application with different modules. Let's create a blogger as parent project and it's 3 sub-modules are blogger-core, blogger-common, blogger-web.

Real-world examples of maven multi-module projects are:

1. https://github.com/RameshMF/junit-developer-guide
2. https://github.com/spring-projects/spring-framework
3. https://github.com/apache/maven
4. https://github.com/jersey/jersey

## Create a Maven Multi Module using Command Line

Below are the steps to create parent and sub-modules projects.

### Step 1: Create Parent project - blogger

To create the Parent project:

```bash
mvn archetype:generate -DgroupId=com.companyname.blogger -DartifactId=blogger
```

Note that whole command should be a single line. After build success, we will see below output in the command line console.

```log
[INFO] Parameter: package, Value: com.companyname.blogger
[INFO] Parameter: groupId, Value: com.companyname.blogger
[INFO] Parameter: artifactId, Value: blogger
[INFO] Parameter: packageName, Value: com.companyname.blogger
[INFO] Parameter: version, Value: 1.0-SNAPSHOT
[INFO] project created from Old (1.x) Archetype in dir: C:\Ramesh_Study\maven\guides\blogger
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 01:09 min
[INFO] Finished at: 2018-06-20T13:40:40+05:30
[INFO] ------------------------------------------------------------------------
```

### Step 2: Update pom.xml to Declare It as Parent Project

Open __pom.xml__ of above-created parent-project and change the packaging to `pom`.

```xml
 <packaging>pom</packaging>
```

The complete __pom.xml__

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.companyname.blogger</groupId>
  <artifactId>blogger</artifactId>
  <version>1.0-SNAPSHOT</version>
  <packaging>pom</packaging>

  <name>blogger</name>
  <url>http://maven.apache.org</url>

  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>

  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>3.8.1</version>
      <scope>test</scope>
    </dependency>
  </dependencies>
</project>
```

If you don't change this pom.xml then you will get below build fail error:

```log
[INFO] Parameter: groupId, Value: com.companyname.blogger
[INFO] Parameter: artifactId, Value: blogger-core
[INFO] Parameter: version, Value: 1.0-SNAPSHOT
[INFO] Parameter: package, Value: com.companyname.blogger
[INFO] Parameter: packageInPathFormat, Value: com/companyname/blogger
[INFO] Parameter: version, Value: 1.0-SNAPSHOT
[INFO] Parameter: package, Value: com.companyname.blogger
[INFO] Parameter: groupId, Value: com.companyname.blogger
[INFO] Parameter: artifactId, Value: blogger-core
[INFO] ------------------------------------------------------------------------
[INFO] BUILD FAILURE
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 01:49 min
[INFO] Finished at: 2018-06-20T13:49:18+05:30
[INFO] ------------------------------------------------------------------------
[ERROR] Failed to execute goal org.apache.maven.plugins:maven-archetype-plugin:3.0.1:generate (default-cli) validPackaging: **Unable to add module to the current project as it is not of packaging type 'pom'** -> [Help 1]
```

### Step 3: Create Sub-modules

Change directory via below command

```bash
cd blogger
```

Let's create sub-modules in `blogger` parent project.

Create `blogger-core` module.

```bash
mvn archetype:generate -DgroupId=com.companyname.blogger  -DartifactId=blogger-core
```

Create `blogger-common` module

```bash
mvn archetype:generate -DgroupId=com.companyname.blogger  -DartifactId=blogger-common
```

Create `blogger-web` module and it is web application packaged with war file. The archetype for maven web application is `-DarchetypeArtifactId=maven-archetype-webapp`

```bash
mvn archetype:generate -DgroupId=com.companyname.blogger  -DartifactId=blogger-web -DarchetypeArtifactId=maven-archetype-webapp
```

Now if you open the blogger parent project __pom.xml__, you will find all three modules being added in there.

```xml
 <modules>
    <module>blogger-core</module>
    <module>blogger-common</module>
    <module>blogger-web</module>
  </modules>
 ```

Also, in each sub-module’s __pom.xml__, a parent section being added.

```xml
 <parent>
    <artifactId>blogger</artifactId>
    <groupId>com.companyname.blogger</groupId>
    <version>1.0-SNAPSHOT</version>
  </parent>
```

### Step 4: Update Sub-Modules pom.xml to Produce Appropriate Output

`blogger-core` module is package with jar

```xml
<packaging>jar</packaging>
```

`blogger-common` module is a package with a jar.

```xml
<packaging>jar</packaging>
```

`blogger-web` module is already packaging with war.

```xml
<packaging>war</packaging>
```

Let's updated __pom.xml__ files for all the parent and sub-modules.

1. `blogger` parent project __pom.xml__:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.companyname.blogger</groupId>
  <artifactId>blogger</artifactId>
  <version>1.0-SNAPSHOT</version>
  <packaging>pom</packaging>

  <name>blogger</name>
  <url>http://maven.apache.org</url>

  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>

  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>3.8.1</version>
      <scope>test</scope>
    </dependency>
  </dependencies>
  <modules>
    <module>blogger-common</module>
    <module>blogger-web</module>
    <module>blogger-core</module>
  </modules>
</project>
```

2. `blogger-core` sub-module __pom.xml__:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <parent>
    <artifactId>blogger</artifactId>
    <groupId>com.companyname.blogger</groupId>
    <version>1.0-SNAPSHOT</version>
  </parent>

  <groupId>com.companyname.blogger</groupId>
  <artifactId>blogger-core</artifactId>
  <version>1.0-SNAPSHOT</version>
  <packaging>jar</packaging>
  <name>blogger-core</name>
  <!-- FIXME change it to the project's website -->
  <url>http://www.example.com</url>

  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <maven.compiler.source>1.7</maven.compiler.source>
    <maven.compiler.target>1.7</maven.compiler.target>
  </properties>

  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>4.11</version>
      <scope>test</scope>
    </dependency>
  </dependencies>
</project>
```

3. `blogger-common` sub-module __pom.xml__:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <parent>
    <artifactId>blogger</artifactId>
    <groupId>com.companyname.blogger</groupId>
    <version>1.0-SNAPSHOT</version>
  </parent>

  <groupId>com.companyname.blogger</groupId>
  <artifactId>blogger-common</artifactId>
  <version>1.0-SNAPSHOT</version>
  <packaging>jar</packaging>
  <name>blogger-common</name>
  <!-- FIXME change it to the project's website -->
  <url>http://www.example.com</url>

  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <maven.compiler.source>1.7</maven.compiler.source>
    <maven.compiler.target>1.7</maven.compiler.target>
  </properties>

  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>4.11</version>
      <scope>test</scope>
    </dependency>
  </dependencies>
</project>
```

4. `blogger-web` sub-module __pom.xml__:

```xml
<?xml version="1.0"?>
<project xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd" xmlns="http://maven.apache.org/POM/4.0.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <modelVersion>4.0.0</modelVersion>
  <parent>
    <groupId>com.companyname.blogger</groupId>
    <artifactId>blogger</artifactId>
    <version>1.0-SNAPSHOT</version>
  </parent>
  <groupId>com.companyname.blogger</groupId>
  <artifactId>blogger-web</artifactId>
  <version>1.0-SNAPSHOT</version>
  <packaging>war</packaging>
  <name>blogger-web Maven Webapp</name>
  <url>http://maven.apache.org</url>
  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>3.8.1</version>
      <scope>test</scope>
    </dependency>
  </dependencies>
  <build>
    <finalName>blogger-web</finalName>
  </build>
</project>
```

### 2. Build Multi-Module
To test all the multi-module project setup is correct then run below maven common on blogger parent project:

```bash
mvn clean install
```

The output of above command

```log
[INFO] Reactor Summary:
[INFO]
[INFO] blogger 1.0-SNAPSHOT ............................... SUCCESS [  0.746 s]
[INFO] blogger-common ..................................... SUCCESS [  5.727 s]
[INFO] blogger-core ....................................... SUCCESS [  1.775 s]
[INFO] blogger-web Maven Webapp 1.0-SNAPSHOT .............. SUCCESS [  0.809 s]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 9.289 s
[INFO] Finished at: 2018-06-20T14:20:05+05:30
[INFO] ------------------------------------------------------------------------
```

That's it. Now can import this project into Eclipse IDE. In Eclipse , __File -> Import -> Maven -> Existing Maven projects__

### 3. Conclusion

In this guide, we have learned how to create maven Multi-Module using Command Line by taking the bloggerproject as an example.

The source code of this multi-module project is available on [GitHub](https://github.com/RameshMF/apache-maven-httpclient-tomcat-guides/tree/master/blogger-multi-module).

Read my favorite [Maven Developers Guide](http://java-developers-guide.blogspot.com/p/maven.html).
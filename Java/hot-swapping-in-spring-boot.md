FROM [Hot Swapping In Spring Boot](https://stackoverflow.com/questions/21399586/hot-swapping-in-spring-boot)

What helped me in IntelliJ 15.0, windows 10, was the following sequence:

STEP 1: Added the following dependency in pom (This is mentioned everywhere but this alone dint solve it), as mentioned by @jonashackt

```xml
<dependency>
     <groupId>org.springframework.boot</groupId>
     <artifactId>spring-boot-devtools</artifactId>
</dependency>
```

STEP 2: Then from __File->Settings-> Build-Execution-Deployment -> Compiler__ (make sure main compiler option is selected and not any of its sub-options)

enable Make Project Automatically. Click ok and close the dialog Note : In latest version it will be Build project automatically

STEP 3: Hold `Shift+Ctrl+A` (on windows) you will see a search dialog with title __Enter Action or option name__ , type __registry__ Double click the first option that says "Registry..." it will open another window. Look for the following option:

```
compiler.automake.allow.when.app.running
```

and enable it, click close

STEP 4: Restart IDE

Elaborated from this [source](https://dzone.com/articles/spring-boot-application-live-reload-hot-swap-with)

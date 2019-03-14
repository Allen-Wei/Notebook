# How to Set $JAVA_HOME environment variable on Mac OS X

如何在Mac系统上设置 `JAVA_HOME`

via [How to Set $JAVA_HOME environment variable on Mac OS X](https://www.mkyong.com/java/how-to-set-java_home-environment-variable-on-mac-os-x/)

In this tutorial, we show you how to set `$JAVA_HOME` environment variable on latest or older Mac OSX.

## Mac OSX 10.5 or later
In Mac OSX 10.5 or later, Apple recommends to set the `$JAVA_HOME` variable to `/usr/libexec/java_home`, just export `$JAVA_HOME` in file `~/.bash_profile` or `~/.profile`.

```bash
$ vim .bash_profile 
export JAVA_HOME=$(/usr/libexec/java_home)
$ source .bash_profile
$ echo $JAVA_HOME
/Library/Java/JavaVirtualMachines/1.7.0.jdk/Contents/Home
```

Why `/usr/libexec/java_home`?
This `java_home` can return the Java version specified in Java Preferences for the current user. For examples,

```bash
/usr/libexec/java_home -V
Matching Java Virtual Machines (3):
    1.7.0_05, x86_64:	"Java SE 7"	/Library/Java/JavaVirtualMachines/1.7.0.jdk/Contents/Home
    1.6.0_41-b02-445, x86_64:	"Java SE 6"	/System/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home
    1.6.0_41-b02-445, i386:	"Java SE 6"	/System/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home
```

This Mac OSX has three JDK installed.

```
##return top Java version
$ /usr/libexec/java_home
/Library/Java/JavaVirtualMachines/1.7.0.jdk/Contents/Home

## I want Java version 1.6
$ /usr/libexec/java_home -v 1.6
/System/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home
```

 
## Older Mac OSX
For older Mac OSX, the `/usr/libexec/java_home` doesn’t exists, so, you should set `JAVA_HOME` to the fixed path:

```bash
$ vim .bash_profile 
export JAVA_HOME=/System/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home
$ source .bash_profile
$ echo $JAVA_HOME
/System/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home
```
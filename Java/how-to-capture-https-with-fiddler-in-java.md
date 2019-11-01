# how to Capture https with fiddler in java

怎么在Java程序中捕获HTTPS请求: 

[Ref](https://stackoverflow.com/questions/8549749/how-to-capture-https-with-fiddler-in-java)

Create a keystore containing the Fiddler certificate. Use this keystore as the truststore for the JVM along with the proxy settings.

Here's how to do that:

Export Fiddler's root certificate

	Tools -> Fiddler Options... -> HTTPS -> Export Root Certificate to Desktop

Create a keystore with this certificate
Open command line as administrator (keytool doesn't work otherwise)

	<JDK_Home>\bin\keytool.exe -import -file C:\Users\<Username>\Desktop\FiddlerRoot.cer -keystore FiddlerKeystore -alias Fiddler

Enter a password when prompted. This should create a file called FiddlerKeystore.

Now start the JVM with Fiddler as the proxy and this keystore as the truststore. You'll need these vmargs:

```
-DproxySet=true
-DproxyHost=127.0.0.1
-DproxyPort=8888
-Djavax.net.ssl.trustStore=<path\to\FiddlerKeystore>
-Djavax.net.ssl.trustStorePassword=<Keystore Password>
```

Use these vmargs in your eclipse run configuration and you should be good to go.

I'm able to capture HTTPS requests made from the JVM without any issues with this setup.


* `-Djava.net.useSystemProxies=true` 使用系统代理
* `-Dhttp.proxyHost=127.0.0.1` Http代理地址
* `-Dhttp.proxyPort=8888` Http代理端口号
* `-Dhttps.proxyHost=127.0.0.1` Https代理地址
* `-Dhttps.proxyPort=8888` Https代理端口号
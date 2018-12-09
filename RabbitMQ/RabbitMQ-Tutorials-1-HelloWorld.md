
[原文](http://www.rabbitmq.com/tutorials/tutorial-one-dotnet.html)

# Introduction


RabbitMQ 是一个消息代理(协商服务器). 本质上, RabbitMQ从生产者那儿接收一个消息, 然后把消息传递给消费者. 在两者之间, 可以根据你提供的规则路由, 缓存和持久化消息.

RabbitMQ, 用行业术语就是通信.

生产意味着发送. 一个程序发送消息就是生产者, 我们用P表示:

![P](http://www.rabbitmq.com/img/tutorials/producer.png)

队列就是有名字的邮箱, 存活在RabbitMQ里. 虽然消息流通过RabbitMQ和你的程序, 但是消息被存储在队列里面. 队列没有被绑定任何限制, 你可以存储许多消息在队列里. 它本质上是一个无限的缓存区. 多个生产者可以发送多个消息到一个队列, 多个消费者可以从一个队列接收数据. 队列可以表示如下:

![Queue](http://www.rabbitmq.com/img/tutorials/queue.png)

消费近似意味着接收. 消费者是一个大部分情况下在等待接收消息的程序. 表示如下:

![Consumer](http://www.rabbitmq.com/img/tutorials/consumer.png)

注意, 生产者, 消费者和代理不一定必须在宿主在一台机器上. 实际上, 大部分应用他们都不在一台机器上.

## "Hello World"
(using the .NET/C# Client)
在教程的这个部分, 我们将用C#写两个程序. 一个发送单条消息的生产者, 和接收并打印消息的消费者. 我们将会做一些注释, 在一些具体的.NET API上.
在下面的示意图上, "P" 是我们的生产者, "C"是消费者. 中间的盒子是队列, 也即是缓存的消息:
![P-Q-C](http://www.rabbitmq.com/img/tutorials/python-one.png)

	.NET client library
	RabbmitMQ支持多种协议. 这个教程使用的是AMQP 0-9-1, 一种开放的, 多用途的消息协议. 有多个RabbitMQ不同语言的客户端.我们将要使用RabbitMQ提供的.NET客户端
	下载[客户端类库](http://www.rabbitmq.com/dotnet.html), 比对签名.解压并拷贝到工作目录.
	你需要确保你的系统能够找到C#编译工具 `csc.exe`, 你也许需要添加 `http://www.rabbitmq.com/dotnet.html`(根据你安装的.NET版本改变路径) 到你的Path.

现在我们有了.NET客户端类库, 我们可以写一下代码

## Sending

![sending](http://www.rabbitmq.com/img/tutorials/sending.png)
我们将会调用我们的消息发送者 `Send.cs` 和我们的消息接收者 `Receive.cs`. 发送者将会连接 RabbitMQ, 发送一条消息, 然后退出.

在 `Send.cs` 里, 我们需要使用如下命名空间:

	using System;
	using RabbitMQ.Client;
	using System.Text;	

设置类:

	class Send
	{
		public static void Main()
		{
			...
		}
	}

然后我们可以创建一个连接到服务器:

	class Send
	{
		public static void Main()
		{
			var factory = new ConnectionFactory() {HostName = "localhost"};
			using(var connection = factory.CreateConnection())
			{
				using(var channel = connection.CreateModel())
				{
					...
				}
			}
		}
	}

connection连接抽象了socket连接, 为我们提供了协议版本协商和认证等等. 这里我们连接到本机的代理 - *localhost*. 如果我们想连接其他机器上的代理, 只需要在此处指定他的名字或IP地址.
接下来我们创建channel(信道), 这是大部分API获取信息的地方.
我们要为我们的发送声明一个队列, 然后我们就可以发布消息到这个队列:


	using System;
	using RabbitMQ.Client;
	using System.Text;

	class Send
	{
		public static void Main()
		{
			var factory = new ConnectionFactory() { HostName = "localhost" };
			using(var connection = factory.CreateConnection())
			using(var channel = connection.CreateModel())
			{
				channel.QueueDeclare(queue: "hello",
									 durable: false,
									 exclusive: false,
									 autoDelete: false,
									 arguments: null);

				string message = "Hello World!";
				var body = Encoding.UTF8.GetBytes(message);

				channel.BasicPublish(exchange: "",
									 routingKey: "hello",
									 basicProperties: null,
									 body: body);
				Console.WriteLine(" [x] Sent {0}", message);
			}

			Console.WriteLine(" Press [enter] to exit.");
			Console.ReadLine();
		}
	}


声明队列是幂等的, 队列仅仅在它不存在的时候才被创建.(Alan: 如果队列A已经被声明过, 再次声明队列A, 只是简单地返回队列A, 并不会再创建一次队列A. 如果两次声明的队列A的名字相同, 其他参数不同, 那么第二次的队列声明会抛异常.)消息内容是字节数组, 所以你可以编码任何你想发送的东西.
当上面的代码结束运行, channel信道和连接都会被回收.
[这是完整的Send.cs类](http://github.com/rabbitmq/rabbitmq-tutorials/blob/master/dotnet/Send.cs)

发送无法正常执行!
如果你是第一次使用RabbitMQ, 而且看不到消息 "Sent", 你抓破头皮也想不出哪里出了问题. 也许是代理没有足够的磁盘空间开始执行(默认RabbitMQ需要至少50MB的空间), 因此RabbitMQ拒绝接收消息. 检查代理日志文件, 如果必要, 确认和降低限制. [配置文件文档](http://www.rabbitmq.com/configure.html#config-items)告诉你如果设置 `disk_free_limit`.

## Receiving

以上就是我们的发送者。我们的接受者从RabbitMQ接收消息，所以不像发布一条消息的发送者，我们需要保持接收者持续运行接收消息并打印出来。

receive.cs里的using语句几乎和send.cs一样：

	using RabbitMQ.Client;
	using RabbitMQ.Client.Events;
	using System;
	using System.Text;

 把它设置的河发送者一样；我们打开一个连接和通道，声明一个我们将要消费的队列。注意这里这个队列需要和send程序里的匹配。

	class Receive
	{
		public static void Main()
		{
			var factory = new ConnectionFactory() { HostName = "localhost" };
			using (var connection = factory.CreateConnection())
			{
				using (var channel = connection.CreateModel())
				{
					channel.QueueDeclare(queue: "hello",
										 durable: false,
										 exclusive: false,
										 autoDelete: false,
										 arguments: null);
					...
				}
			}
		}
	}

注意我们在这里也声明了那个队列。因为我们也许先于发送者程序启动接受者程序。

我们将会告诉服务器从那个队列递送消息给我们因为服务器会异步给我们推送消息，所以我们需要爱提供回调。这就是EventingBasicConsumer.Received事件所要处理的。

	using RabbitMQ.Client;
	using RabbitMQ.Client.Events;
	using System;
	using System.Text;

	class Receive
	{
		public static void Main()
		{
			var factory = new ConnectionFactory() { HostName = "localhost" };
			using(var connection = factory.CreateConnection())
			using(var channel = connection.CreateModel())
			{
				channel.QueueDeclare(queue: "hello",
									 durable: false,
									 exclusive: false,
									 autoDelete: false,
									 arguments: null);

				var consumer = new EventingBasicConsumer(channel);
				consumer.Received += (model, ea) =>
				{
					var body = ea.Body;
					var message = Encoding.UTF8.GetString(body);
					Console.WriteLine(" [x] Received {0}", message);
				};
				channel.BasicConsume(queue: "hello",
									 noAck: true,
									 consumer: consumer);

				Console.WriteLine(" Press [enter] to exit.");
				Console.ReadLine();
			}
		}
	}

[Receive.cs 源码](https://github.com/rabbitmq/rabbitmq-tutorials/blob/master/dotnet/Receive.cs)


## Putting It All Together

你可以引用RabbitMQ .NET库同时编译它们两个. 我们使用命令行(cmd.exe和csc)编译和运行代码。另外你也可以使用VS。

	$ csc /r:"RabbitMQ.Client.dll" Send.cs
	$ csc /r:"RabbitMQ.Client.dll" Receive.cs

然后运行可执行程序:

	$ Send.exe

然后运行接收者: 
	
	$ Receive.exe

接收者将会打印来自RabbitMQ发送者的消息。接收者将会保持运行，等待消息（使用Ctrl+C停止），所以试着从另一个终端运行发送者。

如果你想检查队列，可以尝试使用 `RabbitMQctl list_queues`.

是时候移步第二个教程建立简单工作队列了.


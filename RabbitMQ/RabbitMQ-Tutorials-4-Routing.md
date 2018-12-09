[英文原文](http://www.rabbitmq.com/tutorials/tutorial-four-dotnet.html)

# Routing

在[上一教程](./RabbitMQ-Tutorials-3-Publish-Subscribe.md)我们建立了简单的日志系统。我们能够向多个接收者广播日志消息。

在这个教程里我们将会继续给它添加特性：我们将会使仅仅订阅消息的某个子集成为可能。比如，我们能够严重错误的消息写入到日志文件（保存到磁盘空间），期间依然能够打印所有的日志消息到控制台。

## Bindings

 在上一个例子我们创建绑定。你也许像下面一样调用代码：

```csharp
channel.QueueBind(queue: queueName, exchange: "logs", routingKey: "");
```

绑定是交换器和队列之间的一种关系。可以简单的读作：某个队列对某个交换器的消息感兴趣。

绑定需要额外的`routingKey`参数。为了避免和一个BasicPublish的一个参数产生混乱我们把它称作binding key（绑定键）。下面是我们如何能够通过一个键创建绑定：

```csharp
channel.QueueBind(queue: queueName, exchange: "direct_logs", routingKey: "black");
```

这意味着绑定键依赖于交换器类型。我们之前使用的fanout交换器会简单地忽略这个值。

## Direct exchange

我们上一教程的日志系统广播所有的消息给所有的消费者。我们想扩展日志系统，允许基于它们的严重级别过滤消息。比如我们想让日志写入到磁盘的脚本仅接收严重错误的日志，不会浪费磁盘空间在warning和info级别的日志消息上。

我们正使用的fanout交换器并没有提供给我们过多的弹性扩展能力：它仅能胜任无脑的广播。

我们将使用direct交换器代替。direct交换器背后的路由算法是简单的：一个消息要到达一个队列，那么这个队列的绑定键（binding key）需要完全匹配消息的路由键（routing key）。

为了图解这个算法，考虑下面的组织：

![direct exchange](http://www.rabbitmq.com/img/tutorials/direct-exchange.png)

在上面的设置里，我们可以看到`direct`交换器类型x绑定了两个队列。第一个队列使用绑定键`orange`绑定，第二个有两个绑定, 其中一个绑定键是`black`, 另外一个绑定键是`green`.

在上述的配置里，一个路由键为orange的消息发布到交换器将会被路由到Q1队列。路由键为black和green的消息将会被路由到Q2。其他路由键的消息将会被丢弃。


## Multiple bindings

![multiple bindings](http://www.rabbitmq.com/img/tutorials/direct-exchge-multiple.png)

使用相同的绑定键绑定多个队列是完全合法的。在我们的例子里我们可以使用绑定键black在X和Q1之间添加绑定。这样direct交换器将会表现的和fanout类似，广播所有的消息到所有匹配的队列。路由键为black的消息将会被递送到Q1和Q2队列。

## Emitting logs

我们将会为我们的日志系统使用这个模型。我们将会发送消息到direct交换器取代fanout交换器。我们将会提供日志严重级别作为routing key。这样接收脚本就能够筛选它想接收的严重级别的日志。让我们先关注发送日志。

首先我们需要创建一个交换器：

	channel.ExchangeDeclare(exchange: "direct_logs", type: "direct");

然后我们准备发送消息：

	var body = Encoding.UTF8.GetBytes(message);
	channel.BasicPublish(exchange: "direct_logs",
						 routingKey: severity,
						 basicProperties: null,
						 body: body);

为了简单我们假设严重级别可以是info，warning，error中的一个。						

## Subscribing

接收消息就像上一教程里的接收异常信息那样运行，对于每一个我们感兴趣的日志级别我们将会创建一个新的绑定。

	var queueName = channel.QueueDeclare().QueueName;

	foreach(var severity in args)
	{
		channel.QueueBind(queue: queueName,
						  exchange: "direct_logs",
						  routingKey: severity);
	}

## Putting it all together

![putting it all together](http://www.rabbitmq.com/img/tutorials/python-four.png)

`EmitLogDirect.cs`代码如下：


	using System;
	using System.Linq;
	using RabbitMQ.Client;
	using System.Text;

	class EmitLogDirect
	{
		public static void Main(string[] args)
		{
			var factory = new ConnectionFactory() { HostName = "localhost" };
			using(var connection = factory.CreateConnection())
			using(var channel = connection.CreateModel())
			{
				channel.ExchangeDeclare(exchange: "direct_logs",
										type: "direct");

				var severity = (args.Length > 0) ? args[0] : "info";
				var message = (args.Length > 1)
							  ? string.Join(" ", args.Skip( 1 ).ToArray())
							  : "Hello World!";
				var body = Encoding.UTF8.GetBytes(message);
				channel.BasicPublish(exchange: "direct_logs",
									 routingKey: severity,
									 basicProperties: null,
									 body: body);
				Console.WriteLine(" [x] Sent '{0}':'{1}'", severity, message);
			}

			Console.WriteLine(" Press [enter] to exit.");
			Console.ReadLine();
		}
	}
	

`ReceiveLogsDirect.cs`代码如下：

	using System;
	using RabbitMQ.Client;
	using RabbitMQ.Client.Events;
	using System.Text;

	class ReceiveLogsDirect
	{
		public static void Main(string[] args)
		{
			var factory = new ConnectionFactory() { HostName = "localhost" };
			using(var connection = factory.CreateConnection())
			using(var channel = connection.CreateModel())
			{
				channel.ExchangeDeclare(exchange: "direct_logs",
										type: "direct");
				var queueName = channel.QueueDeclare().QueueName;

				if(args.Length < 1)
				{
					Console.Error.WriteLine("Usage: {0} [info] [warning] [error]",
											Environment.GetCommandLineArgs()[0]);
					Console.WriteLine(" Press [enter] to exit.");
					Console.ReadLine();
					Environment.ExitCode = 1;
					return;
				}

				foreach(var severity in args)
				{
					channel.QueueBind(queue: queueName,
									  exchange: "direct_logs",
									  routingKey: severity);
				}

				Console.WriteLine(" [*] Waiting for messages.");

				var consumer = new EventingBasicConsumer(channel);
				consumer.Received += (model, ea) =>
				{
					var body = ea.Body;
					var message = Encoding.UTF8.GetString(body);
					var routingKey = ea.RoutingKey;
					Console.WriteLine(" [x] Received '{0}':'{1}'",
									  routingKey, message);
				};
				channel.BasicConsume(queue: queueName,
									 noAck: true,
									 consumer: consumer);

				Console.WriteLine(" Press [enter] to exit.");
				Console.ReadLine();
			}
		}
	}


像往常一样编译代码（见第一篇教程的编译建议）: 

如果你只想保存warning和error（而不是info）级别的日志消息到文件，只需要打开控制台并键入：

	$ ReceiveLogsDirect.exe warning error > logs_from_rabbit.log

如果你想在显示器上查看所有的日志消息，打开一个新的终端并如下操作：

	$ ReceiveLogsDirect.exe info warning error
	 [*] Waiting for logs. To exit press CTRL+C

然后，比如发送一个error日志消息：

	$ EmitLogDirect.exe error "Run. Run. Or it will explode."
	 [x] Sent 'error':'Run. Run. Or it will explode.'

[EmitLogDirect.cs source](http://github.com/rabbitmq/rabbitmq-tutorials/blob/master/dotnet/EmitLogDirect.cs) [ReceiveLogsDirect.cs source](http://github.com/rabbitmq/rabbitmq-tutorials/blob/master/dotnet/ReceiveLogsDirect.cs)

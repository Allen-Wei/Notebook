[英文原文](http://www.rabbitmq.com/tutorials/tutorial-five-dotnet.html)

# Topics

在上一教程我们改进了我们的日志系统。我们使用一个direct交换器，取代了使用只能广播消息的fanout交换器，获得了有选择接收日志消息的能力。

虽然使用direct交换器改进了我们的系统，但它依然有限制：它不能给予多种标准路由消息。

在我们的日志系统里，我们也许不仅想基于日志级别订阅消息，还想基于日志来源订阅消息。你也许从unix的syslog工具中知道这个概念，它路由消息基于两个：级别（info/waen/crit……）和来源（auth/waen/kern……）。

那将会使我们的日志系统更具弹性：我们也许想监听从corn来的critical级别的错误以及从kern来的所有日志。

为了在我们的日志系统里实现这个，我们需要学习更复杂的topic交换器。

## Topic exchange

发送到topic交换器的消息的routing_key不能是一个随意的值：它必须是一个单词的列表，用点号划分。单词可以是任意的，但是通常他们指出了所连接的消息的某些特点。一些有效的routing_key例子：stock.usd.nyse，nude.vmw，quick.orange.rabbit。只要你喜欢，roungting key（路由键）可以包含很多单词，最大到255个字节。

绑定键也必须是相同的形式。topic交换器背后的逻辑和direct的类似：一个带有特定路由键的消息将会被递送到所有和队列的绑定键匹配的队列。但是对于绑定键有两个重要的特殊情况：

"*"（星）可以取代一个单词。
"#"（哈希）可以代替零个或多个单词

下面的例子很容易地解释了两个特殊情况：

![special character](http://www.rabbitmq.com/img/tutorials/python-five.png)

在这个例子中，我们将会发送描述动物的消息。这些消息将会被发送，并且带有有三个单词（两个点）组成的路由键。路由键中的第一个单词描述速度，第二个描述颜色，第三个描述物种：`"<speed>.<colour>.<species>"`。

.我们创建了三个绑定：Q1使用"*.*.rabbit"绑定键绑定，Q2使用"*.*.rabbitmq"和"lazy.#"两个绑定键绑定。

这些绑定键可以被总结如下：

Q1 对所有橘色的动物感兴趣。

Q2想收到所有关于兔子的消息，和所有速度慢的动物的消息。

路由键集为`"quick.orange.rabbit"`的消息将会被递送到两个队列。。路由键为`"lazy.orange.elephant"`的消息也会被递送到两个队列。但是（On the other hand居然还有但是的意思），`"quick.orange.fox"`仅会被递送到第一个队列，`"lazy.brown.fox"`仅会被递送到第二个队列。`"lazy.pink.rabbit"`仅会被递送到第二个队列一次，即使它匹配了两个绑定。`"quick.brown.fox"`没有匹配任何队列，所以它会被丢弃。

如果我们打破我们的约定，发送的消息的路由键只有一个或者四个单词（比如`"orange"`或者`"quick.orange.male.rabbit"`）会怎样？嗯，这些消息没有匹配任何绑定，将会被丢弃。

但是对于`"lazy.orange.male.rabbit"`，即使它有四个单词，也将会匹配最后一个绑定，消息将会被递送到第二个队列。

Note:

topic交换器很强大，并且能够表现的像其他交换器。

当一个队列使用"#"(hash)作为绑定键，不管消息的路由键是什么，它（队列）都将接收所有的消息，就像`fanout`交换器一样。

当绑定时没有使用特殊字符"*"(start)和"#"(hash)，topic交换器的行为就像一个direct交换器。

## Putting it all together

我们将会在我们的日志系统里使用使用topic交换器。我们开始之前先假设日志的路由键有两个单词：`<facility>.<serity>`。

代码几乎和上一个教程的一样。

`EmitLog.cs`代码如下：

	using System;
	using System.Linq;
	using RabbitMQ.Client;
	using System.Text;

	class EmitLogTopic
	{
		public static void Main(string[] args)
		{
			var factory = new ConnectionFactory() { HostName = "localhost" };
			using(var connection = factory.CreateConnection())
			using(var channel = connection.CreateModel())
			{
				channel.ExchangeDeclare(exchange: "topic_logs",
										type: "topic");

				var routingKey = (args.Length > 0) ? args[0] : "anonymous.info";
				var message = (args.Length > 1)
							  ? string.Join(" ", args.Skip( 1 ).ToArray())
							  : "Hello World!";
				var body = Encoding.UTF8.GetBytes(message);
				channel.BasicPublish(exchange: "topic_logs",
									 routingKey: routingKey,
									 basicProperties: null,
									 body: body);
				Console.WriteLine(" [x] Sent '{0}':'{1}'", routingKey, message);
			}
		}
	}

`ReceiveLogsTopic.cs`代码如下：


	using System;
	using RabbitMQ.Client;
	using RabbitMQ.Client.Events;
	using System.Text;

	class ReceiveLogsTopic
	{
		public static void Main(string[] args)
		{
			var factory = new ConnectionFactory() { HostName = "localhost" };
			using(var connection = factory.CreateConnection())
			using(var channel = connection.CreateModel())
			{
				channel.ExchangeDeclare(exchange: "topic_logs", type: "topic");
				var queueName = channel.QueueDeclare().QueueName;

				if(args.Length < 1)
				{
					Console.Error.WriteLine("Usage: {0} [binding_key...]",
											Environment.GetCommandLineArgs()[0]);
					Console.WriteLine(" Press [enter] to exit.");
					Console.ReadLine();
					Environment.ExitCode = 1;
					return;
				}

				foreach(var bindingKey in args)
				{
					channel.QueueBind(queue: queueName,
									  exchange: "topic_logs",
									  routingKey: bindingKey);
				}

				Console.WriteLine(" [*] Waiting for messages. To exit press CTRL+C");

				var consumer = new EventingBasicConsumer(channel);
				consumer.Received += (model, ea) =>
				{
					var body = ea.Body;
					var message = Encoding.UTF8.GetString(body);
					var routingKey = ea.RoutingKey;
					Console.WriteLine(" [x] Received '{0}':'{1}'",
									  routingKey,
									  message);
				};
				channel.BasicConsume(queue: queueName,
									 noAck: true,
									 consumer: consumer);

				Console.WriteLine(" Press [enter] to exit.");
				Console.ReadLine();
			}
		}
	}

运行下面的例子：

接收所有的日志消息：

	$ ReceiveLogsTopic.exe "#"

接收所有来自`"kern"`的日志消息：

	$ ReceiveLogsTopic.exe "kern.*"

或者仅仅接收`"critical"`级别的日志消息：

	$ ReceiveLogsTopic.exe "*.critical"

你可以创建多个绑定：

	$ ReceiveLogsTopic.exe "kern.*" "*.critical"

然后发送一条路由键为kern.critical的日志消息：

	$ EmitLogTopic.exe "kern.critical" "A critical kernel error"

执行这些程序很有趣。这些代码对路由键或者绑定键没有做任何假设，你也许想发送路由键参数超过两个单词的消息。

一些尝试：

"*" 绑定键会会捕获任何路由键为空的消息吗？

"#.*" 绑定键会捕获路由键为".."的消息吗？它会捕获路由键只有单个单词的消息吗？

"a.*.#"和"a.#"有怎样的区别？

[EmitLogTopic.cs](http://github.com/rabbitmq/rabbitmq-tutorials/blob/master/dotnet/EmitLogTopic.cs) 和 [ReceiveLogsTopic.cs](http://github.com/rabbitmq/rabbitmq-tutorials/blob/master/dotnet/ReceiveLogsTopic.cs) 源码


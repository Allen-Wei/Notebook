[英文原文](http://www.rabbitmq.com/tutorials/tutorial-three-dotnet.html)

# Publish/Subscribe

在上一个教程我们创建了工作队列。上一个工作队列假设每一个任务被递送到一个确切的工作者线程。这一章节我们的做法完全不同：我们把一条消息递送给多个消费者。这种模式被称为“发布/订阅”。

为了图解这个模式，我们会创建一个简单的日志系统。这会常驻两个程序：第一个发布日志消息，第二个将会接收日志消息并打印出来。

在我们的日志系统中，每一个运行接收程序的副本都会得到这些消息。以这种方式，我们能够运行一个接收程序直接将日志写入到到磁盘，同时我们能够运行另外一个人接收程序打印日志到显示器上。

本质上，发布的日志消息将会被广播给所有的接收者。

## Exchanges

在教程的上一部分，我们从一个队列发送和接收消息。现在是时候介绍RabbitMQ 里完全的消息模型了

让我们快速浏览我们在之前的教程里覆盖的内容：

* *生产者*是一个发送消息的用户应用。
* *队列*是存储消息的缓冲区
* *消费者*是一个接收消息的用户程序。

RabbitMQ的消息模型的核心思想是生产者从不直接发送任何消息到一个队列。实际上，生产者甚至不知道消息有可能不会递送到任何队列。

相反，生产者仅仅发送消息到交换器。交换器是非常简单的东西。交换器一边从生产者那里接受消息，另一边把消息发送到队列。交换器必须确切地知道它接收到的消息要做什么。是应该追加到一个特定的队列？或者是把消息丢弃。采取什么样的规则是由交换器类型定义的。

![pub sub 1](http://www.rabbitmq.com/img/tutorials/exchanges.png)

有一些可用的交换器类型：direct，topic，headers和fanout。我们将关注最后一个: fanout. 让我们创建一个这个类型的交换器, 叫做`logs`.

	channel.ExchangeDeclare("logs", "fanout");

fanout交换器非常简单。因为你从名字可能就猜到，它会广播接收到的所有消息给所有的队列。这就是我们的日志系统所需要的。


列出交换器

可以运行`rabbitmqctl`列出服务器上的所有交换器：

	$ sudo rabbitmqctl list_exchanges
	Listing exchanges ...
			direct
	amq.direct      direct
	amq.fanout      fanout
	amq.headers     headers
	amq.match       headers
	amq.rabbitmq.log        topic
	amq.rabbitmq.trace      topic
	amq.topic       topic
	logs    fanout
	...done.

在上面的列表里有一些`amq.*`交换器和一个默认（未命名）的交换器。这些是系统默认创建的，但这不像你等会将会使用的。

缺省名字的交换器

在教程的上一部分，我们不知道交换器，但是我们能够给队列发送消息。那是可能的，因为我们使用了默认交换器，即我们用空字符串标识的。

重新看一下之前我们如何发布一条消息：

	var message = GetMessage(args);
	var body = Encoding.UTF8.GetBytes(message);
	channel.BasicPublish(exchange: "",
						 routingKey: "hello",
						 basicProperties: null,
						 body: body);

第一个参数是交换器的名字，空字符串表示默认或未命名交换器：消息会被路由到路由键名指定的队列，如果这个人队列存在。

现在我们可以使用我们的命名交换器来代替：

	var message = GetMessage(args);
	var body = Encoding.UTF8.GetBytes(message);
	channel.BasicPublish(exchange: "logs",
						 routingKey: "",
						 basicProperties: null,
						 body: body);


## Temporary queues						 

你也许还记得之前我们使用指定名字的队列（还记得`hello`和`task_queue`吗？）。能够命名一个队列对我们来说是重要的：我们需要把工作者指向相同的队列（工作者使用相同的队列名来接收消息）。所以当你想在生产者和消费者之间共享队列的时候，给队列起个名字是重要的。

但这不是我们的日志系统所使用的案例。我们需要接收所有的日志消息，不仅仅是它们中的部分。我们只对当前流里的消息感兴趣，而不是之前的消息。为了解决这个需求，我们需要做两件事。

第一，无论我们何时连接到rabbit，我们需要刷新清空队列。为了做到这一点，我们应该使用随机名来创建队列，或者，更好的做法是让服务器为我们选择一个随机名字。

第二，一旦我们断开与消费者的连接，队列应该自动被删除。

在.NET客户端，当我们使用无参的`QueueDeclare()`时，我们便创建了非持久化，私有的，自动删除的，带有随机名字的队列：

	var queueName = channel.QueueDeclare().QueueName;

此時`queueName`包含了一个随机的队列名字。它看起来可能像`amq.gen-JzTY20BRgKO-HjmUJj0wLg`.

## Bindings

![Binding](http://www.rabbitmq.com/img/tutorials/bindings.png)

我们已经创建了一个fanout交换器和一个队列。现在我们需要告诉告诉交换器想我们的队列发送消息。交换器和队列之间的这种关系被称为*绑定*。

> 列出所有绑定
> 你可以使用 `rabbitmqctl list_bindings` 列出所有绑定.

## Putting it all together

![putting it all together](http://www.rabbitmq.com/img/tutorials/python-three-overall.png)

发送日志消息的生产者程序和上一个教程没有多大区别。最重要的改变是我们现在发布消息到我们的`logs`交换器，来取代没有提供名字的交换器。当发送消息时我们需要提供`routingKey`参数，但是这个值会被`fanout`交换器忽略。

 这是`EmitLog.cs`的代码：

	using System;
	using RabbitMQ.Client;
	using System.Text;

	class EmitLog
	{
		public static void Main(string[] args)
		{
			var factory = new ConnectionFactory() { HostName = "localhost" };
			using(var connection = factory.CreateConnection())
			using(var channel = connection.CreateModel())
			{
				channel.ExchangeDeclare(exchange: "logs", type: "fanout");

				var message = GetMessage(args);
				var body = Encoding.UTF8.GetBytes(message);
				channel.BasicPublish(exchange: "logs",
									 routingKey: "",
									 basicProperties: null,
									 body: body);
				Console.WriteLine(" [x] Sent {0}", message);
			}

			Console.WriteLine(" Press [enter] to exit.");
			Console.ReadLine();
		}

		private static string GetMessage(string[] args)
		{
			return ((args.Length > 0)
				   ? string.Join(" ", args)
				   : "info: Hello World!");
		}
	}

[EmitLog.cs source](http://github.com/rabbitmq/rabbitmq-tutorials/blob/master/dotnet/EmitLog.cs)


就像你看到的，建立了连接之后我们声明了交换器。这一步时必须的，因为禁止向一个不存在的交换器发布消息。

如果没有队列绑定到交换器，消息是会丢失的，但这对我们来说是没问题的。如果还没有消费者监听消息，我们可以安全地丢弃消息。

`ReceiveLogs.cs`代码：

	using System;
	using RabbitMQ.Client;
	using RabbitMQ.Client.Events;
	using System.Text;

	class ReceiveLogs
	{
		public static void Main()
		{
			var factory = new ConnectionFactory() { HostName = "localhost" };
			using(var connection = factory.CreateConnection())
			using(var channel = connection.CreateModel())
			{
				channel.ExchangeDeclare(exchange: "logs", type: "fanout");

				var queueName = channel.QueueDeclare().QueueName;
				channel.QueueBind(queue: queueName,
								  exchange: "logs",
								  routingKey: "");

				Console.WriteLine(" [*] Waiting for logs.");

				var consumer = new EventingBasicConsumer(channel);
				consumer.Received += (model, ea) =>
				{
					var body = ea.Body;
					var message = Encoding.UTF8.GetString(body);
					Console.WriteLine(" [x] {0}", message);
				};
				channel.BasicConsume(queue: queueName,
									 noAck: true,
									 consumer: consumer);

				Console.WriteLine(" Press [enter] to exit.");
				Console.ReadLine();
			}
		}
	}


[ReceiveLogs.cs source](http://github.com/rabbitmq/rabbitmq-tutorials/blob/master/dotnet/ReceiveLogs.cs)

 编译我们之前所做的：

	$ csc /r:"RabbitMQ.Client.dll" EmitLogs.cs
	$ csc /r:"RabbitMQ.Client.dll" ReceiveLogs.cs

如果你想保存日志到一个文件，只需要打开控制台，键入：

	$ ReceiveLogs.exe > logs_from_rabbit.log

如果你想在你的显示器上看到日志，打开一个新的控制台：

	$ ReceiveLogs.exe

当然了，发布消息键入：

	$ EmitLog.exe

使用rabbitmqctl list_bindings你可以验证代码确实如我们所想创建了队列和绑定。通过两个运行的ReceiveLos.cs程序，你可以看到类似于下面的东西：

	$ sudo rabbitmqctl list_bindings
	Listing bindings ...
	logs    exchange        amq.gen-JzTY20BRgKO-HjmUJj0wLg  queue           []
	logs    exchange        amq.gen-vso0PVvyiRIL2WoV3i48Yg  queue           []
	...done.

结果显示的很直白：从logs交换器来的数据传递给两个服务器命名的队列。

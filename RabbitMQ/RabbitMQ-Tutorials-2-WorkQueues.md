[英文原文](http://www.rabbitmq.com/tutorials/tutorial-two-dotnet.html)

# Work Queues

在[第一篇教程](https://github.com/Allen-Wei/GitBlog/blob/master/RabbitMQ/RabbitMQ-Tutorials-1-HelloWorld.md)里，我们写了从已命名队列发送和接收消息的程序。在这篇教程里，我们将创建工作队列在多个工作者上分发耗时任务。

工作队列（也称任务队列）的主要目的是避免立即执行资源密集型任务而且必须等待完成。相反我们推迟任务执行。我们把一个任务封装成消息，发送到一个队列。一个工作者进程在后台完成任务。当你运行多个工作者进程时，任务会被在他们之间共享。

上面描述的概念，在短暂的HTTP请求期间可能要处理复杂任务的Web程序里尤其有用。

## Preparation

在这个教程的上一部分，我们发送了包含“hello world”的消息。现在我们将要发送代表复杂任务的字符串。 我们没有真实环境的任务，比如图片尺寸处理或者pdf文件渲染，所以我们使用Thread.Sleep来模拟我们很忙的意图。我们用字符串中的点表示复杂度，每一个点代表一秒的工作量。比如我们使用 `Hello...` 模拟任务，就代表三秒钟的任务。

我们从我们之前的例子里稍微修改一下Send.cs代码，允许从命令行发送任意消息。这个程序将会计划任务到我们的队列里，所以让我们把它命名为 `NewTsk.cs`:

	var message = GetMessage(args);
	var body = Encoding.UTF8.GetBytes(message);

	var properties = channel.CreateBasicProperties();
	properties.SetPersistent(true);

	channel.BasicPublish(exchange: "",
						 routingKey: "task_queue",
						 basicProperties: properties,
						 body: body);

一个从命令行参数获取信息的实用方法:

	private static string GetMessage(string[] args)
	{
		return ((args.Length > 0) ? string.Join(" ", args) : "Hello World!");
	}

我们的 *Receive.cs* 也需要做一些修改：它需要为消息内容里的每个点模拟一秒钟的工作量。它会处理经由RabbitMQ递送的消息和执行任务，所以让我们叫做 `Worker.cs` :

	var consumer = new EventingBasicConsumer(channel);
	consumer.Received += (model, ea) =>
	{
		var body = ea.Body;
		var message = Encoding.UTF8.GetString(body);
		Console.WriteLine(" [x] Received {0}", message);

		int dots = message.Split('.').Length - 1;
		Thread.Sleep(dots * 1000);

		Console.WriteLine(" [x] Done");

		channel.BasicAck(deliveryTag: ea.DeliveryTag, multiple: false);
	};
	channel.BasicConsume(queue: "task_queue", noAck: false, consumer: consumer);

我们的伪装任务使用以下代码模拟执行时间：

	int dots = message.Split('.').Length - 1;
	Thread.Sleep(dots * 1000);

像教程一那样编译它们：

	$ csc /r:"RabbitMQ.Client.dll" NewTask.cs
	$ csc /r:"RabbitMQ.Client.dll" Worker.cs

## Round-robin dispatching

使用任务队列的其中一个优点就是很容易就能进行并行任务。如果我们需要创建一个后台日志，我们只需要添加更多的工作者进程，极其容易。

首先，我们试着在相同的时间运行两个`Worker.cs`脚本，它们两个都会从队列中获取消息，但是确切是怎样的呢？让我们看看：

你需要打开三个控制台，两个运行`Worker.cs`脚本，这两个就是我们的两个消费者 C1和C2.

	shell1$ Worker.exe
	Worker
	 [*] Waiting for messages. To exit press CTRL+C
	shell2$ Worker.exe
	Worker
	 [*] Waiting for messages. To exit press CTRL+C

在第三个控制台 我们发布消息。一旦你开始了消费者进程，你就可以发布消息了：

	shell3$ NewTask.exe First message.
	shell3$ NewTask.exe Second message..
	shell3$ NewTask.exe Third message...
	shell3$ NewTask.exe Fourth message....
	shell3$ NewTask.exe Fifth message.....

让我们看看都有什么到达了我们的工作者进程: 

	shell1$ Worker.exe
	 [*] Waiting for messages. To exit press CTRL+C
	 [x] Received 'First message.'
	 [x] Received 'Third message...'
	 [x] Received 'Fifth message.....'
	shell2$ Worker.exe
	 [*] Waiting for messages. To exit press CTRL+C
	 [x] Received 'Second message..'
	 [x] Received 'Fourth message....'

RabbitMQ默认会发送每一个消息给下一个队列中的消费者。平均每个消费者都能获取相同数量的消息。这种分发消息的方式叫round-robin. 尝试三个或更多的工作者进程。


## Message acknowledgment

完成一个任务只需数秒。你也许想知道如果其中一个消费者进程开始一个耗时任务，在仅部分完成的时候死去了会发生什么。对于我们当前的代码，一旦RabbitMQ将消息递送到消费者，就会立即将消息从内存中移除。在这种情况下，如果你杀死一个工作者进程，你就会丢失那条消息。我们也会丢失所有分发到这个工作者进程但尚未处理的消息。

不过我们不想丢失任何任务。如果一个工作者进程死去，我们希望这个任务被递送到其他工作者进程。

为了保证消息不会丢失，RabbitMQ支持消息确认。消费者发送回一个消息确认，告诉RabbitMQ指定的消息被接收，处理，RabbitMQ可以自由删除那条消息了。

如果一个消费者没有发送消息确认就死去（比如信道被关闭，连接被关闭，或者TCP连接丢失），RabbitMQ便知道消息没有被完全处理，然后会重新加入队列。此时，如果有其他的消费者在线，RabbitMQ很快重新递送消息给其他消费者了。这样你就可以确保没有消息会丢失，甚至工作者进程偶尔会死去。

没有消息会超时。当消费者死去的时候，RabbitMQ会重新递送消息。这是非常好的设计，即便消息处理花费了很长很长的时间。

消息确认默认是开启的。在上一个例子中，我们通过设置参数noAck(非手动确认)的值为true显式地关闭了消息确认功能。一旦我们完成任务，需要移除这个标示，从工作者进程发送一个恰当的确认。

	var consumer = new EventingBasicConsumer(channel);
	consumer.Received += (model, ea) =>
	{
		var body = ea.Body;
		var message = Encoding.UTF8.GetString(body);
		Console.WriteLine(" [x] Received {0}", message);

		int dots = message.Split('.').Length - 1;
		Thread.Sleep(dots * 1000);

		Console.WriteLine(" [x] Done");

		channel.BasicAck(deliveryTag: ea.DeliveryTag, multiple: false);
	};
	channel.BasicConsume(queue: "task_queue", noAck: false, consumer: consumer);

使用这段代码我们可以确保即便我们在工作者进程处理消息的时候使用Ctrl+C杀死了工作者进程，也不会有东西丢失。在工作者进程死去后，所有未确认的消息很快会被重新投递分发。

Note: 
忘记调用BasicAck是一个常见的错误，这是一个很简单的错误，但对于并发来说是很严重的错误。当你的客户端退出时消息会被重新递送（这看起来像是随机递送），但是RabbitMQ将会吃掉越来越多的内存，因为RanbitMQ不能释放任何未被确认的消息。

为了调试这种类型的错误，你可以使用RabbitMQctl打印messeages_unacknowledged字段：

	$ sudo rabbitmqctl list_queues name messages_ready messages_unacknowledged
	Listing queues ...
	hello    0       0
	...done.


## Message durability

我们学习了如何确保任务不会丢失，即便消费者进程死去。但是如果RabbitMQ服务器停止我们任务仍会丢失。

 当RabbitMQ 退出或者崩溃时会忘记队列和消息，除非你告诉RabbitMQ 不要这样做。确保消息不会丢失需要确保两件事：我们需要让消息和队列持久化。

 首先我们要确保RabbitMQ 不会丢失我们的队列，为此，我们需要讲队列声明称可持久化的：

	channel.QueueDeclare(queue: "hello",
                     durable: true,
                     exclusive: false,
                     autoDelete: false,
                     arguments: null);

虽然这个命令本身是正确的，但是在我们当前的设置里它不会工作。那是因为我们已经定义了一个未持久化的名为`hello`的队列。

RabbitMQ 不允许我们使用不同的参数重定义一个已经存在的队列，而且如果程序试着这么做了RabbitMQ 会返回一个错误。但是有一个便捷的替代方案 声明一个不同名字的队列，比如`task_queue`:

	channel.QueueDeclare(queue: "task_queue",
                     durable: true,
                     exclusive: false,
                     autoDelete: false,
                     arguments: null);


队列声明的改变需要在生产者和消费者的代码中同时应用这个改变。

此刻我们可以确保task_queue队列不会丢失即使RabbitMQ重启了。现在我们需要让我们的消息持久化 — 通过把`IBasicProperties.SetPersistent`设置成`true`.

	var properties = channel.CreateBasicProperties();
	properties.SetPersistent(true);

Note:
关于消息持久化

让消息持久化并不能保证消息不会丢失。虽然持久化消息会告诉RabbitMQ把消息保存到硬盘，但是依然有RabbitMQ接收消息但未能保存消息的短时窗口期。RabbitMQ 也不会为每个消息执行`fsync(2)`，这就仅仅是被保存到缓存而不是真正地写入到硬盘。这样确保持久化并不强壮，但是这对于我们简单的任务队列来说已经足够了。如果你需要更强壮的消息保证，你可以使用**发布者确认**。


## Fair dispatch 公平分发

你也许已经注意到分发还不能像你想要的那样工作。比如在有两者工作者进程的情况，当所有的奇数消息的工作量很大，偶数消息是轻量简单的，那么一个工作者进程常常是忙碌的，而另一个工作者进程几乎不会做任何工作。嗯，对于这种情况，RabbitMQ一点都不知道，将会一直这样平均地分发消息。

 导致这样的事情是因为当消息进入队列时，RabbitMQ 只是分发消息。它不会根据每个消费者未确认消息数量来分发消息，而是盲目地将第N个消息发送给第N的消费者。

 ![fair dispatch](http://www.rabbitmq.com/img/tutorials/prefetch-count.png)

为了避免这种情况，我们可以使用`basicQos`方法把`prefetchCount`设置成`1`。这会告诉RabbitMQ一次不要给工作者进程超过一条消息。或者，换句话说，直到工作者进程处理并确认上一条消息之前不要再给这个工作者进程分发新的消息。相反，RabbitMQ会把消息发送到下一个不忙碌的工作者进程。

	channel.BasicQos(0, 1, false);

> 关于队列大小
> 如果所有的工作者进程都忙碌，你的队列可能会塞满消息。你可能需要监视堵塞，然后可能需要添加更多的工作者进程，或者使用一些其他的策略。


## Putting it all together

`NewTask.cs`类最终代码:

	using System;
	using RabbitMQ.Client;
	using System.Text;

	class NewTask
	{
		public static void Main(string[] args)
		{
			var factory = new ConnectionFactory() { HostName = "localhost" };
			using(var connection = factory.CreateConnection())
			using(var channel = connection.CreateModel())
			{
				channel.QueueDeclare(queue: "task_queue",
									 durable: true,
									 exclusive: false,
									 autoDelete: false,
									 arguments: null);

				var message = GetMessage(args);
				var body = Encoding.UTF8.GetBytes(message);

				var properties = channel.CreateBasicProperties();
				properties.SetPersistent(true);

				channel.BasicPublish(exchange: "",
									 routingKey: "task_queue",
									 basicProperties: properties,
									 body: body);
				Console.WriteLine(" [x] Sent {0}", message);
			}

			Console.WriteLine(" Press [enter] to exit.");
			Console.ReadLine();
		}

		private static string GetMessage(string[] args)
		{
			return ((args.Length > 0) ? string.Join(" ", args) : "Hello World!");
		}
	}

[NewTask.cs soruce](http://github.com/rabbitmq/rabbitmq-tutorials/blob/master/dotnet/NewTask.cs)

`Worker.cs` 代码:

	using System;
	using RabbitMQ.Client;
	using RabbitMQ.Client.Events;
	using System.Text;
	using System.Threading;

	class Worker
	{
		public static void Main()
		{
			var factory = new ConnectionFactory() { HostName = "localhost" };
			using(var connection = factory.CreateConnection())
			using(var channel = connection.CreateModel())
			{
				channel.QueueDeclare(queue: "task_queue",
									 durable: true,
									 exclusive: false,
									 autoDelete: false,
									 arguments: null);

				channel.BasicQos(prefetchSize: 0, prefetchCount: 1, global: false);

				Console.WriteLine(" [*] Waiting for messages.");

				var consumer = new EventingBasicConsumer(channel);
				consumer.Received += (model, ea) =>
				{
					var body = ea.Body;
					var message = Encoding.UTF8.GetString(body);
					Console.WriteLine(" [x] Received {0}", message);

					int dots = message.Split('.').Length - 1;
					Thread.Sleep(dots * 1000);

					Console.WriteLine(" [x] Done");

					channel.BasicAck(deliveryTag: ea.DeliveryTag, multiple: false);
				};
				channel.BasicConsume(queue: "task_queue",
									 noAck: false,
									 consumer: consumer);

				Console.WriteLine(" Press [enter] to exit.");
				Console.ReadLine();
			}
		}
	}


[Worker.cs](http://github.com/rabbitmq/rabbitmq-tutorials/blob/master/dotnet/Worker.cs)

使用消息确认和 `BasicQos` 你可以对工作队列进行设置。持久化选项让任务在RabbitMQ重启之后也能存活。

你可以浏览 [RabbitMQ .NET API](http://www.rabbitmq.com/releases/rabbitmq-dotnet-client/v3.2.2/rabbitmq-dotnet-client-3.2.2-client-htmldoc/html/index.html) 在线参考资料 来获取更多关于IModel方法和IBasicProperties的信息。

现在我们继续第三篇教程，学习如何想多个消费者递送相同的消息。

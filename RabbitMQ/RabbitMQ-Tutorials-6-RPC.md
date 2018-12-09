[英文原文](http://www.rabbitmq.com/tutorials/tutorial-six-dotnet.html)

# Remote procedure call (RPC)

在第二个教程里我们学习了如何使用工作队列在多个工作者进程之间分发耗时任务。

但是如果我们需要在远程计算机上运行一个函数并等待结果该如何做呢？嗯，这种事完全不同的使用场景。这种模式通常被称作远程处理调用（Remote Procedure Call）或者简称RPC。

在这个教程里我们将会使用RabbitMQ建立RPC系统：一个客户端和一个可伸缩的RPC服务器。因为我们没有值得分发的耗时任务，所以我们将会创建一个返回斐波那契数的虚拟RPC服务。

## Client interface

为了展示如何使用一个RPC服务我们将会创建一个简单的客户端。它将会暴露一个名为call的方法，这个方法发送一个RPC请求并且阻塞直到接收到答案（响应）：


	var rpcClient = new RPCClient();

	Console.WriteLine(" [x] Requesting fib(30)");
	var response = rpcClient.Call("30");
	Console.WriteLine(" [.] Got '{0}'", response);

	rpcClient.Close();


Note:

虽然RPC是一个用于计算的常见模式，但它常常是危险的。当一个程序员没有意识到函数调用是否是本地时或者是一个很慢的RPC调用时问题就会产生。

解决上面的缺陷，考虑以下建议：

搞明白哪个函数是本地调用，哪一个是远程调用。

组织你的系统。让组件之间的依赖保持清晰。

错误处理情况。当RPC服务器长时间罢工客户端应该怎么反应？

当上述问题不清楚时避免使用RPC。如果你搞明白了，你应该使用一个阻塞的异步管道取代RPC，结果被异步推送到下一个计算阶段。

## Callback queue

通常通过RabbitMQ执行RPC调用是容易的。一个客户端发送一个请求消息，服务器端回复响应消息。为了能够接受响应我们需要发送一个带有“callback”队列地址的请求。


	var corrId = Guid.NewGuid().ToString();
	var props = channel.CreateBasicProperties();
	props.ReplyTo = replyQueueName;
	props.CorrelationId = corrId;

	var messageBytes = Encoding.UTF8.GetBytes(message);
	channel.BasicPublish(exchange: "",
						 routingKey: "rpc_queue",
						 basicProperties: props,
						 body: messageBytes);

	// ... then code to read a response message from the callback_queue ...


Note:
消息属性

AMQP协议给消息预先定义了14个属性集。大部分消暑极少使用，下面几个例外（下面几个常用）：

`deliveryMode`: 使消息持久化（值为2）或者短暂的（发后即忘模式，其他任意值）。你也许还记得第二个教程里提到的这个属性。

`contentType`: 用于描述编码的mime-type。比如对于常用的JSON编码设置属性值为application/json是一个好的实践。

`replyTo`: 一般用于命名回调队列。

`correlationId`: 常用于关联RPC请求等待响应。

## Correlation Id

在上面发送请求之前的方法里，我们建议为每一个RPC请求创建一个回调队列。那是非常低效的。幸运的是有一个更好的办法：让我们创建单个回调队列每客户端。

这会产生新的问题，响应不清楚是哪个队列发出的请求。这时候需要使用correlationId属性。我们打算把每个请求的correlationId设置成唯一值。之后，我们在回调队列里接收一条消息，我们将会查看这个属性，然后基于这个属性我们能够匹配这个请求的响应。如果我们看到一个位置的correlationId值，我们可以安全地丢弃消息，这条消息不属于我们的请求。

You may ask, why should we ignore unknown messages in the callback queue, rather than failing with an error? It's due to a possibility of a race condition on the server side. Although unlikely, it is possible that the RPC server will die just after sending us the answer, but before sending an acknowledgment message for the request. If that happens, the restarted RPC server will process the request again. That's why on the client we must handle the duplicate responses gracefully, and the RPC should ideally be idempotent. 你也许会问为什么我们在回调队列里忽略未知消息，而不是引发一个错误然后失败。

## Summary

![summary](http://www.rabbitmq.com/img/tutorials/python-six.png)

我们的RPC像这样工作：

当我们的客户端启动时，它会创建一个匿名排他的回调队列。 

对于每一个RPC请求，客户端发送的消息都带有两个属性：replayTo，用来标识回调队列，correlationId，为每一次请求设置唯一标识。

请求被发送到一个`rpc_queue`队列。

RPC工作线程（也称作服务器）等待那个队列（rpc_queue）的请求。当请求出现，RPC工作线程开始执行作业并且把作业的结果以消息的形式使用replyTo字段发回客户端，

客户端在回调队列里等待数据。当消息出现，客户端检查`correlationId`属性。如果这个属性值和请求里的值匹配，它就会把这个响应返回给应用。


## Putting it all together

斐波那契任务:

	private static int fib(int n)
	{
		if (n == 0 || n == 1) return n;
		return fib(n - 1) + fib(n - 2);
	}

我们声明我们的斐波那契函数。假设只有正整数有效。（不要这个函数对大数能工作，这可能是最慢的递归实现）。

 RPC server的代码如下：

	using System;
	using RabbitMQ.Client;
	using RabbitMQ.Client.Events;
	using System.Text;

	class RPCServer
	{
		public static void Main()
		{
			var factory = new ConnectionFactory() { HostName = "localhost" };
			using(var connection = factory.CreateConnection())
			using(var channel = connection.CreateModel())
			{
				channel.QueueDeclare(queue: "rpc_queue",
									 durable: false,
									 exclusive: false,
									 autoDelete: false,
									 arguments: null);
				channel.BasicQos(0, 1, false);
				var consumer = new QueueingBasicConsumer(channel);
				channel.BasicConsume(queue: "rpc_queue",
									 noAck: false,
									 consumer: consumer);
				Console.WriteLine(" [x] Awaiting RPC requests");

				while(true)
				{
					string response = null;
					var ea = (BasicDeliverEventArgs)consumer.Queue.Dequeue();

					var body = ea.Body;
					var props = ea.BasicProperties;
					var replyProps = channel.CreateBasicProperties();
					replyProps.CorrelationId = props.CorrelationId;

					try
					{
						var message = Encoding.UTF8.GetString(body);
						int n = int.Parse(message);
						Console.WriteLine(" [.] fib({0})", message);
						response = fib(n).ToString();
					}
					catch(Exception e)
					{
						Console.WriteLine(" [.] " + e.Message);
						response = "";
					}
					finally
					{
						var responseBytes = Encoding.UTF8.GetBytes(response);
						channel.BasicPublish(exchange: "",
											 routingKey: props.ReplyTo,
											 basicProperties: replyProps,
											 body: responseBytes);
						channel.BasicAck(deliveryTag: ea.DeliveryTag,
										 multiple: false);
					}
				}
			}
		}

		/// <summary>
		/// Assumes only valid positive integer input.
		/// Don't expect this one to work for big numbers,
		/// and it's probably the slowest recursive implementation possible.
		/// </summary>
		private static int fib(int n)
		{
			if(n == 0 || n == 1)
			{
				return n;
			}

			return fib(n - 1) + fib(n - 2);
		}
	} 

服务器端代码更简单明了：

通常我开始先建立连接，通道和声明队列。

我们也许想运行更多的服务器来处理。为了在多个服务器上负载均衡我们需要设置`channel.basicQos`的`preferchCount`。

我们使用`basicConsume`来访问队列。然后为了等待请求消息我们进入while循环，执行工作并发送响应。

RPC客户端代码如下：


	using System;
	using System.Collections.Generic;
	using System.Linq;
	using System.Text;
	using System.Threading.Tasks;
	using RabbitMQ.Client;
	using RabbitMQ.Client.Events;

	class RPCClient
	{
		private IConnection connection;
		private IModel channel;
		private string replyQueueName;
		private QueueingBasicConsumer consumer;

		public RPCClient()
		{
			var factory = new ConnectionFactory() { HostName = "localhost" };
			connection = factory.CreateConnection();
			channel = connection.CreateModel();
			replyQueueName = channel.QueueDeclare().QueueName;
			consumer = new QueueingBasicConsumer(channel);
			channel.BasicConsume(queue: replyQueueName,
								 noAck: true,
								 consumer: consumer);
		}

		public string Call(string message)
		{
			var corrId = Guid.NewGuid().ToString();
			var props = channel.CreateBasicProperties();
			props.ReplyTo = replyQueueName;
			props.CorrelationId = corrId;

			var messageBytes = Encoding.UTF8.GetBytes(message);
			channel.BasicPublish(exchange: "",
								 routingKey: "rpc_queue",
								 basicProperties: props,
								 body: messageBytes);

			while(true)
			{
				var ea = (BasicDeliverEventArgs)consumer.Queue.Dequeue();
				if(ea.BasicProperties.CorrelationId == corrId)
				{
					return Encoding.UTF8.GetString(ea.Body);
				}
			}
		}

		public void Close()
		{
			connection.Close();
		}
	}

	class RPC
	{
		public static void Main()
		{
			var rpcClient = new RPCClient();

			Console.WriteLine(" [x] Requesting fib(30)");
			var response = rpcClient.Call("30");
			Console.WriteLine(" [.] Got '{0}'", response);

			rpcClient.Close();
		}
	}


客户端代码涉及了稍微多一些：

我们建立一个连接和一个通道并且声明一个排他的回调队列用于回复。

我们订阅了回调队列，所以我们能够接收RPC响应

我们的call方法执行实际的RPC请求。

在这里，我们首先声称一个唯一的`correlationId`数并保存它，在while循环里将会使用这个值捕获合适的响应。

下面我们发布请求消息，并带有replayTo和correlationId两个属性。

这个时候我们可以坐下来然后等待直到合适的响应到达。

while循环做的事情很简单，对于每一个响应消息它（这while循环那段代码）都检查correlationId是否是我们查找的那个。如果是，它会保存响应。最终我们给用户返回响应。

执行客户端请求：

	RPCClient fibonacciRpc = new RPCClient();

	System.out.println(" [x] Requesting fib(30)");
	String response = fibonacciRpc.call("30");
	System.out.println(" [.] Got '" + response + "'");

	fibonacciRpc.close();

现在是时候查看我们完整的例子源码了（包括基本的异常处理）：RPCClient.cs和RPCServer.cs。

像往常一样编译：

	$ csc /r:"RabbitMQ.Client.dll" RPCClient.cs
	$ csc /r:"RabbitMQ.Client.dll" RPCServer.cs

我们的RPC服务已经准备好了。我们可以启动服务器了：

	$ RPCServer.exe
	 [x] Awaiting RPC requests

运行下面客户端请求一个斐波那契数：

	$ RPCClient.exe
	 [x] Requesting fib(30)

目前这里的设计不是一个RPC服务唯一可能的实现，但是它给出了一些重要的建议：

如果RPC服务器很慢，你可以运行一个新的RPC服务器。试着在一个新的控制台运行第二个RPCServer。

在客户端，RPC要求客户端只能发送和接收一条消息。没有要求像queueDeclare的同步调用。对于单个RPC请求，RPC客户端只需要一次网络来回就可以得到结果。

目前我们的代码还是非常简单，而且没有尝试解决更复杂（但更重要）的问题，比如：

如果没有运行的服务器，客户端应该如何反应？

对于RPC，客户端是否应该有某些类型的超时？

如果服务器发生故障或者抛出异常，应该把它转发到客户端吗？

在处理之前阻止无效入站消息（比如检查限制，类型）


[ԭ��](http://www.rabbitmq.com/tutorials/tutorial-one-dotnet.html)

# Introduction


RabbitMQ ��һ����Ϣ����(Э�̷�����). ������, RabbitMQ���������Ƕ�����һ����Ϣ, Ȼ�����Ϣ���ݸ�������. ������֮��, ���Ը������ṩ�Ĺ���·��, ����ͳ־û���Ϣ.

RabbitMQ, ����ҵ�������ͨ��.

������ζ�ŷ���. һ����������Ϣ����������, ������P��ʾ:

![P](http://www.rabbitmq.com/img/tutorials/producer.png)

���о��������ֵ�����, �����RabbitMQ��. ��Ȼ��Ϣ��ͨ��RabbitMQ����ĳ���, ������Ϣ���洢�ڶ�������. ����û�б����κ�����, ����Դ洢�����Ϣ�ڶ�����. ����������һ�����޵Ļ�����. ��������߿��Է��Ͷ����Ϣ��һ������, ��������߿��Դ�һ�����н�������. ���п��Ա�ʾ����:

![Queue](http://www.rabbitmq.com/img/tutorials/queue.png)

���ѽ�����ζ�Ž���. ��������һ���󲿷�������ڵȴ�������Ϣ�ĳ���. ��ʾ����:

![Consumer](http://www.rabbitmq.com/img/tutorials/consumer.png)

ע��, ������, �����ߺʹ���һ��������������һ̨������. ʵ����, �󲿷�Ӧ�����Ƕ�����һ̨������.

## "Hello World"
(using the .NET/C# Client)
�ڽ̵̳��������, ���ǽ���C#д��������. һ�����͵�����Ϣ��������, �ͽ��ղ���ӡ��Ϣ��������. ���ǽ�����һЩע��, ��һЩ�����.NET API��.
�������ʾ��ͼ��, "P" �����ǵ�������, "C"��������. �м�ĺ����Ƕ���, Ҳ���ǻ������Ϣ:
![P-Q-C](http://www.rabbitmq.com/img/tutorials/python-one.png)

	.NET client library
	RabbmitMQ֧�ֶ���Э��. ����̳�ʹ�õ���AMQP 0-9-1, һ�ֿ��ŵ�, ����;����ϢЭ��. �ж��RabbitMQ��ͬ���ԵĿͻ���.���ǽ�Ҫʹ��RabbitMQ�ṩ��.NET�ͻ���
	����[�ͻ������](http://www.rabbitmq.com/dotnet.html), �ȶ�ǩ��.��ѹ������������Ŀ¼.
	����Ҫȷ�����ϵͳ�ܹ��ҵ�C#���빤�� `csc.exe`, ��Ҳ����Ҫ��� `http://www.rabbitmq.com/dotnet.html`(�����㰲װ��.NET�汾�ı�·��) �����Path.

������������.NET�ͻ������, ���ǿ���дһ�´���

## Sending

![sending](http://www.rabbitmq.com/img/tutorials/sending.png)
���ǽ���������ǵ���Ϣ������ `Send.cs` �����ǵ���Ϣ������ `Receive.cs`. �����߽������� RabbitMQ, ����һ����Ϣ, Ȼ���˳�.

�� `Send.cs` ��, ������Ҫʹ�����������ռ�:

	using System;
	using RabbitMQ.Client;
	using System.Text;	

������:

	class Send
	{
		public static void Main()
		{
			...
		}
	}

Ȼ�����ǿ��Դ���һ�����ӵ�������:

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

connection���ӳ�����socket����, Ϊ�����ṩ��Э��汾Э�̺���֤�ȵ�. �����������ӵ������Ĵ��� - *localhost*. ����������������������ϵĴ���, ֻ��Ҫ�ڴ˴�ָ���������ֻ�IP��ַ.
���������Ǵ���channel(�ŵ�), ���Ǵ󲿷�API��ȡ��Ϣ�ĵط�.
����ҪΪ���ǵķ�������һ������, Ȼ�����ǾͿ��Է�����Ϣ���������:


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


�����������ݵȵ�, ���н������������ڵ�ʱ��ű�����.(Alan: �������A�Ѿ���������, �ٴ���������A, ֻ�Ǽ򵥵ط��ض���A, �������ٴ���һ�ζ���A. ������������Ķ���A��������ͬ, ����������ͬ, ��ô�ڶ��εĶ������������쳣.)��Ϣ�������ֽ�����, ��������Ա����κ����뷢�͵Ķ���.
������Ĵ����������, channel�ŵ������Ӷ��ᱻ����.
[����������Send.cs��](http://github.com/rabbitmq/rabbitmq-tutorials/blob/master/dotnet/Send.cs)

�����޷�����ִ��!
������ǵ�һ��ʹ��RabbitMQ, ���ҿ�������Ϣ "Sent", ��ץ��ͷƤҲ�벻�������������. Ҳ���Ǵ���û���㹻�Ĵ��̿ռ俪ʼִ��(Ĭ��RabbitMQ��Ҫ����50MB�Ŀռ�), ���RabbitMQ�ܾ�������Ϣ. ��������־�ļ�, �����Ҫ, ȷ�Ϻͽ�������. [�����ļ��ĵ�](http://www.rabbitmq.com/configure.html#config-items)������������� `disk_free_limit`.

## Receiving

���Ͼ������ǵķ����ߡ����ǵĽ����ߴ�RabbitMQ������Ϣ�����Բ��񷢲�һ����Ϣ�ķ����ߣ�������Ҫ���ֽ����߳������н�����Ϣ����ӡ������

receive.cs���using��伸����send.csһ����

	using RabbitMQ.Client;
	using RabbitMQ.Client.Events;
	using System;
	using System.Text;

 �������õĺӷ�����һ�������Ǵ�һ�����Ӻ�ͨ��������һ�����ǽ�Ҫ���ѵĶ��С�ע���������������Ҫ��send�������ƥ�䡣

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

ע������������Ҳ�������Ǹ����С���Ϊ����Ҳ�����ڷ����߳������������߳���

���ǽ�����߷��������Ǹ����е�����Ϣ��������Ϊ���������첽������������Ϣ������������Ҫ���ṩ�ص��������EventingBasicConsumer.Received�¼���Ҫ����ġ�

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

[Receive.cs Դ��](https://github.com/rabbitmq/rabbitmq-tutorials/blob/master/dotnet/Receive.cs)


## Putting It All Together

���������RabbitMQ .NET��ͬʱ������������. ����ʹ��������(cmd.exe��csc)��������д��롣������Ҳ����ʹ��VS��

	$ csc /r:"RabbitMQ.Client.dll" Send.cs
	$ csc /r:"RabbitMQ.Client.dll" Receive.cs

Ȼ�����п�ִ�г���:

	$ Send.exe

Ȼ�����н�����: 
	
	$ Receive.exe

�����߽����ӡ����RabbitMQ�����ߵ���Ϣ�������߽��ᱣ�����У��ȴ���Ϣ��ʹ��Ctrl+Cֹͣ�����������Ŵ���һ���ն����з����ߡ�

�����������У����Գ���ʹ�� `RabbitMQctl list_queues`.

��ʱ���Ʋ��ڶ����̳̽����򵥹���������.


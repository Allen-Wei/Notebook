# ���ڱհ�

��������, �����������ʵ�һ��ʲô�Ǳհ�������, �ҵ�ʱ������Ǻ����ڱ�����֮ǰ��ס����������ʱ��������ı���, ����Щ�����ں������������޷����ʵ���. ����һ���򵥵����������������:

	var outer = function(){
		var name = "Alan";
		var inner = function(){
			return name;
		};
	};

	var getName = outer();
	var name = getName();

�����������������ִ�е�, �Ǹ�outer�������ڵ���������ȫ��������. ȫ�����������޷����ʵ�`name`������, ����ͨ���հ����ʵ���.

��һֱ��Ϊ, JS�ĺ�����һ����Ϊ���ں��������ʱ��, ������ס�˺��������������ϵ����ɱ���. �������������Ϊ, JS�����˱հ�������(��Ȼ�˻��кܶ����ؾ����˱հ�, ������������, �����Ҿ���JS�����������Ϊ�Ահ�������������.)

������������һ������, ����ʵ����Ŀ��������, ��Ŵ�������:

	function Outer(){
		
		this.greet = function(name){
			return "Hello " + name + ".";
		};

		this.iteral = function(){
			var names = ["Allen", "Alan"];
			$.each(names, function(index, name){
				console.log(this.greet(name));	//���������������, ���������޷����ʵ��ⲿ��`this.greet`;
			});
		};
	}

�ҵ�ʱ�����Ľ�������Ƕ���һ����ʱ��������`this`:

	this.iteral = function(){
		var context = this;
		$.each(names, function(index, name){
			console.log(context.greet(name));
		});
	};

��ʱ����˵������д���ǲ���(Ҳ�����ҵ�ʱ����������, ��������.), �ҵ�ʱҲ��ԥ��,��Ϊ��������.(�Ͼ���ţ��˵������. ��˵���������, ����ǰҲ���������Ƶ�, �Ҽǵõ�ʱjQuery�Ǹ�������������Ĳ������޸Ļص�������`this`, ���Ǿ������ĸ�����, ���������Ҳ鵽��`$.proxy`�����������ʵ��.)

�����ؼ�����һ���������([���������](http://stackoverflow.com/questions/14212414/jquery-change-callback-context)), Ҳ�Լ�����һ��, ֤���Լ��ǶԵ�. 

��������д�ļ��ֽ���������ķ���:

	function Outer() {
		var names = ["Alan", "Allen"];

		this.greet = function (name) {
			return "Hello " + name + ".";
		};

		this.tempRef = function () {
			var context = this;
			$.each(names, function (index, item) {
				console.info(context.greet(item));
			});
		};
		this.selfFn = function () {
			$.each(names, (function (context) {
				return function (index, item) {
					console.info(context.greet(item));
				};
			})(this));

		};
		this.proxy = function () {
			$.each(names, $.proxy(function (index, item) {
				console.info(this.greet(item));
			}, this));

		};
	}
	var instance = new Outer();
	instance.tempRef();
	instance.selfFn();
	instance.proxy();

`instance.tempRef()`, `instance.selfFn()`, `instance.proxy` ���ַ�ʽ���ܽ���������.

`tempRef`�ȽϺ����, �������ıհ������, ��ʵ�ⲻ�Ǳհ�������, ��`this`������, jQuery��`each`������, �ڶ��������ǻص�����, ���ص��������`this`, ���Ǹ�item����, �������������´���:
	
	$.each(["Alan", "Allen"], function(){
		console.log(this);
	});

�����һ����� `Alan` �� `Allen`. ����Կ� `jQuery-2.1.4.js` Դ��� `354`, `362`, `374`, `382`��Դ��, ����:
	
	for ( ; i < length; i++ ) {
		value = callback.call( obj[ i ], i, obj[ i ] );
		if ( value === false ) {
			break;
		}
	}

Դ����� `callback` �����Ǹ��ص�����, `callback.call` ������˻ص��������`this`����. ����XX����������������Ҫ��ԭ����`this`�������ı���. �������ñհ����ⲿ(`Outer`)��`this`���ݸ�ֵ��һ������, �ص���������ʱ�����Ǹ�����, �Ϳ��Լ�����õ�`Outer`��`this`��. ʵ����, �ص�����������`Outer`��`this`��������, Ϊʲô�ص������ﻹ�Ƿ��ʲ���`this.greet`��? ����Ϊ`this`�ڻص������ﱻ����ָ����`obj[i]`��, ��������������� `instance.proxy()` ���Ǹı�ص�������`this`, ʹ�ûص�������`this`����ָ��`Outer`ʵ��. PS: ��һ�ֺ͵ڶ��ַ�ʽ�Ƚ�����.

Ҫ�����Ҹ��հ���һ��׼ȷ�Ķ���, �һ���˵����, ��������[ժ¼](http://www.ibm.com/developerworks/cn/linux/l-cn-closure/index.html)һ�±��˵ı��˵Ķ���:

	ʲô�Ǳհ���
	�հ�������ʲô����ĸ�������ڸ߼����Կ�ʼ��չ������Ͳ����ˡ��հ���Closure���Ǵʷ��հ���Lexical Closure���ļ�ơ��Ահ��ľ��嶨���кܶ���˵������Щ˵��������Է�Ϊ���ࣺ
	һ��˵����Ϊ�հ��Ƿ���һ�������ĺ���������ο���Դ����������հ����հ�������ʷ������������������ɱ���(ע1)�ĺ�����
	��һ��˵����Ϊ�հ����ɺ�����������ص����û�����϶��ɵ�ʵ�塣����ο���Դ�о��������ĵĶ��壺��ʵ����Լ��(ע2)ʱ����Ҫ����һ������ʽ��ʾ���û����Ķ���������������ص��ӳ���������һ�������������������屻��Ϊ�հ���
	�����ֶ�����ĳ���������Ƕ����ģ�һ����Ϊ�հ��Ǻ�������һ����Ϊ�հ��Ǻ��������û�����ɵ����塣��Ȼ��Щҧ�Ľ��֣������Կ϶��ڶ���˵����ȷ�С��հ�ֻ������ʽ�ͱ�������������ʵ���ϲ��Ǻ�����������һЩ��ִ�еĴ��룬��Щ�����ں�����������ȷ���ˣ�������ִ��ʱ�����仯������һ������ֻ��һ��ʵ�����հ�������ʱ�����ж��ʵ������ͬ�����û�������ͬ�ĺ�����Ͽ��Բ�����ͬ��ʵ������ν���û�����ָ�ڳ���ִ���е�ĳ�������д��ڻ�Ծ״̬��Լ������ɵļ��ϡ����е�Լ����ָһ�����������ֺ���������Ķ���֮�����ϵ����ôΪʲôҪ�����û����뺯����������أ�����Ҫ����Ϊ��֧��Ƕ��������������У���ʱ���ܼ�ֱ�ӵ�ȷ�����������û���������������һ��������������ԣ�
	������һ��ֵ��First-class value����������������Ϊ��һ�������ķ���ֵ���������������Ϊһ��������ֵ��
	��������Ƕ�׶��壬����һ�������ڲ����Զ�����һ��������
	
�����ᵽ��`�ʷ�������`, �������ᵽ�ĺ�������ʱ��������.


������дһ�����õıհ�������:

	var outer = function(){
		var name = "Alan";

		return {
			get: function(){ return name; },
			set: function(val){ name = val; }
		};
	};

��дһ����ȫ�ȼ۵�C#����:

	Func<Tuple<Func<string>, Action<string>>> Closure = () =>
	{
		var name = "Alan";
		Func<string> get = () => name;
		Action<string> set = (newVal) => name = newVal;
		return Tuple.Create(get, set);
	};

	var closure = Closure();
	Console.WriteLine(closure.Item1()); // => Alan
	closure.Item2("Allen");             
	Console.WriteLine(closure.Item1);   // => Allen
		
��, �����Ǹ�����C#����. C#�󲿷��������Capture by reference, ������Ǳ���������. (�Ƽ�һƪ����C#�հ���[����](http://csharpindepth.com/Articles/Chapter5/Closures.aspx).)

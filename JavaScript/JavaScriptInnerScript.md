##前言
这两天在写动态查询, 前端要把查询表达式拼接好传到后端, 后来写了一大坨代码之后发现不够灵活, 突然想起来AngularJS的内嵌表达式了, Angular允许你把JS表达式绑定到元素上求值, 比如 

	<ul>
		<li ng-repeat="item in items">
			Price:　{{item.price}},
			Count: {{item.count}},
			Sub Price: {{item.price * item.count}}
		</li>
	</ul>

上面代码的{{item.price * item.count}}就是一个JS表达式, Angular能帮你求值. 这是因为Angular自己实现了要给AST [Abstract Syntax Tree](http://jointjs.com/demos/javascript-ast), 一种JS到JS的parser, 可是实现这个可不是一般人能完成的, 就是一个解释器.
以前看到过说Knockout, avalon使用的是eval或者 new Function来做的. 今天特地试了一下.

我要获取的查询表达式大概是这个样子的 
	
	UserName.Contains(@0) and Birthday > @1

然后@0和@1分别对应参数数组的值.

下面是我代码的实现部分:
	
	 getFilters: function (userOpt) {
            var defOpt = {
                inputs: "#toolbar-search input"
            };
            $.extend(defOpt, userOpt);

            var filters = [];
            var params = [];
            $(defOpt.inputs).each(function () {
                var $input = $(this);
                var filter = $input.data("ysdSearchFilter") || " ";
                var getValues = $input.data("ysdSearchGet") || {
                    getValue: function ($ele) {
                        return $ele.val();
                    }
                };
                var value = getValues.getValue($input);


                var reg = /\{\{(.+)\}\}/gi;
                var matchdFilterExpressions = reg.exec(filter);
                if (matchdFilterExpressions && matchdFilterExpressions.length === 2) {
                    var fnBody = matchdFilterExpressions[1].replace("$value", value);
                    filter = filter.replace(matchdFilterExpressions[0], "@" + params.length);
                    var fn = new Function(fnBody);
                    value = fn.apply($input);
                }
                if (value === undefined || value == null || value === "" || /^ +$/gi.test(value)) {
                    return;
                }
                filters.push(filter.replace("$value", "@" + params.length));
                params.push(value);
            });

            return {
                filters: filters.join(" and "),
                params: params
            };
        }


然后使用的时候大概是这个样子的:

	<div id="toolbar-search">
        生成日期 开始: <input class="easyui-datebox ysd-search ysd-search-startdate" data-ysd-search-filter="GenerateDate > {{return Ysd.Services.Utils.ifIsInvalidDate(new Date($(this).datebox('getValue')), undefined)}}" style="width:100px">
        生成日期 结束: <input class="easyui-datebox ysd-search ysd-search-enddate" data-ysd-search-filter="GenerateDate < {{return Ysd.Services.Utils.ifIsInvalidDate(new Date($(this).datebox('getValue')), undefined)}}" style="width:100px">
        名字: <input type="text" class="ysd-search ysd-search-name" data-ysd-search-filter="UserName.Contains($value)" style="width: 80px;" />
        手机号： <input type="text" class="ysd-search ysd-search-phone" data-ysd-search-filter="Mobile.Contains($value)" style="width: 80px;" />
        贷款额度大于: <input type="text" class="ysd-search ysd-search-loanlimit" data-ysd-search-filter="LoanLimit.Value > {{return parseInt($(this).val())}}" style="width: 80px;"  /> 
        <a href="#" class="easyui-linkbutton ysd-form-search" iconcls="icon-search">Search</a>
    </div>

下面是判断是否是无效日期的相关函数
	
	    isDate: function (date) {
            if (Object.prototype.toString.call(date) === "[object Date]") {
                return true;
            }
            return false;
        },
        isInvalidDate: function (date) {
            if (!this.isDate(date)) {
                return true;
            }
            if (isNaN(date.getTime())) {
                return true;
            }
            else {
                return false;
            }
        },
        ifIsInvalidDate: function (date, whenTrue) {
            return this.isInvalidDate(date) ? whenTrue : date;
        }

下面是运行截图:

![JavaScriptInnerScript](https://raw.githubusercontent.com/Allen-Wei/GitBlog/master/JavaScript/JavaScriptInnerScript.png)

现在在**data-ysd-search-filter**的**{{}}**里面可以写JS表达式了,其实是一个完成的函数body, 因为使用Function.prototype.apply把当前作用域替换成了当前元素, 所以现在表达式的this是当前元素.
日期使用了easyui的组件, 使用内嵌的表达是最方便的.
实现动态解析JS表达式的主要利用了 [new Function](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function) 和 [Function.prototype.apply](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/apply).
如果使用一般的获取方式可能就要写一大坨获取值并转换的代码了, 无法抽象出一个公共方法:

	var startDate = Ysd.Services.Utils.ifIsInvlidDate(new Date($(".ysd-search-startdate").datebox("getValue")), undefined);
	filters.push("GenerateDate > @0");
	params.push(startDate);
	var endDate = Ysd.Services.Utils.ifIsInvlidDate(new Date($(".ysd-search-enddate").datebox("getValue")), undefined);
	...
	var limit = parseInt( $(".ysd-search-loanlimit").val);
	...
	....

现在等于把这些获取值的方法移到HTML里面了, 然后就能批量获取操作了. 多方便~

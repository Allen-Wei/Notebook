##ǰ��
��������д��̬��ѯ, ǰ��Ҫ�Ѳ�ѯ���ʽƴ�Ӻô������, ����д��һ�������֮���ֲ������, ͻȻ������AngularJS����Ƕ���ʽ��, Angular�������JS���ʽ�󶨵�Ԫ������ֵ, ���� 

	<ul>
		<li ng-repeat="item in items">
			Price:��{{item.price}},
			Count: {{item.count}},
			Sub Price: {{item.price * item.count}}
		</li>
	</ul>

��������{{item.price * item.count}}����һ��JS���ʽ, Angular�ܰ�����ֵ. ������ΪAngular�Լ�ʵ����Ҫ��AST [Abstract Syntax Tree](http://jointjs.com/demos/javascript-ast), һ��JS��JS��parser, ����ʵ������ɲ���һ��������ɵ�, ����һ��������.
��ǰ������˵Knockout, avalonʹ�õ���eval���� new Function������. �����ص�����һ��.

��Ҫ��ȡ�Ĳ�ѯ���ʽ�����������ӵ� 
	
	UserName.Contains(@0) and Birthday > @1

Ȼ��@0��@1�ֱ��Ӧ���������ֵ.

�������Ҵ����ʵ�ֲ���:
	
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


Ȼ��ʹ�õ�ʱ������������ӵ�:

	<div id="toolbar-search">
        �������� ��ʼ: <input class="easyui-datebox ysd-search ysd-search-startdate" data-ysd-search-filter="GenerateDate > {{return Ysd.Services.Utils.ifIsInvalidDate(new Date($(this).datebox('getValue')), undefined)}}" style="width:100px">
        �������� ����: <input class="easyui-datebox ysd-search ysd-search-enddate" data-ysd-search-filter="GenerateDate < {{return Ysd.Services.Utils.ifIsInvalidDate(new Date($(this).datebox('getValue')), undefined)}}" style="width:100px">
        ����: <input type="text" class="ysd-search ysd-search-name" data-ysd-search-filter="UserName.Contains($value)" style="width: 80px;" />
        �ֻ��ţ� <input type="text" class="ysd-search ysd-search-phone" data-ysd-search-filter="Mobile.Contains($value)" style="width: 80px;" />
        �����ȴ���: <input type="text" class="ysd-search ysd-search-loanlimit" data-ysd-search-filter="LoanLimit.Value > {{return parseInt($(this).val())}}" style="width: 80px;"  /> 
        <a href="#" class="easyui-linkbutton ysd-form-search" iconcls="icon-search">Search</a>
    </div>

�������ж��Ƿ�����Ч���ڵ���غ���
	
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

���������н�ͼ:

![JavaScriptInnerScript](https://raw.githubusercontent.com/Allen-Wei/GitBlog/master/JavaScript/JavaScriptInnerScript.png)

������**data-ysd-search-filter**��**{{}}**�������дJS���ʽ��,��ʵ��һ����ɵĺ���body, ��Ϊʹ��Function.prototype.apply�ѵ�ǰ�������滻���˵�ǰԪ��, �������ڱ��ʽ��this�ǵ�ǰԪ��.
����ʹ����easyui�����, ʹ����Ƕ�ı��������.
ʵ�ֶ�̬����JS���ʽ����Ҫ������ [new Function](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function) �� [Function.prototype.apply](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/apply).
���ʹ��һ��Ļ�ȡ��ʽ���ܾ�Ҫдһ�����ȡֵ��ת���Ĵ�����, �޷������һ����������:

	var startDate = Ysd.Services.Utils.ifIsInvlidDate(new Date($(".ysd-search-startdate").datebox("getValue")), undefined);
	filters.push("GenerateDate > @0");
	params.push(startDate);
	var endDate = Ysd.Services.Utils.ifIsInvlidDate(new Date($(".ysd-search-enddate").datebox("getValue")), undefined);
	...
	var limit = parseInt( $(".ysd-search-loanlimit").val);
	...
	....

���ڵ��ڰ���Щ��ȡֵ�ķ����Ƶ�HTML������, Ȼ�����������ȡ������. �෽��~

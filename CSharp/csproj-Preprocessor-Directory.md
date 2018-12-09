# C# Preprocessor Directives

## 在.csproj文件中定义预处理指令
下面的`PropertyGroup`节点是在根节点`Project`下定义的: 

	<Project>
		...
		<PropertyGroup ....>
			...
			<DefineConstants Condition=" '$(TargetFrameworkVersion)' == 'v4.0' ">NET4</DefineConstants>
			<DefineConstants Condition=" '$(TargetFrameworkVersion)' == 'v4.5' ">NET45</DefineConstants>
			<DefineConstants Condition=" '$(TargetFrameworkVersion)' == 'v4.51' ">NET451</DefineConstants>
			...
		</PropertyGroup>
		...
	</Project>

也可以一次定义多个指令:

    <DefineConstants>TRACE;DEBUG;CODE_ANALYSIS;$(DefineConstants);$(AdditionalConstants)</DefineConstants>

NOTE: 要把`<DefineConstants>`定义在` <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Release|AnyCPU' ">`或者`<PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|AnyCPU' ">`节点下. 如果定义在没有属性的`<PropertyGroup>`节点下有可能会造成VS 2015崩溃.
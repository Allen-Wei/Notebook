# Node.js in Action Second Edition

### 1.5 三种主流的Node程序

#### 1.5.2 命令行工具和后台程序

Node 可以用来编写命令行工具, 你可以试一下创建一个名为 `cli.js` 的新文件, 添加如下代码: 
```javascript
#!/usr/bin/env node 
const [nodePath, scriptPath, name] = process.argv;

console.log(`Node Path: ${nodePath};
Script Path: ${scriptPath}
Name: ${name}`);
```
然后执行一下bash命令:
```bash
> chmod +x cli.js
> ./cli.js helloWorld

Node Path: /usr/local/Cellar/node/10.3.0/bin/node;
Script Path: /Users/hello/workspace/temporary/node.hello/cli.js
Name: helloWorld
```

> 第一行`#!/usr/bin/env node`只在Unix系统(XOS, Linux)上有作用, 用于告诉系统使用`node`来执行下面脚本.

### 2.3 用module.exports微调模块的创建

最终在程序里导出的是 `module.exports`。`exports` 只是对 `module.exports` 的一个全局引用，最初被定义为一个可以添加属性的空对象。`exports.myFunc` 只是 `module.exports. myFunc` 的简写。
所以，如果把 `exports` 设定为别的，就打破了 `module.exports` 和 `exports` 之间的引用 关系。可是因为真正导出的是 `module.exports`，那样 `exports` 就不能用了，因为它不再指向 `module.exports` 了。如果你想保留那个链接，可以像下面这样让 `module.exports` 再次引用 `exports`: `module.exports = exports = Currency;`
根据需要使用 `exports` 或 `module.exports` 可以将功能组织成模块，规避掉程序脚本 一直增长所产生的弊端。
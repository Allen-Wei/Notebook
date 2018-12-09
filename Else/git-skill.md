# 更新 Git 记住的密码

如果你的git账号密码放生变更, 再次执行`git pull`提交代码的时候会提示认证失败, 需要重新设置一下账号密码, 一个简单的方式是在提交代码的时候添加`-u`参数, 这样会弹窗提示执行用户名, 这个时候输入之前记住的账号名和新密码就可以更新了:

```bash
git push -u origin master
```

# Tag


```bash
# ref: https://stackoverflow.com/questions/3404936/show-which-git-tag-you-are-on
# 显示当前的标签 
git describe --tags

# ref https://stackoverflow.com/questions/35979642/how-to-checkout-remote-git-tag
# 获取所有的tag
git fetch --all --tags --prune

# 切换标签
git checkout tags/<tag_name> -b <branch_name>

# list all tags
git tag

# create tag
git tag -a v1.0 -m "Product release"

# delete tag
git tag -d <tag_name>
```

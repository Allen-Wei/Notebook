# Git 配置

* `git config --global --edit` 编辑全局配置 

## core editor

使用以下方式指定默认编辑器为 vim:

```sh
git config --global core.editor "vim"
export GIT_EDITOR=vim
```

或者编辑配置文件使用 sublime 作为默认编辑器: 

```
[core]
    editor = 'subl' --wait
```

## credential 

```sh
git config --global credential.helper cache # 设置credential存储在内存中, 默认是 “900”，也就是 15 分钟
git config --global credential.helper store --file ~/.my-credentials # 设置credential存储在指定文件
```

```gitconfig
# 设置credential存储在内存中, 并设置过期时间
[credential]
    helper = cache --timeout 3600
```

# Git 查看文件区别


`git diff <previous_commit_hash>..<newer_commit_hash> -- {file_path}` 用于查看指定文件两个不同commit之间的区别, 比如: 

```
> git diff 9a422584b66686b11c20ce330aeb84f47e1c0b9b..e5f766ac6899f191a2fd53c9247f1ee9264886e0 -- src/some_file.js 
```

> Ref: [Show diff between commits](https://stackoverflow.com/questions/3368590/show-diff-between-commits)

Try

```bash
git diff k73ud^..dj374
```

to make sure to include all changes of k73ud in the resulting diff.

`git diff` compares two endpoints ([instead of a commit range](https://stackoverflow.com/a/7256391/6309)). Since the OP want to see the changes introduced by `k73ud`, he/she needs to difference between [the first parent commit of k73ud:  k73ud^](https://stackoverflow.com/a/1956054/6309) (or [k73ud^1 or k73ud~](https://stackoverflow.com/a/2222920/6309) ).

That way, the diff results will include changes since k73ud parent (meaning including changes from k73ud itself), instead of changes introduced since k73ud (up to dj374).

Also you can try:

```bash
git diff oldCommit..newCommit
git diff k73ud..dj374 
```

and (1 space, not more):

```bash
git diff oldCommit newCommit
git diff k73ud dj374
```

And if you need to get only files names (e.g. to copy hotfix them manually):

```bash
git diff k73ud dj374 --name-only
```

And you can get changes applied to another branch:

```bash
git diff k73ud dj374 > my.patch
git apply my.patch
```
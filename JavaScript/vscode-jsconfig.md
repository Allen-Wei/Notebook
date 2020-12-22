Visual Studio Code 配置绝对路径包引用的智能感知

[Ref](https://stackoverflow.com/questions/55723308/vue-js-and-vs-code-no-intellisense-for-absolute-file-path)

**jsconfig.json**

```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": [
        "./src/*"
      ],
    }
  },
  "include": [
    "src/**/*",
    "jsconfig.json"
  ]
}
```
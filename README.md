# fir-mac
基于 macOS 的 fir.im 可视化管理客户端，可以进行上传、查看、编辑等操作。

<img width="700" src="http://ww4.sinaimg.cn/large/006tKfTcgy1ffnjkuvhrhj31bs0z87bb.jpg" />

### 开发环境

- Swift 3.0
- Xcode 8
- OS X 10.12

### 下载

[Releases](https://github.com/isaced/fir-mac/releases)

### 使用

使用你自己的 fir 账号登陆，先到 [fir.im 后台](https://fir.im/apps/apitoken) 查看自己的 `API Token`，然后在应用中登陆，即可完成后续一系列数据请求。

> `API Token` 完全纯本地保存在应用沙盒 UserDefaults 中，所以你不必担心其安全问题

### URL scheme

你可以在其他地方唤起 fir-mac 进行上传操作

```
fir-mac://upload?filepath=path/to/xx.ipa
```

### API

所有网络请求接口都基于 [fir.im API Documents](http://fir.im/docs)

### FAQ

- [fir-mac 开发笔记](http://www.isaced.com/post-286.html)
- [打不开“fir.im”，因为它来自身份不明的开发者](https://github.com/isaced/fir-mac/wiki/FAQ#faq-1打不开-firim因为它来自身份不明的开发者)

### 反馈

如有任何问题或建议，请[提交](https://github.com/isaced/fir-mac/issues/new) issue 让我看到。

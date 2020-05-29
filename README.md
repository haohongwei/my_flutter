# my_flutter

A new flutter module project.

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.dev/).


iOS和Flutter混合工程的CI中的Flutter工程示例。

具体可以参考https://www.jianshu.com/u/a3ae8888a19a

和官方的混合工程的区别主要是添加了两个文件，xcode_backend.sh和get_version.sh.

其中xcode_backend.sh的主要作用就是拷贝Flutter工程编译后的产物和提交到github上，以便iOS工程使用。

get_version.sh主要是读取当前版本，作为可选项，也可以不添加。

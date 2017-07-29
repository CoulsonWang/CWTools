# CWTools
保存一些自己抽取封装的工具类文件


文件目录

## Objective-C
1.Single.h 单例宏

2.Category 分类
- NSDictionary+Log         自定义NSDictionary和NSArray的打印
- NSDictionary+Property    根据字典中的键快速生成属性列表的代码
- NSObject+Model           利用runtime字典转模型
- UIColor+Hex              通过16进制格式的字符串生成颜色
- UIImage+Clip             提供类方法和对象方法创建圆角图片，采用开启图形上下文重绘的方式
- UIImage+Render           根据图片名称生成一张不被渲染的图片
- UINavigationBar+CWBackgroundColor  通过一个颜色快速设置navigationBar的背景图片
- UIImage+CWColorAndStretch     通过一个颜色快速创建一张图片，以及快速创建可拉伸的图片


## Swift
1.表情键盘                   封装了一个简单的表情键盘实现

2.定位获取工具类             封装了一个快速获取定位信息的工具类

3.二维码工具                 封装了一个可以快速生成、检测、扫描二维码的工具类

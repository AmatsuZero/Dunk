# Dunk
![](https://raw.githubusercontent.com/naoyashiga/Dunk/master/demo.gif)  
Dunk is a Dribbble client.

***

###以下是我的注释
这个项目我从这个项目[Dunk](https://github.com/naoyashiga/Dunk)这个项目Fork出来的，选择改造这个项目作为我的第一个Swift项目，有这么几个原因：
1. 这个项目很简单。由于没有复杂的架构，看懂这个项目没有花多少时间；
2. 这个项目没有用多少国内主流的东西。可以趁这个机会熟悉一些主流Swift第三方库；
3. 这个项目不完美。数据加载、请求错误处理、性能优化等等都没有做，因此还有提升的空间。
4. 原版项目作者及时将语法升级到了3.0版本。这省去了我不少的麻烦，不必为语法过渡挠头。

原来的项目只用到了SDWebImage和FLAnimatedImage两个第三方库，而且也没有多么深入的使用。我又引进了一些主流的Swift第三方库，包括：
* **[Alamofire](https://github.com/Alamofire/Alamofire)**：大名鼎鼎的网络请求库，不熟悉一下API都不好意思跟人打招呼；
* **[SnapKit](https://github.com/SnapKit/SnapKit)**：Masonry的Swift版本，像我这种不愿使用xib和storyboadr的人的福音；
* **[MBProgressHUD](https://github.com/jdg/MBProgressHUD)**：从OC时代就开始用的用来显示进度显示第三方库，虽然很多人有用[SVProgressHUD](https://github.com/SVProgressHUD/SVProgressHUD)，但我还是更喜欢这个多一些；

我目前做了这么几个工作：
1. 删掉所有的storyboard、xib，完全由SnapKit手动写布局；
2. 圆角优化。原版完全通过给layer设置cornerRadius来显示圆角，考虑到数据源不是静态的，会频繁触发离屏渲染而导致性能下降，这里采用了手工绘制圆形遮盖然后覆盖上的办法。目前这个方法仍有一些瑕疵，就是圆角不是立刻就覆盖上，而是需要等一会儿，待以后优化；
3. 添加3D Touch；
4. 添加中文本地化支持；
5. 细节优化。比如cell在有图片显示之前不是干等，而是显示一个带有进度条的HUD；

###TODO
* 添加travis CI
* 多搞几个layout。目前搞了一个旋转式的layout，但效果不是很好，待以后添加
* 额，看看能不能多搞几个功能，比如分享什么的，毕竟现在功能太有限了……

###踩坑笔记
1. Swift的类型转化跟其他语言很不一样，比如我们想把两个整数之商转换为Float类型，Float（商）是不行的。
只把一个整数转换为Float也不行（在以前语言中，以精度大的为准，这样得到的商就是Float类型）。
Swift需要将除数和被除数都转换为Float类型，才能得到期望的值。
2. SDWebImage在Swift下各种方法由于重载的原因会有问题，可以参考[OS上一个Bug的讨论](http://stackoverflow.com/questions/38949214/ambiguous-use-of-sd-setimagewithplaceholderimagecompleted-with-swift-3)
3. 各种恶心的初始化的问题。关于Swift下初始化的顺序问题，可以看一篇[教程](http://www.jianshu.com/p/2c3db48101da)
4. Swift3把dispatch_once方法移除了。这导致了原来很多的写法不可用了，这里分享一个自造的dispatch_once方法，本方法通过``objc_sync_enter``和``objc_sync_exit``来保证线程安全，实现如下：

```swift
import Foundation

public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform. or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
    }
    
    //使用UUID作为token
    public class func once(block:()->Void) {
        let token = NSUUID().uuidString
        DispatchQueue.once(token: token, block: block)
    }
}
```
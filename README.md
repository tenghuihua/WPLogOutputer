# WPLogOutputer
##离线日志打印神器,调试神器
是否遇到过在Xcode未跑起来,直接在真机上调试但是此刻bug出现了想到看到日志输出,却无法看到时的尴尬呢...  
现在有了这个工具`WPLogOutputer` ,这些烦恼就没有了,快来试试吧   
使用简单,只需一两步就拥有,快来试试吧

##【能做什么】
- 与Xcode的日志控制台同步输出
- 打印的日志信息可保存到沙盒,不错过bug的追踪
- 可将保存的日志文件分享,通过QQ或者别的工具进行在线的传输,共享给其他开发人员,直接在线预览日志的信息
- 日志文件中记录着日志的打印时间,做到日志可控


###先来几个图  
####注意截图由于掉帧的情况,导致在截图里看起来离线日志打印工具上的日志和Xcode里的日志同步不一致,其实是一致的,不信可以下载下来看效果

日志信息  
![image](https://github.com/anrikgwp/WPLogOutputer/blob/master/demoImages/demo4.png)  
 
演示图2   
![image](https://github.com/anrikgwp/WPLogOutputer/blob/master/demoImages/demo1.gif)  
 
演示图3  
![image](https://github.com/anrikgwp/WPLogOutputer/blob/master/demoImages/demo2.gif)  
  
演示图4  
![image](https://github.com/anrikgwp/WPLogOutputer/blob/master/demoImages/demo3.gif)  




#   用法简介

###【手动导入】
- 【直接下载源代码,将`WPLogOutputer`文件夹拽入项目中】


###【具体用法】
1. 为了方便全局使用在`PrefixHeader.pch`导入主头文件：`#import "WPLogOutputer.h"`
2. 习惯在项目中全局重写`NSLog`,以便打印出我们想要的日志格式,方便找出日志打印所在的代码行
 
```Objective-C
//#ifndef  kAppStore
 #define NSLog(FORMAT, ...) {fprintf(stderr,"\n%s %d -> %s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);[WPLogOutputer printLog:[NSString stringWithFormat:@"%s<Line:%d>:%@", __FUNCTION__, __LINE__,[NSString stringWithFormat:@"%@",[NSString stringWithFormat:FORMAT, ##__VA_ARGS__]]]];}
 #else
 #define NSLog(FORMAT, ...)  nil
 #endif

```
3.在适当时候将日志打印工具显示出来,如在AppDelegate中开启日志打印控件

 
```Objective-C

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 开启打印
    [WPLogOutputer showLogOutputer];
    return YES;
}

```
- 但通常是我们不需要日志打印神器,而是在某个时刻我们让他出现,再此笔者推荐以下做法

```
 // 推荐做法
 { 
 // 放在项目中的BaseViewController中
	UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerIncident:)];
 	singleFingerOne.numberOfTouchesRequired = 3;// 手指数
 	singleFingerOne.numberOfTapsRequired = 5;// 点击次数
 	[self.view addGestureRecognizer:singleFingerOne];
 }
 
 - (void)fingerIncident:(UITapGestureRecognizer *)ges {
 	[WPLogOutputer showLogOutputer];
 }

```
这样的话就可以通过三指点击屏幕5次即可调用日志打印神器
================================================

- 当然你可以直接使用宏`WPLog(FORMAT, ...)`来直接将想要的打印内容输出到离线日志打印神器上

使用就是这样么轻松!


## 期待
* 第一次开源,多有不足,忘多多指教!
* 如果在使用过程中遇到BUG，希望你能Issues我，谢谢

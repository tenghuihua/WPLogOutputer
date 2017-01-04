//
//  WPLogOutputer.h
//
//  Created by Anrik on 2016/12/18.
//  Copyright © 2016年 Anrik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 打印宏,只需要调用,和正常的NSLog一样使用.只不过打印输出的是在自定义日志输出台.
 */
#define WPLog(FORMAT, ...) [WPLogOutputer printLog:[NSString stringWithFormat:@"%s<Line:%d>:%@", __FUNCTION__, __LINE__,[NSString stringWithFormat:@"%@",[NSString stringWithFormat:FORMAT, ##__VA_ARGS__]]]];

/*
// 自定义Log
//#define kAppStore // 上架到appStore开关,打开就说明要上架到appStore
//#ifndef  kAppStore
 #define NSLog(FORMAT, ...) {fprintf(stderr,"\n%s %d -> %s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);[WPLogOutputer printLog:[NSString stringWithFormat:@"%s<Line:%d>:%@", __FUNCTION__, __LINE__,[NSString stringWithFormat:@"%@",[NSString stringWithFormat:FORMAT, ##__VA_ARGS__]]]];}
 #else
 #define NSLog(FORMAT, ...)  {[WPLogOutputer printLog:[NSString stringWithFormat:@"%s<Line:%d>:%@", __FUNCTION__, __LINE__,[NSString stringWithFormat:@"%@",[NSString stringWithFormat:FORMAT, ##__VA_ARGS__]]]];}
 #endif
*/

/*
 // 推荐做法
 UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerIncident:)];
 singleFingerOne.numberOfTouchesRequired = 3;// 手指数
 singleFingerOne.numberOfTapsRequired = 5;// 点击次数
 [self.view addGestureRecognizer:singleFingerOne];
 
 
 - (void)fingerIncident:(UITapGestureRecognizer *)ges {
 [WPLogOutputer showLogOutputer];
 }
 
 */

#define kLogOutputerHeight 150 // 自定义日志输出台高度
#define kSize CGRectMake(0, 260, [UIScreen mainScreen].bounds.size.width, kLogOutputerHeight)

@interface WPLogOutputer : NSObject
+ (instancetype)sharedManager;

/**
 开启日志输出台
 */
+ (void)showLogOutputer;

/**
 隐藏日志输出台
 */
+ (void)hideLogOutputer;

/**
 打印日志
 */
+ (void)printLog:(NSString*)text;

/** 
 log窗口的活动范围(默认是(0,40,....))
 */
+ (void)setFreeRect:(CGRect)freeRect;

/** 
 保存日志 
 */
+ (void)saveLog;

/**
 日志文件路径
 */
+ (NSString *)wp_LogPath;

/**
 log文件大小
 */
+ (long)logFileSize;
@end




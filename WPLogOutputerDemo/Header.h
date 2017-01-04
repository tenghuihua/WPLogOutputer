//
//  Header.h
//  WPLogOutputerDemo
//
//  Created by Anrik on 2017/1/4.
//  Copyright © 2016年 Anrik. All rights reserved.
//

#ifndef Header_h
#define Header_h

// 自定义Log
#if DEBUG
#   define NSLog(FORMAT, ...) {fprintf(stderr,"\n%s %d -> %s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);[WPLogOutputer printLog:[NSString stringWithFormat:@"%s<Line:%d>:%@", __FUNCTION__, __LINE__,[NSString stringWithFormat:@"%@",[NSString stringWithFormat:FORMAT, ##__VA_ARGS__]]]];}
#else
#define NSLog(FORMAT, ...)  {[WPLogOutputer printLog:[NSString stringWithFormat:@"%s<Line:%d>:%@", __FUNCTION__, __LINE__,[NSString stringWithFormat:@"%@",[NSString stringWithFormat:FORMAT, ##__VA_ARGS__]]]];}
#endif

#endif /* Header_h */

//
//  ViewController.m
//  WPLogOutputerDemo
//
//  Created by Anrik on 2017/1/4.
//  Copyright © 2017年 Anrik. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, copy) NSArray *array;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Anrik_Plist" ofType:@"plist"];
    self.array = [NSArray arrayWithContentsOfFile:path];
    NSLog(@"%@",self.array);
    
    CADisplayLink *theTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(print)];
    theTimer.frameInterval = 60;
    [theTimer addToRunLoop: [NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerIncident:)];
    singleFingerOne.numberOfTouchesRequired = 3;// 手指数
    singleFingerOne.numberOfTapsRequired = 5;// 点击次数
    [self.view addGestureRecognizer:singleFingerOne];
}

// 开启日志
- (void)fingerIncident:(UITapGestureRecognizer *)ges {
    [WPLogOutputer showLogOutputer];
}

- (void)print {
    NSLog(@"%@",self.array[arc4random()%self.array.count]);
}

@end

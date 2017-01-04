//
//  WPLogOutputer.m
//
//  Created by Anrik on 2016/12/18.
//  Copyright © 2016年 Anrik. All rights reserved.
//

#import "WPLogOutputer.h"

@interface LogInfo : NSObject
/** log产生的时间 */
@property (nonatomic, strong) NSDate *logTime;
/** log */
@property (nonatomic, copy) NSString* log;
@end

@implementation LogInfo
@end

@interface WPWindow : UIWindow
/** log窗口的活动范围 */
@property (nonatomic,assign) CGRect freeRect;
@end

@interface WPWindow ()
@property (nonatomic,assign) CGPoint startPoint;
@property (nonatomic,assign) CGPoint startFramePoint;
@end

@implementation WPWindow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
        self.windowLevel = UIWindowLevelStatusBar + 100.0;
//        self.windowLevel = UIWindowLevelAlert;
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragAction:)];
        [self addGestureRecognizer:panGestureRecognizer];
    }
    return self;
}

- (void)dragAction:(UIPanGestureRecognizer *)ges {
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:{
            // 注意一旦你完成上述的移动，将translation重置为0十分重要。否则translation每次都会叠加
            [ges setTranslation:CGPointMake(0, 0) inView:self];
            self.startPoint = [ges translationInView:self];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [ges translationInView:self];
            float dx;
            float dy;
            dx = point.x - self.startPoint.x;
            dy = point.y - self.startPoint.y;
            
            // 计算移动后的view中心点
            // CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);
            CGPoint newcenter = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, self.center.y + dy);
            self.center = newcenter;
            // 注意一旦你完成上述的移动，将translation重置为0十分重要。否则translation每次都会叠加
            [ges setTranslation:CGPointMake(0, 0) inView:self];
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            CGRect rect = self.frame;
            if (self.frame.origin.y < self.freeRect.origin.y) {
                CGContextRef context = UIGraphicsGetCurrentContext();
                [UIView beginAnimations:@"topMove" context:context];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                [UIView setAnimationDuration:0.5];
                rect.origin.y = self.freeRect.origin.y;
                [self setFrame:rect];
                [UIView commitAnimations];
            } else if(self.freeRect.origin.y+self.freeRect.size.height< self.frame.origin.y+self.frame.size.height){
                CGContextRef context = UIGraphicsGetCurrentContext();
                [UIView beginAnimations:@"bottomMove" context:context];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                [UIView setAnimationDuration:0.5];
                rect.origin.y = self.freeRect.origin.y+self.freeRect.size.height-self.frame.size.height;
                [self setFrame:rect];
                [UIView commitAnimations];
            }
            break;
        }
        default:
            break;
    }
}

@end

@interface WPLogOutputViewController : UIViewController
@property (nonatomic, weak) WPWindow* hostWindow;// 一定要用weak修饰
- (void)printLog:(NSString*)newLog;
/** 日志文件路径 */
- (NSString *)wp_LogPath;

/** 保存日志 */
- (void)saveLog:(UIButton *)sender;
@end

@interface WPLogOutputViewController ()<UIDocumentInteractionControllerDelegate>
@property (nonatomic, strong) UIView *topBgV;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *cleanupBtn;
@property (nonatomic, strong) UIButton *saveLogBtn;
@property (nonatomic, strong) UIButton *sendLogBtn;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UILabel *sizeLab;
@property (nonatomic, strong) UITextView* logTextView;
@property (nonatomic, strong) NSMutableArray *logs;
@property (nonatomic, strong) NSMutableAttributedString *printAttributedString;
@property (nonatomic, strong) NSMutableString *logMuStr;
@property (nonatomic ,assign) BOOL isAnother;
@property (nonatomic ,assign) BOOL isFirstSave;
@property (nonatomic, strong) NSDate *startTime;// 启动时间
@end

@implementation WPLogOutputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.logs = [NSMutableArray array];
    self.isFirstSave = YES;
    self.printAttributedString = [[NSMutableAttributedString alloc]init];
    self.logMuStr = [[NSMutableString alloc]init];
    self.startTime = [NSDate date];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (self.isFirstSave) {
            NSFileManager *fileM = [NSFileManager defaultManager];
            BOOL ise = [fileM fileExistsAtPath:[self wp_LogPath]];
            if (ise) {
                NSError *error;
                NSString *lastTimeLogstring = [NSString stringWithContentsOfFile:[self wp_LogPath] encoding:NSUTF8StringEncoding error:&error];
                if (error) {
                    WPLog(@"%@",error);
                }else {
                    [self.logMuStr appendString:[NSString stringWithFormat:@"%@\n\n\n******************************************************\n************启动时间:%@***********\n******************************************************\n",lastTimeLogstring,[self wp_stringDateWith:self.startTime]]];// 拼接上一次
                }
            }
            self.isFirstSave = NO;
        }
    });
    
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor clearColor];
    UIView *topBgV = [[UIView alloc]init];
    topBgV.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.5];
    topBgV.frame = CGRectMake(0, 0, self.view.frame.size.width, 20);
    [self.view addSubview:topBgV];
    self.topBgV = topBgV;
    
    UIFont *font = [UIFont systemFontOfSize:13];
    
    UILabel *sizeLab = [[UILabel alloc] init];
    sizeLab.textColor = [UIColor whiteColor];
    sizeLab.font = font;
    sizeLab.textAlignment = NSTextAlignmentLeft;
    [topBgV addSubview:sizeLab];
    self.sizeLab = sizeLab;
    
    UIButton *closeBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [closeBtn setTitle:@"x" forState:(UIControlStateNormal)];
    closeBtn.titleLabel.font = font;
    [closeBtn addTarget:self action:@selector(closeLogOutputer:) forControlEvents:(UIControlEventTouchUpInside)];
    [closeBtn setBackgroundColor:[UIColor redColor]];
    [topBgV addSubview:closeBtn];
    self.closeBtn = closeBtn;
    
    UIButton *cleanupBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [cleanupBtn setTitle:@"clear" forState:(UIControlStateNormal)];
    cleanupBtn.titleLabel.font = font;
    [cleanupBtn addTarget:self action:@selector(cleanupLogOutputer:) forControlEvents:(UIControlEventTouchUpInside)];
    [cleanupBtn setBackgroundColor:[UIColor redColor]];
    [topBgV addSubview:cleanupBtn];
    self.cleanupBtn = cleanupBtn;
    
    UIButton *saveLogBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [saveLogBtn setTitle:@"save" forState:(UIControlStateNormal)];
    saveLogBtn.titleLabel.font = font;
    [saveLogBtn addTarget:self action:@selector(saveLog:) forControlEvents:(UIControlEventTouchUpInside)];
    [saveLogBtn setBackgroundColor:[UIColor redColor]];
    [topBgV addSubview:saveLogBtn];
    self.saveLogBtn = saveLogBtn;
    
    UIButton *sendLogBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [sendLogBtn setTitle:@"send" forState:(UIControlStateNormal)];
    sendLogBtn.titleLabel.font = font;
    [sendLogBtn addTarget:self action:@selector(sendLog:) forControlEvents:(UIControlEventTouchUpInside)];
    [sendLogBtn setBackgroundColor:[UIColor redColor]];
    [topBgV addSubview:sendLogBtn];
    self.sendLogBtn = sendLogBtn;
    
    UIButton *deleteBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [deleteBtn setTitle:@"delete" forState:(UIControlStateNormal)];
    deleteBtn.titleLabel.font = font;
    [deleteBtn addTarget:self action:@selector(deleteLog:) forControlEvents:(UIControlEventTouchUpInside)];
    [deleteBtn setBackgroundColor:[UIColor redColor]];
    [topBgV addSubview:deleteBtn];
    self.deleteBtn = deleteBtn;
    
    CGFloat cornerRadius = 4;
    self.closeBtn.layer.cornerRadius = cornerRadius;
    self.closeBtn.layer.masksToBounds = YES;
    self.cleanupBtn.layer.cornerRadius = cornerRadius;
    self.cleanupBtn.layer.masksToBounds = YES;
    self.saveLogBtn.layer.cornerRadius = cornerRadius;
    self.saveLogBtn.layer.masksToBounds = YES;
    self.sendLogBtn.layer.cornerRadius = cornerRadius;
    self.sendLogBtn.layer.masksToBounds = YES;
    self.deleteBtn.layer.cornerRadius = cornerRadius;
    self.deleteBtn.layer.masksToBounds = YES;

    UITextView* logTextView = [[UITextView alloc] initWithFrame:self.view.bounds];
    logTextView.font = [UIFont systemFontOfSize:11.0f];
    logTextView.backgroundColor = [UIColor clearColor];
    logTextView.scrollsToTop = YES;
    logTextView.editable = NO;
    [self.view addSubview:logTextView];
    self.logTextView = logTextView;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.topBgV.frame = CGRectMake(0, 0, self.view.frame.size.width, 20);
    self.sizeLab.frame = CGRectMake(10, 0, 60, 20);
    self.closeBtn.frame = CGRectMake(self.view.frame.size.width - 30, 0, 20, 20);
    self.cleanupBtn.frame = CGRectMake(CGRectGetMinX(self.closeBtn.frame) - 50, 0, 40, 20);
    self.saveLogBtn.frame = CGRectMake(CGRectGetMinX(self.cleanupBtn.frame) - 50, 0, 40, 20);
    self.sendLogBtn.frame = CGRectMake(CGRectGetMinX(self.saveLogBtn.frame) - 50, 0, 40, 20);
    self.deleteBtn.frame = CGRectMake(CGRectGetMinX(self.sendLogBtn.frame) - 50, 0, 40, 20);
    self.logTextView.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 20);
}

#pragma mark- Actions
- (void)closeLogOutputer:(UIButton *)sender {
    self.hostWindow.hidden = YES;
}

- (void)cleanupLogOutputer:(UIButton *)sender {
    [self.printAttributedString deleteCharactersInRange:(NSMakeRange(0, self.printAttributedString.length))];
    self.logTextView.attributedText = self.printAttributedString;
}

- (void)saveLog:(UIButton *)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error;
        BOOL suc = [self.logMuStr writeToFile:[NSString stringWithFormat:@"%@",[self wp_LogPath]] atomically:YES encoding:(NSUTF8StringEncoding) error:&error];
        if (!suc) {
            WPLog(@"日志保存失败:%@",error);
        }else {
            WPLog(@"日志保存成功");
        }
    });
}

- (void)sendLog:(UIButton *)sender {
    // http://blog.csdn.net/xuqiang918/article/details/13001451
    UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:[self wp_LogPath]]];
    documentController.delegate = self;
    //    documentController.UTI = @"public.text";
    [documentController presentOpenInMenuFromRect:CGRectZero inView:[UIApplication sharedApplication].keyWindow.rootViewController.view animated:YES];
}

- (void)deleteLog:(UIButton *)sender {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self wp_LogPath]]) {
        NSError *error;
        BOOL suc = [[NSFileManager defaultManager] removeItemAtPath:[self wp_LogPath] error:&error];
        if (!suc) {
            WPLog(@"删除日志文件失败:%@",error);
        }else {
            WPLog(@"删除日志文件成功");
        }
    }else {
        WPLog(@"文件不存在");
    }
    self.sizeLab.text = [NSString stringWithFormat:@"%.2fKb",[[[NSFileManager defaultManager] attributesOfItemAtPath:[self wp_LogPath] error:nil] fileSize] / 1024.0];
}

#pragma mark- pravite
- (NSString *)wp_stringDateWith:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // hh:mm:ss:SSS // 精确到毫秒
    // YYYY-MM-dd HH:mm:ss:SSS
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss:SSS"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

- (void)printLog:(NSString*)newLog {
    if (newLog.length == 0)
        return;
    
    LogInfo *info = [[LogInfo alloc]init];
    info.log = newLog;
    info.logTime = [NSDate date];
    [self.logs addObject:info];
    
    UIColor *color;
    if (self.isAnother) {
        self.isAnother = NO;
        color = [UIColor whiteColor];
    }else {
        self.isAnother = YES;
        color = [UIColor yellowColor];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableAttributedString* logString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@",newLog]];
        [logString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, logString.length)];
        [self.printAttributedString appendAttributedString:logString];
        
        NSString *logTime = [self wp_stringDateWith:info.logTime];
        [self.logMuStr appendString:[NSString stringWithFormat:@"\n%@:%@",logTime,info.log]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.logTextView.attributedText = self.printAttributedString;
            NSRange bottom = NSMakeRange(self.printAttributedString.length, 1);
            [self.logTextView scrollRangeToVisible:bottom];
            self.sizeLab.text = [NSString stringWithFormat:@"%.2fKb",[[[NSFileManager defaultManager] attributesOfItemAtPath:[self wp_LogPath] error:nil] fileSize]/ 1024.0];
        });
    });
}

- (NSString *)wp_LogPath {
    NSString *wp_LogPath = [NSString stringWithFormat:@"%@/%@_wp.log",[self wp_LogFilePath],[[NSBundle mainBundle] infoDictionary][@"CFBundleExecutable"]];
    return wp_LogPath;
}

// 日志文件夹路径
- (NSString *)wp_LogFilePath {
    NSString *wp_LogFilePath = [NSString stringWithFormat:@"%@/wp_Log", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:wp_LogFilePath]) {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:wp_LogFilePath withIntermediateDirectories:YES attributes:nil error:nil]) NSLog(@"创建失败");
    }
    return wp_LogFilePath;
}
@end

@interface WPLogOutputer ()
@property (nonatomic, strong) WPWindow *logWindow;
@property (nonatomic, strong) WPLogOutputViewController *logController;
@end

@implementation WPLogOutputer
+ (instancetype)sharedManager {
    static WPLogOutputer *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (WPLogOutputViewController *)logController {
    if (!_logController) {
        _logController = [[WPLogOutputViewController alloc]init];
        _logController.view.frame = CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, kLogOutputerHeight);
    }
    return _logController;
}

- (WPWindow *)logWindow {
    if (!_logWindow) {
        _logWindow = [[WPWindow alloc] initWithFrame:(kSize)];
        _logWindow.rootViewController = self.logController;
        _logWindow.freeRect = CGRectMake(0, 40, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height + 20);
        self.logController.hostWindow = _logWindow;
        //        [_logWindow makeKeyAndVisible];// 激活窗口
        //        [_logWindow resignKeyWindow];// 失去窗口响应
    }
    return _logWindow;
}

+ (void)printLog:(NSString*)text {
    WPLogOutputer *logOutputer = [WPLogOutputer sharedManager];
    [logOutputer.logController printLog:text];
}

+ (void)showLogOutputer {
    WPLogOutputer *logOutputer = [WPLogOutputer sharedManager];
    logOutputer.logWindow.hidden = NO;
}

+ (void)hideLogOutputer {
    WPLogOutputer *logOutputer = [WPLogOutputer sharedManager];
    logOutputer.logWindow.hidden = YES;
}

+ (void)setFreeRect:(CGRect)freeRect {
    WPLogOutputer *logOutputer = [WPLogOutputer sharedManager];
    logOutputer.logWindow.freeRect = freeRect;
}

/** 保存日志 */
+ (void)saveLog {
    WPLogOutputer *logOutputer = [WPLogOutputer sharedManager];
    [logOutputer.logController saveLog:nil];
}

/** 日志文件夹 */
+ (NSString *)wp_LogPath {
    WPLogOutputer *logOutputer = [WPLogOutputer sharedManager];
    return [logOutputer.logController wp_LogPath];
}

/**
 log文件大小(单位是byte)
 */
+ (long)logFileSize {
    NSError *error;
    long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:[self wp_LogPath] error:&error] fileSize];
    if (error) {
        NSLog(@"%@",error);
    }
    return fileSize;
}
@end

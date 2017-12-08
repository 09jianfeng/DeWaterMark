//
//  EditViewController.m
//  DeWaterMark
//
//  Created by JFChen on 2017/11/4.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import "EditViewController.h"
#import "EditSliderView.h"
#import "Masonry.h"
#include "ffmpeg.h"
#include "KxMovieViewController.h"
#include "ChoosingRectView.h"
#import "MyFileManage.h"
#import "MBProgressHUD.h"
#import "PayViewAndLogic.h"
#import "PreviewViewController.h"
#import "CommonConfig.h"

int ffmpegmain(int argc, char **argv);

/**
 *	sample_count= 获取最大的最大的值。总值
 *  frame= 为进度
 *	Total: 这个是总共处理了多少帧。结束
 */

static float totalCount = 1;
static float currentFrame = 0;
static EditViewController *EDITCon;

static void ffmpeg_log_callback(void* ptr, int level, const char* fmt, va_list vl)
{
    NSString *input = [[NSString alloc] initWithFormat:[NSString stringWithFormat:@"%s",fmt] arguments:vl];
    NSLog(@"%@",input);
    NSRange range = [input rangeOfString:@"sample_count="];
    if (range.location != NSNotFound) {
        NSRange range2 = [input rangeOfString:@","];
        NSString *countStr = [input substringWithRange:NSMakeRange(range.location + range.length, range2.location - range.location - range.length)];
        int count = [countStr intValue];
        if (count > totalCount) {
            totalCount = count;
            NSLog(@"____ totalCount:%f",totalCount);
        }
    }
    
    range = [input rangeOfString:@"sample_count = "];
    if (range.location != NSNotFound) {
        NSString *countStr = [input substringFromIndex:range.location+range.length];
        int count = [countStr intValue];
        if (count > totalCount) {
            totalCount = count;
            NSLog(@"____ totalCount:%f",totalCount);
        }
    }
    
    range = [input rangeOfString:@"frame= "];
    if (range.location != NSNotFound) {
        NSRange range2 = [input rangeOfString:@" QP"];
        if (range2.location != NSNotFound) {
            NSString *countStr = [input substringWithRange:NSMakeRange(range.location + range.length, range2.location - range.location - range.length)];
            int frame_count = [countStr intValue];
            currentFrame = frame_count;
            NSLog(@"____ currentFrame:%f",currentFrame);
        }
    }
    
    range = [input rangeOfString:@"Total:"];
    if (range.location != NSNotFound) {
        currentFrame = totalCount;
    }
    
    float progress = currentFrame / totalCount;
    if (EDITCon) {
        if (progress >= 1.0) {
            progress = 0.9;
        }
        [EDITCon setFFMPEGProgress:progress];
    }
}

@interface EditViewController ()<EditSliderViewDelegate,ChoosingRectView,KxMovieViewControllerDelegate>
@property (weak, nonatomic) IBOutlet ChoosingRectView *videoView;

@property (weak, nonatomic) IBOutlet EditSliderView *slidView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playViewHeigh;
@end

@implementation EditViewController{
    KxMovieViewController *_vc;
    CGRect _choosingVideoRect;
    MBProgressHUD *HUD;
    CGFloat _drafPosition;
    CGFloat _drafFrameDuration;
    UIView *_baseView;
    NSString *_outputVideoPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addSubViews];
    EDITCon = self;
    _drafPosition = 0.00001f;
}

- (void)dealloc{
    EDITCon = nil;
}

- (void)viewDidAppear:(BOOL)animated{
    EDITCon = self;
    [super viewDidAppear:animated];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    // increase buffering for .wmv, it solves problem with delaying audio frames
    if ([_videoPath.pathExtension isEqualToString:@"wmv"])
        parameters[KxMovieParameterMinBufferedDuration] = @(5.0);
    
    // disable deinterlacing for iPhone, because it's complex operation can cause stuttering
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        parameters[KxMovieParameterDisableDeinterlacing] = @(YES);

    _vc = [KxMovieViewController movieViewControllerWithContentPath:_videoPath
                                                                               parameters:parameters];
    [self addChildViewController:_vc];
    _vc.view.frame = _videoView.bounds;
    _vc.delegate = self;
    [_videoView insertSubview:_vc.view atIndex:0];
    _videoView.delegate = self;
    
    _slidView.delegate = self;
    _slidView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    _playViewHeigh.constant = CGRectGetHeight(self.view.frame) - 168;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addSubViews{
    
    _baseView = [UIView new];
    _baseView.frame = self.view.bounds;
    _baseView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _baseView.hidden = YES;
    [self.view addSubview:_baseView];
    
    HUD = [[MBProgressHUD alloc] init];
    [_baseView addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;//进度条
    HUD.square = YES;
    //14,设置显示和隐藏动画类型  有三种动画效果，如下
    HUD.animationType = MBProgressHUDAnimationZoomIn; //和上一个相反，前近，最后淡化消失
    HUD.removeFromSuperViewOnHide = NO;
    HUD.label.textColor = [UIColor blueColor];
    //18,进度指示器  模式是0，取值从0.0————1.0
    HUD.progress = 0.1;
}

- (void)setFFMPEGProgress:(float)progress{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"____ progress:%f",progress);
        HUD.label.text = [NSString stringWithFormat:@"%%%d",(int)(progress*100)];
    });
}


#pragma mark - btnPress
- (IBAction)delogoPressed:(id)sender {
    
    BOOL isVIP = [CommonConfig isVIP];
    int rest = [CommonConfig restChance];
    if (rest <= 0 && !isVIP) {
        [self getVIP];
        return;
    }
    
    _baseView.hidden = NO;
    [HUD showAnimated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       [self dealVideoWithDelogoWithChoosingRect:_choosingVideoRect];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _baseView.hidden = YES;
            [HUD showAnimated:NO];
            
            PreviewViewController *preview = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PreviewViewController"];
            preview.videoPath = _outputVideoPath;
            [self.navigationController pushViewController:preview animated:YES];
            
            [CommonConfig decreaseOneChance];
        });
    });
}

- (IBAction)clickRunButton:(id)sender {
    [_vc playDidTouch:nil];
}

- (void)dealVideoWithDelogoWithChoosingRect:(CGRect)choosingRect{
    NSString *resourcePath = _videoPath;
    NSString *root = [MyFileManage getMyProductionsDirPath];
    
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    // 设置日期格式
    [dateFormatter setDateFormat:@"MM_dd_hh:mm:ss"];
    NSString *dayTime = [dateFormatter stringFromDate:[NSDate date]];

    NSString *targetPath = [root stringByAppendingString:[NSString stringWithFormat:@"/%@%@",dayTime,[resourcePath lastPathComponent]]];
    
    NSString *command = [NSString stringWithFormat:@"ffmpeg -i %@ -vf delogo=x=%d:y=%d:w=%d:h=%d:band=10 %@",resourcePath,(int)choosingRect.origin.x,(int)choosingRect.origin.y,(int)choosingRect.size.width,(int)choosingRect.size.height,targetPath];
    _outputVideoPath = targetPath;
    
    NSString *command_str= [NSString stringWithFormat:@"%@",command];
    NSArray *argv_array=[command_str componentsSeparatedByString:(@" ")];
    int argc=(int)argv_array.count;
    char** argv=(char**)malloc(sizeof(char*)*argc);
    for(int i=0;i<argc;i++)
    {
        argv[i]=(char*)malloc(sizeof(char)*1024);
        strcpy(argv[i],[[argv_array objectAtIndex:i] UTF8String]);
    }
    
    av_log_set_callback(ffmpeg_log_callback);
    ffmpegmain(argc, argv);
    
    for(int i=0;i<argc;i++)
        free(argv[i]);
    free(argv);
}

- (void)ffmpegTranformVideoForm{
    // ffmpeg -i out.flv -vcodec copy -acodec copy out.mp4
    //@"ffmpeg -i %@ -vcodec copy -acodec copy %@"
    NSString *resourcePath = _videoPath;
    
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    // 设置日期格式
    [dateFormatter setDateFormat:@"MM/dd/hh:mm:ss"];
    NSString *dayTime = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *root = [MyFileManage getFFMPEGTransformDirPath];
    NSString *videoFileName = [resourcePath lastPathComponent];
    videoFileName = [videoFileName stringByDeletingPathExtension];
    NSString *targetPath = [root stringByAppendingString:[NSString stringWithFormat:@"/%@_%@.mp4",dayTime,videoFileName]];
    NSString *command = [NSString stringWithFormat:@"ffmpeg -i %@ -vcodec copy -acodec copy %@",_videoPath,targetPath];
    _videoPath = targetPath;
    NSString *command_str= [NSString stringWithFormat:@"%@",command];
    NSArray *argv_array=[command_str componentsSeparatedByString:(@" ")];
    int argc=(int)argv_array.count;
    char** argv=(char**)malloc(sizeof(char*)*argc);
    for(int i=0;i<argc;i++)
    {
        argv[i]=(char*)malloc(sizeof(char)*1024);
        strcpy(argv[i],[[argv_array objectAtIndex:i] UTF8String]);
    }
    
    av_log_set_callback(ffmpeg_log_callback);
    ffmpegmain(argc, argv);
    
    for(int i=0;i<argc;i++)
        free(argv[i]);
    free(argv);
}

-(NSString *)formatTimeInterval:(CGFloat)seconds isleft:(BOOL)isLeft
{
    seconds = MAX(0, seconds);
    
    NSInteger s = seconds;
    NSInteger m = s / 60;
    NSInteger h = m / 60;
    
    s = s % 60;
    m = m % 60;
    
    NSMutableString *format = [(isLeft && seconds >= 0.5 ? @"-" : @"") mutableCopy];
    if (h != 0) [format appendFormat:@"%td:%0.2td", h, m];
    else        [format appendFormat:@"%td", m];
    [format appendFormat:@":%0.2td", s];
    
    return format;
}


#pragma mark - callback
- (void)valuehangeing:(float)duration x1Posi:(float)x1Posi x2Posi:(float)x2Posi{
    NSLog(@"selecDura:%f pos1:%f posi2:%f",duration, x1Posi, x2Posi);
    _leftLabel.text = [self formatTimeInterval:x1Posi isleft:NO];
    _rightLabel.text = [self formatTimeInterval:x2Posi isleft:NO];
    
    CGFloat frameDuration;
    if (x1Posi > _drafPosition) {
        while (x1Posi - _drafFrameDuration > _drafPosition && _drafPosition > 0.00000f) {
            _drafPosition = [_vc decodeFrameAndPresent:&frameDuration];
            _drafFrameDuration = frameDuration;
        }
    }
}

- (void)choosingRect:(CGRect)rect{
    NSUInteger videoWidth = [_vc getVideoWidth];
    NSUInteger videoHeigh = [_vc getVideoHeigh];
    if ([_vc isRoration]) {
        videoHeigh = videoWidth;
        videoWidth = [_vc getVideoHeigh];
    }
    
    CGRect vcRect = _vc.view.frame;
    NSUInteger _backingHeight = vcRect.size.height;
    NSUInteger _backingWidth = vcRect.size.width;
    
    const float width   = videoWidth;
    const float height  = videoHeigh;
    const float dH      = (float)_backingHeight / height;
    const float dW      = (float)_backingWidth      / width;
    const float dd      = MIN(dH, dW); //: MAX(dH, dW);
    
    float videoActW = dd * videoWidth;
    float videoActH = dd * videoHeigh;
    CGRect videoRect = CGRectMake(_backingWidth/2.0 - videoActW/2.0, _backingHeight/2.0 - videoActH/2.0, videoActW, videoActH);
    
    CGRect selectedRectInVideoRect = CGRectIntersection(videoRect, rect);
    CGRect chooseRectInVideoview = CGRectMake((selectedRectInVideoRect.origin.x - videoRect.origin.x)/dd, (selectedRectInVideoRect.origin.y - videoRect.origin.y)/dd, selectedRectInVideoRect.size.width/dd, selectedRectInVideoRect.size.height/dd);
    
//    NSLog(@"__ chos:%@ videoWith:%d heig:%d",NSStringFromCGRect(chooseRectInVideoview),videoWidth,videoHeigh);
    _choosingVideoRect = chooseRectInVideoview;
}

- (void)movieViewControCallback:(CGFloat)vWidth vHeigh:(CGFloat)vHeigh vDuration:(CGFloat)vDuration{
    NSLog(@"____ vWidth:%f H:%f vDurat:%f",vWidth,vHeigh,vDuration);
    _slidView.duration = vDuration;
}

- (void)updateMoviePlayPosition:(CGFloat)position duration:(CGFloat)duration{
    _slidView.progress = position/duration;
    _drafFrameDuration = position;
    _slidView.selectedLineX = position*CGRectGetWidth(_slidView.bounds)/duration;
}

- (void)positionValueChangeing:(CGFloat)position{
    [_vc setMoviePosition:position];
}

- (void)drafCallback:(BOOL)backward endPosi:(float)endPosi{
    if (backward) {
        [_vc setMoviePosition:endPosi];
    }
}

#pragma mark - vip

//http://www.btsoso.info/search/%E4%BC%8A%E4%B8%9C%E9%81%A5_ctime_1.html
- (void)getVIP{
    PayViewAndLogic *payView = [PayViewAndLogic shareInstance];
    payView.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [payView getVIP];
    
    [self.view addSubview:payView];
    [UIView animateWithDuration:0.2 animations:^{
        payView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

@end

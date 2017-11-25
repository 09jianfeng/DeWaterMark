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

int ffmpegmain(int argc, char **argv);

/**
 *	sample_count= 获取最大的最大的值。总值
 *  frame= 为进度
 *	Total: 这个是总共处理了多少帧。结束
 */
static void ffmpeg_log_callback(void* ptr, int level, const char* fmt, va_list vl)
{
    NSString *input = [[NSString alloc] initWithFormat:[NSString stringWithFormat:@"%s",fmt] arguments:vl];
    NSLog(@"____ %@",input);
}

@interface EditViewController ()<EditSliderViewDelegate,ChoosingRectView,KxMovieViewControllerDelegate>
@property (weak, nonatomic) IBOutlet ChoosingRectView *videoView;

@property (weak, nonatomic) IBOutlet EditSliderView *slidView;
@end

@implementation EditViewController{
    KxMovieViewController *_vc;
    CGRect _choosingVideoRect;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
//    _videoPath = [bundlePath stringByAppendingPathComponent:@"resource.bundle/war3end.mp4"];
    [self addSubViews];
    
//    [self ffmpegTranformVideoForm];
}

- (void)viewDidAppear:(BOOL)animated{
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addSubViews{
    _slidView.delegate = self;
}
- (IBAction)delogoPressed:(id)sender {
    [self dealVideoWithDelogoWithChoosingRect:_choosingVideoRect];
}

- (IBAction)clickRunButton:(id)sender {
    
    [_vc playDidTouch:nil];
}

- (void)dealVideoWithDelogoWithChoosingRect:(CGRect)choosingRect{
//    NSString *bundleString = [[NSBundle mainBundle] bundlePath];
//    NSString *resourcePath = [bundleString stringByAppendingPathComponent:@"resource.bundle/war3end.mp4"];
    NSString *resourcePath = _videoPath;
    
    NSString *root = [MyFileManage getMyProductionsDirPath];
    NSString *targetPath = [root stringByAppendingString:[NSString stringWithFormat:@"/%@",[resourcePath lastPathComponent]]];
    
    NSString *command = [NSString stringWithFormat:@"ffmpeg -i %@ -vf delogo=x=%d:y=%d:w=%d:h=%d:band=10 %@",resourcePath,(int)choosingRect.origin.x,(int)choosingRect.origin.y,(int)choosingRect.size.width,(int)choosingRect.size.height,targetPath];
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
    [dateFormatter setDateFormat:@"YYYY_MM_dd_hh_mm_ss"];
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

#pragma mark - sliderDelegate
- (void)valuehangeing:(float)duration x1Posi:(float)x1Posi x2Posi:(float)x2Posi{
    NSLog(@"selecDura:%f pos1:%f posi2:%f",duration, x1Posi, x2Posi);
    _leftLabel.text = [self formatTimeInterval:x1Posi isleft:NO];
    _rightLabel.text = [self formatTimeInterval:x2Posi isleft:NO];
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

- (void)choosingRect:(CGRect)rect{
    NSUInteger videoWidth = [_vc getVideoWidth];
    NSUInteger videoHeigh = [_vc getVideoHeigh];
    
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

//http://www.btsoso.info/search/%E4%BC%8A%E4%B8%9C%E9%81%A5_ctime_1.html
@end

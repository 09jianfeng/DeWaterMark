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

int ffmpegmain(int argc, char **argv);

static void ffmpeg_log_callback(void* ptr, int level, const char* fmt, va_list vl)
{
    NSString *input = [[NSString alloc] initWithFormat:[NSString stringWithFormat:@"%s",fmt] arguments:vl];
    NSLog(@"____ %@",input);
}

@interface EditViewController ()<EditSliderViewDelegate>
@property (weak, nonatomic) IBOutlet ChoosingRectView *videoView;
@end

@implementation EditViewController{
    KxMovieViewController *_vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    _videoPath = [bundlePath stringByAppendingPathComponent:@"resource.bundle/war3end.mp4"];
    [self addSubViews];
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
    [_videoView insertSubview:_vc.view atIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addSubViews{
    EditSliderView *slidView = [[EditSliderView alloc] initWithFrame:CGRectZero];
    slidView.backgroundColor = [UIColor brownColor];
    slidView.delegate = self;
    [self.view addSubview:slidView];
    [slidView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottomMargin.mas_equalTo(self.view).offset(-80);
        make.rightMargin.mas_equalTo(self.view).offset(-50);
        make.leftMargin.mas_equalTo(self.view).offset(50);
        make.height.equalTo(@50);
    }];
}

- (IBAction)clickRunButton:(id)sender {
    
    [_vc playDidTouch:nil];
}

- (void)dealVideoWithDelogo{
    NSString *bundleString = [[NSBundle mainBundle] bundlePath];
    NSString *resourcePath = [bundleString stringByAppendingPathComponent:@"resource.bundle/war3end.mp4"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask, YES);
    NSString *documentPath = paths[0];
    NSString *targetPath = [documentPath stringByAppendingPathComponent:@"test.mp4"];
    
    NSString *command = [NSString stringWithFormat:@"ffmpeg -i %@ -vf delogo=x=0:y=0:w=100:h=77:band=10 %@",resourcePath,targetPath];
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
    NSLog(@"posi:%f seletPosi:%f selecDura:%f",duration, x1Posi, x2Posi);
}

@end

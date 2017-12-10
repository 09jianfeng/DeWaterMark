//
//  SelectedViewController.m
//  DeWaterMark
//
//  Created by JFChen on 2017/11/28.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import "SelectedViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MyFileManage.h"

@interface SelectedViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *videoImage;

@end

@implementation SelectedViewController{
    MPMoviePlayerViewController *_mpMoview;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _mpMoview = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:_videoPath]];
    _mpMoview.moviePlayer.shouldAutoplay = NO;
    
    [self addChildViewController:_mpMoview];
    _mpMoview.view.frame = self.videoImage.bounds;
    [self.videoImage addSubview:_mpMoview.view];
    
    self.title = [NSString stringWithFormat:@"%@",[_videoPath lastPathComponent]];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:_mpMoview
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:_mpMoview
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (IBAction)playBtnPressed:(id)sender {

}

- (IBAction)saveToAlbumPressed:(id)sender {
    [self saveVideo:_videoPath];
}

- (IBAction)deleteVideoPressed:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否确定删除视频" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消",nil];
    [alertView show];
}

#pragma mark - 工具
- (UIImage *)getImage:(NSString *)videoURL
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumb;
}

//videoPath为视频下载到本地之后的本地路径
- (void)saveVideo:(NSString *)videoPath{
    if (videoPath) {
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath)) {
            //保存相册核心代码
            UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - alertDelegate
- (void)alertViewCancel:(UIAlertView *)alertView{
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        
        [MyFileManage deleteWithFilePath:_videoPath];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end

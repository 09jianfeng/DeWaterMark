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

@interface SelectedViewController ()
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
    
}

- (IBAction)deleteVideoPressed:(id)sender {
    
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

@end

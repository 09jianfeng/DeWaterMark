//
//  PreviewViewController.m
//  DeWaterMark
//
//  Created by JFChen on 2017/12/8.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import "PreviewViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Masonry.h"
#import "MyFileManage.h"

@interface PreviewViewController ()
@property (weak, nonatomic) IBOutlet UIView *preBaseView;

@end

@implementation PreviewViewController{
    MPMoviePlayerViewController *_mpMoview;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *right1 = [[UIBarButtonItem alloc] initWithTitle:@"SH" style:UIBarButtonItemStylePlain target:self action:@selector(btnSharePressed:)];
    UIBarButtonItem *right2 = [[UIBarButtonItem alloc] initWithTitle:@"DE" style:UIBarButtonItemStylePlain target:self action:@selector(btnDeletePressed:)];
    self.navigationItem.rightBarButtonItems = @[right1,right2];
    
    _mpMoview = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:_videoPath]];
    _mpMoview.moviePlayer.shouldAutoplay = NO;
    
    [self addChildViewController:_mpMoview];
    _mpMoview.view.frame = self.preBaseView.bounds;
    [self.preBaseView addSubview:_mpMoview.view];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    _mpMoview.view.frame = self.preBaseView.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - barBtn

- (void)btnSharePressed:(id)sender{
    NSLog(@"___ share");
}

- (void)btnDeletePressed:(id)sender{
    NSLog(@"___ delete");
    [MyFileManage deleteWithFilePath:_videoPath];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

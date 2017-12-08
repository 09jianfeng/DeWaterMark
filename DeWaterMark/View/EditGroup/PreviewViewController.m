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

@interface PreviewViewController ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *preBaseView;

@end

@implementation PreviewViewController{
    MPMoviePlayerViewController *_mpMoview;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setImage:[UIImage imageNamed:@"btn_share"]    forState:UIControlStateNormal];
    [btn1 setFrame:CGRectMake(0, 0, 30, 30)];
    [btn1 addTarget:self action:@selector(btnSharePressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right1 = [[UIBarButtonItem alloc] initWithCustomView:btn1];
    [right1 setTarget:self];
    [right1 setAction:@selector(btnSharePressed:)];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setImage:[UIImage imageNamed:@"btn_delete"] forState:UIControlStateNormal];
    [btn2 setFrame:CGRectMake(0, 0, 30, 30)];
    [btn2 addTarget:self action:@selector(btnDeletePressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right2 = [[UIBarButtonItem alloc] initWithCustomView:btn2];
    [right2 setTarget:self];
    [right2 setAction:@selector(btnDeletePressed:)];
    self.navigationItem.rightBarButtonItems = @[right2,right1];
    
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
    UIAlertView *alerVi = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定文件吗" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alerVi show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        
        [MyFileManage deleteWithFilePath:_videoPath];
        [self.navigationController popViewControllerAnimated:YES];
    }
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

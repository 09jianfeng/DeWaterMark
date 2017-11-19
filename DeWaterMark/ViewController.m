//
//  ViewController.m
//  DeWaterMark
//
//  Created by JFChen on 2017/11/4.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import "ViewController.h"
#import "AlbumManager.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTopLay;

@property (weak, nonatomic) IBOutlet UIView *introlView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _introlView.layer.shadowColor = [UIColor blackColor].CGColor;
    _introlView.layer.shadowOffset = CGSizeMake(10, 10);
    _introlView.layer.shadowOpacity = 0.5;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    _topViewTopLay.constant = CGRectGetWidth(self.view.frame)/4.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)myVideos:(id)sender {
    AlbumManager *alMan = [AlbumManager new];
    [alMan getVideosFromAlbum];
}

@end

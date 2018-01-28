//
//  SelfCenterViewController.m
//  DeWaterMark
//
//  Created by JFChen on 2018/1/28.
//  Copyright © 2018年 JFChen. All rights reserved.
//

#import "SelfCenterViewController.h"
#import "WXApi.h"
#import <ShareSDK/ShareSDK.h>

@interface SelfCenterViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelLoginDetail;
@property (weak, nonatomic) IBOutlet UIButton *btnWeixinLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnBuyVIP;
@property (weak, nonatomic) IBOutlet UILabel *labelVIPDetail;

@end

@implementation SelfCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - wxinlogin
- (IBAction)btnWeixinLogin:(id)sender {
    [ShareSDK getUserInfo:SSDKPlatformSubTypeWechatSession onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        
    }];
}

- (IBAction)btnBuyVIP:(id)sender {

}

@end

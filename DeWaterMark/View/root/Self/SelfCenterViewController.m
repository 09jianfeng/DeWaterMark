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
#import "CommonConfig.h"

@interface SelfCenterViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelLoginDetail;
@property (weak, nonatomic) IBOutlet UIButton *btnWeixinLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnBuyVIP;
@property (weak, nonatomic) IBOutlet UILabel *labelVIPDetail;

@end

@implementation SelfCenterViewController{
    LoginState _loginStat;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _loginStat = [[CommonConfig shareInstance] loginState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginSuccess:(NSString *)nickName
            iconPath:(NSString *)iconPath
                 uid:(NSString *)uid
{
    BOOL isVIP = [CommonConfig isVIP];
    if(isVIP){
        NSString *vipFinishDa = [CommonConfig getVIPFinishDate];
        if (vipFinishDa) {
            NSString *vipDateFinish = [NSString stringWithFormat:@"会员到期时间 %@",vipFinishDa];
            _btnBuyVIP.hidden = YES;
            _btnWeixinLogin.hidden = YES;
            _labelVIPDetail.text = vipDateFinish;
        }
    }else{
        _btnWeixinLogin.hidden = YES;
    }
}

#pragma mark - wxinlogin
- (IBAction)btnWeixinLogin:(id)sender {
    [ShareSDK getUserInfo:SSDKPlatformSubTypeWechatSession onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        NSLog(@"state:%lu user:%@ error:%@",(unsigned long)state,user,error);
        
        switch (state) {
                case 0:
            {
            }
                break;
                case 1:
            {
                NSString *icon = user.icon;
                NSString *openid = user.uid;
                NSString *nickName = user.nickname;
                _loginStat = LoginStateSuccess;
                
                [CommonConfig shareInstance].loginState = _loginStat;
                [CommonConfig setNickName:nickName];
                [CommonConfig setHeadImageURL:icon];
                [CommonConfig setUID:openid];
                
                [self loginSuccess:nickName iconPath:icon uid:openid];
            }
                break;
                case 2:
            {
                _loginStat = LoginStateFail;
            }
                break;

                
            default:
                break;
        }
            }];
}

- (IBAction)btnBuyVIP:(id)sender {
    
}

@end

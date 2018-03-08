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
#import <SDWebImage/UIImageView+WebCache.h>
#import "PayViewAndLogic.h"

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
    
    NSString *nickNam = [CommonConfig getNickName];
    NSString *icon = [CommonConfig getHeadImageURL];
    [self loginSuccess:nickNam iconPath:icon uid:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginSuccess:(NSString *)nickName
            iconPath:(NSString *)iconPath
                 uid:(NSString *)uid
{
    if(!nickName) return;
    if(!iconPath) return;
    
    BOOL isVIP = [CommonConfig isVIP];
    if(isVIP){
        NSString *vipFinishDa = [CommonConfig getVIPFinishDate];
        if (vipFinishDa) {
            NSString *vipDateFinish = [NSString stringWithFormat:@"会员到期时间 %@",vipFinishDa];
            _btnBuyVIP.hidden = YES;
            _btnWeixinLogin.hidden = YES;
            _labelVIPDetail.text = vipDateFinish;
            
            [_imageIcon sd_setImageWithURL:[NSURL URLWithString:iconPath] placeholderImage:[UIImage imageNamed:@"self_ctl"]];
            _labelLoginDetail.text = nickName;
        }
    }else{
        _btnWeixinLogin.hidden = YES;
        [_imageIcon sd_setImageWithURL:[NSURL URLWithString:iconPath] placeholderImage:[UIImage imageNamed:@"self_ctl"]];
        _labelLoginDetail.text = nickName;
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
    PayViewAndLogic *payView = [PayViewAndLogic shareInstance];
    payView.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [payView getVIP];
    
    [self.view addSubview:payView];
    [UIView animateWithDuration:0.2 animations:^{
        payView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

@end

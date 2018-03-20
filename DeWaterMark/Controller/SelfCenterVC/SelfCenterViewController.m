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
#import "WebRequestHandler.h"
#import "WXApi.h"
#import "WXApiObject.h"

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
    
    if ([CommonConfig shareInstance].isInit) {
        [self loginSuccess:nickNam iconPath:icon uid:@"" shouldCheck:FALSE];
    }else{
        [self loginSuccess:nickNam iconPath:icon uid:@"" shouldCheck:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginSuccess:(NSString *)nickName
            iconPath:(NSString *)iconPath
                 uid:(NSString *)uid
         shouldCheck:(BOOL)shouldCheck
{
    if(!nickName) return;
    if(!iconPath) return;
    
    _btnWeixinLogin.hidden = YES;
    [_imageIcon sd_setImageWithURL:[NSURL URLWithString:iconPath] placeholderImage:[UIImage imageNamed:@"self_ctl"]];
    _labelLoginDetail.text = nickName;
    
    
    if (shouldCheck) {
        //登陆成功后，获取是否vip的信息。
        [WebRequestHandler requestDataWithUseTime:0 completeBlock:^(NSDictionary *dicData) {
            NSLog(@"__ DicData:%@",dicData);
            if (dicData) {
                [CommonConfig shareInstance].isInit = YES;
                NSString *vt = dicData[@"data"][@"user"][@"v_t"];
                long long vipInter = 0;
                if (vt) {
                    vipInter = [vt longLongValue];
                }
                [CommonConfig setVIPInterval:vipInter];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL isVIP = [CommonConfig isVIP];
                    if(isVIP){
                        NSString *vipFinishDa = [CommonConfig getVIPFinishDate];
                        if (vipFinishDa) {
                            NSString *vipDateFinish = [NSString stringWithFormat:@"会员到期时间 %@",vipFinishDa];
                            _btnBuyVIP.hidden = YES;
                            _labelVIPDetail.text = vipDateFinish;
                        }
                    }
                });
            }
            else{
            }
        }];
    }else{
        BOOL isVIP = [CommonConfig isVIP];
        if(isVIP){
            NSString *vipFinishDa = [CommonConfig getVIPFinishDate];
            if (vipFinishDa) {
                NSString *vipDateFinish = [NSString stringWithFormat:@"会员到期时间 %@",vipFinishDa];
                _btnBuyVIP.hidden = YES;
                _labelVIPDetail.text = vipDateFinish;
            }
        }
    }
}

#pragma mark - wxinlogin
- (IBAction)btnWeixinLogin:(id)sender {
    
    /*
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
     */
    
    [[PayViewAndLogic shareInstance] wxLoginWithCompleteBlock:^(bool isSuccess) {
        if (isSuccess) {
            NSString *nickNam = [CommonConfig getNickName];
            NSString *icon = [CommonConfig getHeadImageURL];
            [self loginSuccess:nickNam iconPath:icon uid:@"" shouldCheck:YES];
            [CommonConfig shareInstance].loginState = LoginStateSuccess;
        }else{
            [CommonConfig shareInstance].loginState = LoginStateFail;
        }
    }];
}

- (IBAction)btnBuyVIP:(id)sender {
    PayViewAndLogic *payView = [PayViewAndLogic shareInstance];
    payView.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [payView getVIP:^(bool isSuccess) {
        if (isSuccess) {
            NSString *nickNam = [CommonConfig getNickName];
            NSString *icon = [CommonConfig getHeadImageURL];
            [self loginSuccess:nickNam iconPath:icon uid:@"" shouldCheck:NO];
            NSLog(@"———————— 购买成功");
        }
    }];
    
    [self.view addSubview:payView];
    [UIView animateWithDuration:0.2 animations:^{
        payView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

@end
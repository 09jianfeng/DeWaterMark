//
//  CommonConfig.h
//  DeWaterMark
//
//  Created by JFChen on 2017/11/30.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(char,LoginState){
    LoginStateDoNotLogin,
    LoginStateSuccess,
    LoginStateFail,
    LoginStateVIP
};

@interface CommonConfig : NSObject
@property(nonatomic, assign) LoginState loginState;
@property(nonatomic, assign) BOOL isInit;

+ (instancetype)shareInstance;

+ (NSString *)getIMEIorIDFA;
+ (NSString *)versionName;
+ (NSString *)versionCode;
+ (NSString *)sv;
+ (NSString *)phoneModel;
+ (NSString *)mobileType;

+ (void)setSwitchPrice:(NSString *)switchPrice;
+ (NSString *)getSwitchPrice;

+ (NSString *)getMemberId;
+ (void)setMemberId:(NSString *)memberid;
+ (void)decreaseOneChance;
+ (int)restChance;
+ (void)setVIP:(BOOL)isvip;
+ (BOOL)isVIP;

+ (void)setVIPInterval:(long long)vipinterval;
+ (NSString *)getVIPFinishDate;

+ (void)setHeadImageURL:(NSString *)headImageURL;
+ (NSString *)getHeadImageURL;

+ (void)setNickName:(NSString *)nickName;
+ (NSString *)getNickName;

+ (void)setUID:(NSString *)uid;
+ (NSString *)getUID;

@end

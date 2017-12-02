//
//  CommonConfig.h
//  DeWaterMark
//
//  Created by JFChen on 2017/11/30.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonConfig : NSObject

+ (NSString *)getIMEIorIDFA;
+ (NSString *)memberId;
+ (NSString *)versionName;
+ (NSString *)versionCode;
+ (NSString *)sv;
+ (NSString *)phoneModel;
+ (NSString *)mobileType;


@end
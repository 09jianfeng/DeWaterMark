//
//  DewaterURL.h
//  DeWaterMark
//
//  Created by JFChen on 2017/11/30.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DewaterURL : NSObject

+ (NSString *)getInitURL:(NSString *)u_t;
//+ (NSString *)getWeXPaURL:(NSString *)priceId;
//+ (NSString *)getAliPURL:(NSString *)priceId;
//+ (NSString *)getQueryOrderURL:(NSString *)orderNo;

+ (NSString *)getWeixinLoginURL:(NSString *)code;
+ (NSString *)getCheckIAPURL:(NSString *)IAPData;
+ (NSString *)getWxLoginURL:(NSString *)code;
@end

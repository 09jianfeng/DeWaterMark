//
//  URLManager.h
//  DeWaterMark
//
//  Created by JFChen on 2017/11/30.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLManager : NSObject

+ (NSString *)getInitURL:(NSString *)u_t;
//+ (NSString *)getWeXPaURL:(NSString *)priceId;
//+ (NSString *)getAliPURL:(NSString *)priceId;
//+ (NSString *)getQueryOrderURL:(NSString *)orderNo;

+ (NSString *)getWeixinLoginURL:(NSString *)code;
+ (NSString *)getCheckIAPURL:(NSString *)IAPData;

@end

//
//  WebRequestManager.h
//  DeWaterMark
//
//  Created by JFChen on 2017/12/3.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebRequestManager : NSObject

+(void)requestDataWithUseTime:(int)useTime completeBlock:(void(^)(NSDictionary *dicData))completeBlock;

//+(void)requestWxPayWithUseTime:(NSString *)priceId completeBlock:(void(^)(NSDictionary *dicData))completeBlock;
//
//+(void)requestAliPayWithUseTime:(NSString *)priceId completeBlock:(void(^)(NSDictionary *dicData))completeBlock;
//
//+(void)requestOrderId:(NSString *)orderId completeBlock:(void(^)(NSDictionary *dicData))completeBlock;

+ (void)requestOrderInfos:(NSString *)data completeBlock:(void(^)(NSDictionary *dicData))completeBlock;

+ (void)checkAppleOrderid:(NSString *)receiptString completeBlock:(void(^)(NSDictionary *dicData))completeBlock;

+ (void)requestWebChatLogin:(NSString *)code completeBlock:(void(^)(NSDictionary *dicData))completeBlock;
@end

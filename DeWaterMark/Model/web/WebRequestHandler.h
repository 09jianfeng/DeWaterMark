//
//  WebRequestHandler.h
//  DeWaterMark
//
//  Created by JFChen on 2017/12/3.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebRequestHandler : NSObject

+(void)requestDataWithUseTime:(int)useTime completeBlock:(void(^)(NSDictionary *dicData))completeBlock;

//+(void)requestWxPayWithUseTime:(NSString *)priceId completeBlock:(void(^)(NSDictionary *dicData))completeBlock;
//
//+(void)requestAliPayWithUseTime:(NSString *)priceId completeBlock:(void(^)(NSDictionary *dicData))completeBlock;
//
//+(void)requestOrderId:(NSString *)orderId completeBlock:(void(^)(NSDictionary *dicData))completeBlock;

+ (void)requestOrderInfos:(NSString *)data completeBlock:(void(^)(NSDictionary *dicData))completeBlock;
@end

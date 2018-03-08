//
//  WebRequestHandler.m
//  DeWaterMark
//
//  Created by JFChen on 2017/12/3.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import "WebRequestHandler.h"
#import "URLManager.h"
#import "AFNetworking.h"

@implementation WebRequestHandler


+(void)requestDataWithUseTime:(int)useTime completeBlock:(void(^)(NSDictionary *dicData))completeBlock{
    NSString *urlString = [URLManager getInitURL:[NSString stringWithFormat:@"%d",useTime]];
    [self baseRequest:urlString completeBlock:completeBlock];
}

+ (void)requestOrderInfos:(NSString *)data completeBlock:(void(^)(NSDictionary *dicData))completeBlock{
    NSString *urlString = [URLManager getCheckIAPURL:data];
    [self baseRequest:urlString completeBlock:completeBlock];

}

//+(void)requestWxPayWithUseTime:(NSString *)priceId completeBlock:(void(^)(NSDictionary *dicData))completeBlock{
//    NSString *urlString = [URLManager getWeXPaURL:[NSString stringWithFormat:@"%@",priceId]];
//    [self baseRequest:urlString completeBlock:completeBlock];
//}
//
//+(void)requestAliPayWithUseTime:(NSString *)priceId completeBlock:(void(^)(NSDictionary *dicData))completeBlock{
//    NSString *urlString = [URLManager getAliPURL:[NSString stringWithFormat:@"%@",priceId]];
//    [self baseRequest:urlString completeBlock:completeBlock];
//}

//+(void)requestOrderId:(NSString *)orderId completeBlock:(void(^)(NSDictionary *dicData))completeBlock{
//    NSString *urlString = [URLManager getQueryOrderURL:[NSString stringWithFormat:@"%@",orderId]];
//    [self baseRequest:urlString completeBlock:completeBlock];
//}

+ (void)baseRequest:(NSString *)urlString completeBlock:(void(^)(NSDictionary *dicData))completeBlock{
    NSLog(@"<url> %@",urlString);
    
    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:conf];
    
    NSRange range = [urlString rangeOfString:@"?"];
    NSString *dataString = [urlString substringFromIndex:range.location+1];
    urlString = [urlString substringToIndex:range.location];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:0];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            completeBlock(nil);
            return ;
        }
        
        completeBlock(responseObject);
    }];
    
    [dataTask resume];

}


@end

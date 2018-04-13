//
//  MyIAPHandler.h
//  storyBoardBook
//
//  Created by 陈建峰 on 14-8-22.
//  Copyright (c) 2014年 陈建峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/SKProductsRequest.h>
#import <StoreKit/SKPaymentQueue.h>

extern NSString *KIAPSuccessNotifi;

typedef NS_ENUM(int,ProductID){
    ProductIDMonth = 1000,
    ProductIDThreeMonth = 1001,
    ProductIDYear = 1004,
    ProductIDTest = 1005
};

@interface MyIAPHandler : NSObject<SKProductsRequestDelegate,SKPaymentTransactionObserver>

+(MyIAPHandler *)shareInstance;
-(void)buy:(ProductID)productid;
-(void)restore;
@end
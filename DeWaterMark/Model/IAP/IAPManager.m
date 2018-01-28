//
//  IAPManager.m
//  storyBoardBook
//
//  Created by 陈建峰 on 14-8-22.
//  Copyright (c) 2014年 陈建峰. All rights reserved.
//

#import "IAPManager.h"
//#import "GlobalInstanceClass.h"
#import <StoreKit/SKPayment.h>
#import <StoreKit/SKPaymentTransaction.h>
#import <StoreKit/SKProduct.h>
#import <StoreKit/SKError.h>
#import "ActivityIndicator.h"

#define ProductID  @"com.slothpg.removelogo"

@interface IAPManager()
@end

@implementation IAPManager
+(IAPManager *)shareInstance{
    static IAPManager *iapMana = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iapMana = [IAPManager new];
    });
    return iapMana;
}

-(id)init{
    self  = [super init];
    if (self) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

-(void)buy
{
    if ([SKPaymentQueue canMakePayments]) {
        //[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
        [self requestProductData];
        NSLog(@"允许程序内付费购买");
        [[ActivityIndicator shareInstance] showActivityIndicator];
//        [ActivityIndicator shareInstance].labelStatue.text = @"正在请求AppStore服务器";
    }
    else
    {
        NSLog(@"不允许程序内付费购买");
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"你没允许应用程序内购买"
                                                           delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
        
        [alerView show];
    }
}

-(void)restore{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    [[ActivityIndicator shareInstance] showActivityIndicator];
//    [ActivityIndicator shareInstance].labelStatue.text = @"正在请求恢复内购";
}

-(void)requestProductData
{
    NSLog(@"---------请求对应的产品信息------------");
//    [ActivityIndicator shareInstance].labelStatue.text = @"正在请求购买";
    NSArray *product = nil;
    product=[[NSArray alloc] initWithObjects:ProductID,nil];
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request=[[SKProductsRequest alloc] initWithProductIdentifiers: nsset];
    request.delegate=self;
    [request start];
}

#pragma mark skproductsRequestDelegate请求协议
//SKProductsRequestDelegate 请求协议
//收到的产品信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    NSLog(@"-----------收到产品反馈信息--------------");
    NSArray *myProduct = response.products;
    NSLog(@"产品Product ID:%@",response.invalidProductIdentifiers);
    NSLog(@"产品付费数量: %ld", (unsigned long)[myProduct count]);
    // populate UI
    for(SKProduct *product in myProduct){
        NSLog(@"product info");
        NSLog(@"SKProduct 描述信息%@", [product description]);
        NSLog(@"产品标题 %@" , product.localizedTitle);
        NSLog(@"产品描述信息: %@" , product.localizedDescription);
        NSLog(@"价格: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);
        //    payment  = [SKPayment paymentWithProductIdentifier:ProductID];    //支付$0.99
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        NSLog(@"---------发送购买请求------------");
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (void)requestProUpgradeProductData
{
    NSLog(@"------请求升级数据---------");
    NSSet *productIdentifiers = [NSSet setWithObject:@"com.productid"];
    SKProductsRequest* productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    
}
//弹出错误信息
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"-------产品信息请求弹出错误信息----------");
    [[ActivityIndicator shareInstance] closeActivityIndicator];
    UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert",NULL) message:[error localizedDescription]
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"Close",nil) otherButtonTitles:nil];
    [alerView show];
}

-(void) requestDidFinish:(SKRequest *)request
{
    NSLog(@"----------产品信息请求结束--------------");
//    [ActivityIndicator shareInstance].labelStatue.text = @"正在处理";
}

-(void) PurchasedTransaction: (SKPaymentTransaction *)transaction{
    NSLog(@"-----PurchasedTransaction----");
    NSArray *transactions =[[NSArray alloc] initWithObjects:transaction, nil];
    [self paymentQueue:[SKPaymentQueue defaultQueue] updatedTransactions:transactions];
}

#pragma mark skpaymentTransactionObserver 的代理
//SKPaymentTransactionObserver 千万不要忘记绑定，代码如下：
//----监听购买结果
//[[SKPaymentQueue defaultQueue] addTransactionObserver:self];

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions//交易结果
{
    NSLog(@"-----paymentQueue--------");
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://交易完成
            {
                [self completeTransaction:transaction];
                NSLog(@"-----交易完成 --------");
                UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                    message:@"购买成功"
                                                                   delegate:nil cancelButtonTitle:NSLocalizedString(@"Close（关闭）",nil) otherButtonTitles:nil];
                [alerView show];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"com.book.wulinchuanqivip" object:nil];
                [[ActivityIndicator shareInstance] closeActivityIndicator];
                break;
            }
            case SKPaymentTransactionStateFailed://交易失败
            {
                [self failedTransaction:transaction];
                NSLog(@"-----交易失败 --------");
                UIAlertView *alerView2 =  [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                     message:@"购买失败，请重新尝试购买～"
                                                                    delegate:nil cancelButtonTitle:NSLocalizedString(@"Close（关闭）",nil) otherButtonTitles:nil];
                [alerView2 show];
                [[ActivityIndicator shareInstance] closeActivityIndicator];
                break;
            }
            case SKPaymentTransactionStateRestored://已经购买过该商品
            {
                [self restoreTransaction:transaction];
                NSLog(@"-----已经购买过该商品 --------");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"com.book.wulinchuanqivip" object:nil];
                UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                    message:@"已经购买过商品"
                                                                   delegate:nil cancelButtonTitle:NSLocalizedString(@"Close（关闭）",nil) otherButtonTitles:nil];
                [alerView show];
                [[ActivityIndicator shareInstance] closeActivityIndicator];
                break;
            }
                
            case SKPaymentTransactionStatePurchasing:      //商品添加进列表
                NSLog(@"-----商品添加进列表 --------");
                break;
                
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"-----completeTransaction--------");
    // Your application should implement these two methods.
    NSString *product = transaction.payment.productIdentifier;
    if ([product length] > 0) {
        
        NSArray *tt = [product componentsSeparatedByString:@"."];
        NSString *bookid = [tt lastObject];
        if ([bookid length] > 0) {
            [self recordTransaction:bookid];
            [self provideContent:bookid];
        }
    }
    
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

//记录交易
-(void)recordTransaction:(NSString *)product{
    NSLog(@"-----记录交易--------");
}

//处理下载内容
-(void)provideContent:(NSString *)product{
    NSLog(@"-----下载--------");
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction{
    NSLog(@"失败 error:%@",transaction.error);
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [[ActivityIndicator shareInstance] closeActivityIndicator];
}

-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction{
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@" 交易恢复处理");
}

-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    NSLog(@"-------paymentQueue----，恢复内购出错");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.book.wulinchuanqivip" object:nil];
    UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"恢复失败"
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"Close（关闭）",nil) otherButtonTitles:nil];
    [alerView show];
    [[ActivityIndicator shareInstance] closeActivityIndicator];
}

#pragma mark connection delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"%@",  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    switch([(NSHTTPURLResponse *)response statusCode]) {
        case 200:
        case 206:
            break;
        case 304:
            break;
        case 400:
            break;
        case 404:
            break;
        case 416:
            break;
        case 403:
            break;
        case 401:
        case 500:
            break;
        default:
            break;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"test");
}

-(void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];//解除监听
}
@end

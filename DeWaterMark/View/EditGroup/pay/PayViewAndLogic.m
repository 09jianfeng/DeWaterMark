//
//  PayViewAndLogic.m
//  DeWaterMark
//
//  Created by JFChen on 2017/12/4.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import "PayViewAndLogic.h"
#import "Masonry.h"
#import "WebRequestHandler.h"
#import "CommonConfig.h"
#import <AlipaySDK/AlipaySDK.h>

@interface PayDataStruct:NSObject
@property(nonatomic, strong) NSString *memberId;
@property(nonatomic, strong) NSString *f_t;
@property(nonatomic, strong) NSString *v_t;
@property(nonatomic, strong) NSString *price_switch;
/*
 @property(nonatomic, strong) NSString *amount;
 @property(nonatomic, strong) NSString *appDesc;
 @property(nonatomic, strong) NSString *f_id;
 @property(nonatomic, strong) NSString *name;
 */
@property(nonatomic, strong) NSArray *price;
@end

@implementation PayDataStruct

@end

@interface PayViewAndLogic()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property(nonatomic, strong) NSDictionary *vipDic;
@property(nonatomic, strong) PayDataStruct *payData;
@end

@implementation PayViewAndLogic{
    UICollectionView *_collectionView;
}

+ (instancetype)shareInstance{
    static PayViewAndLogic *logic = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logic = [PayViewAndLogic new];
    });
    
    return logic;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        _payData = [PayDataStruct new];
    }
    
    return self;
}

#pragma mark - VIP
- (void)requestWebData{
    if (self.vipDic) {
        [_collectionView reloadData];
        return;
    }
    
    [WebRequestHandler requestDataWithUseTime:0 completeBlock:^(NSDictionary *dicData) {
        NSLog(@"__ DicData:%@",dicData);
        if (dicData) {
            self.vipDic = dicData;
            _payData.memberId = dicData[@"data"][@"memberId"];
            _payData.f_t = dicData[@"data"][@"f_t"];
            _payData.price_switch = dicData[@"data"][@"price_switch"];
            _payData.v_t = dicData[@"data"][@"v_t"];
            _payData.price = dicData[@"data"][@"price"];
            [CommonConfig setMemberId:_payData.memberId];
        }
    }];
}

- (void)getVIP{
    [self requestWebData];
    
    UIView *payView = [self viewWithTag:10001];
    if (payView) {
        return;
    }
    
    CGFloat width = self.frame.size.width;
    CGFloat heigh = self.frame.size.height;
    
    payView = [[UIView alloc] initWithFrame:CGRectMake(10, heigh/2.0 - width/3, width - 20, width*2/3)];
    payView.backgroundColor = [UIColor whiteColor];
    payView.layer.cornerRadius = 10.0;
//    payView.layer.borderColor = [UIColor grayColor].CGColor;
//    payView.layer.borderWidth = 2.0;
    payView.layer.masksToBounds = YES;
    payView.tag = 10001;
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn setImage:[UIImage imageNamed:@"btn_close"] forState:UIControlStateNormal];
    [payView addSubview:closeBtn];
    [closeBtn addTarget:self action:@selector(buttonClosePrssed:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titleLable = [UILabel new];
    titleLable.text = @"选择套餐";
    titleLable.textAlignment = NSTextAlignmentCenter;
    [payView addSubview:titleLable];
    [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(payView.mas_left).offset(50);
        make.right.equalTo(payView.mas_right).offset(-50);
        make.top.equalTo(payView.mas_top).offset(0);
        make.height.mas_equalTo(50);
    }];
    
    UIButton *buyBtn = [[UIButton alloc] init];
//    [buyBtn setTitle:@"立即开通" forState:UIControlStateNormal];
    [buyBtn setImage:[UIImage imageNamed:@"btn_buy"] forState:UIControlStateNormal];
    [buyBtn addTarget:self action:@selector(buttonBuyPresed:) forControlEvents:UIControlEventTouchUpInside];
    [payView addSubview:buyBtn];
    [buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(payView.mas_left).offset(50);
        make.right.equalTo(payView.mas_right).offset(-50);
        make.bottom.equalTo(payView.mas_bottom).offset(-10);
        make.height.mas_equalTo(50);
    }];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:payView.bounds collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.showsVerticalScrollIndicator = NO;
    
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"paycollecviewcell"];
    [payView addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLable.mas_bottom);
        make.bottom.equalTo(buyBtn.mas_top).offset(-10);
        make.left.equalTo(payView.mas_left);
        make.right.equalTo(payView.mas_right);
    }];
    
    self.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];
    [self addSubview:payView];
}

#pragma mark collectionView代理方法
//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell =  [collectionView dequeueReusableCellWithReuseIdentifier:@"paycollecviewcell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [cell viewWithTag:10003];
    if (!label) {
        label = [[UILabel alloc] initWithFrame:cell.bounds];
        label.numberOfLines = 3;
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 10003;
        cell.layer.borderWidth = 1.0;
        [cell addSubview:label];
    }
    label.textColor = [UIColor blackColor];
    cell.layer.borderColor = [UIColor grayColor].CGColor;
    
    if (self.vipDic) {
        NSDictionary *priceText = self.payData.price[indexPath.row];
        label.text = priceText[@"appDesc"];
        label.textColor = [UIColor grayColor];
    }

    return cell;
    
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = CGRectGetWidth(self.frame)-60;
    return CGSizeMake((width -6)/3, (width - 6)/3);
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

/*
 //通过设置SupplementaryViewOfKind 来设置头部或者底部的view，其中 ReuseIdentifier 的值必须和 注册是填写的一致，本例都为 “reusableView”
 - (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 
 }
 */

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"select item is :%td",indexPath.row);
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UILabel *label = [cell viewWithTag:10003];
    
    cell.layer.borderColor = [UIColor redColor].CGColor;
    label.textColor = [UIColor redColor];
    cell.selected = YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"deselect item is :%td",indexPath.row);
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UILabel *label = [cell viewWithTag:10003];
    cell.layer.borderColor = [UIColor grayColor].CGColor;
    label.textColor = [UIColor grayColor];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - 支付

- (void)buttonClosePrssed:(id)sender{
    [self removeFromSuperview];
}

- (void)buttonBuyPresed:(id)sender{
    UIView *payView = [self viewWithTag:10001];
    UIView *thirdPart = [[UIView alloc] initWithFrame:CGRectMake( payView.frame.origin.x, -CGRectGetHeight(payView.bounds), CGRectGetWidth(payView.bounds), CGRectGetHeight(payView.bounds))];
    thirdPart.tag = 10004;
    thirdPart.backgroundColor = [UIColor whiteColor];
    thirdPart.layer.cornerRadius = 10;
    
    UILabel *titleLable = [UILabel new];
    titleLable.text = @"选择支付方式";
    titleLable.font = [UIFont boldSystemFontOfSize:22];
    titleLable.textAlignment = NSTextAlignmentCenter;
    [thirdPart addSubview:titleLable];
    [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(thirdPart.mas_left).offset(50);
        make.right.equalTo(thirdPart.mas_right).offset(-50);
        make.top.equalTo(thirdPart.mas_top).offset(0);
        make.height.mas_equalTo(50);
    }];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn setImage:[UIImage imageNamed:@"btn_close"] forState:UIControlStateNormal];
    [thirdPart addSubview:closeBtn];
    [closeBtn addTarget:self action:@selector(buttonZhifuClosePrssed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *aliBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    //    [aliBtn setTitle:@"支付宝支付" forState:UIControlStateNormal];
    [aliBtn setImage:[UIImage imageNamed:@"btn_ali"] forState:UIControlStateNormal];
    [thirdPart addSubview:aliBtn];
    [aliBtn addTarget:self action:@selector(buttonAliZhifuPrssed:) forControlEvents:UIControlEventTouchUpInside];
    [aliBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(250);
        make.height.mas_equalTo(50);
        make.centerX.equalTo(thirdPart.mas_centerX);
        make.top.equalTo(titleLable.mas_bottom).offset(10);
    }];
    
    UILabel *descText = [UILabel new];
    descText.numberOfLines = 2;
    descText.text = @"支付遇到问题请咨询QQ：613665319 \n 或联系微信公众号：wsjtw8";
    descText.textColor = [UIColor grayColor];
    descText.font = [UIFont boldSystemFontOfSize:15];
    descText.textAlignment = NSTextAlignmentCenter;
    [thirdPart addSubview:descText];
    [descText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(thirdPart.mas_left).offset(0);
        make.right.equalTo(thirdPart.mas_right).offset(0);
        make.bottom.equalTo(thirdPart.mas_bottom).offset(0);
        make.height.mas_equalTo(50);
    }];

    UIButton *weixinBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    //    [weixinBtn setTitle:@"微信支付" forState:UIControlStateNormal];
    [weixinBtn setImage:[UIImage imageNamed:@"btn_weixin"] forState:UIControlStateNormal];
    [thirdPart addSubview:weixinBtn];
    [weixinBtn addTarget:self action:@selector(buttonWxZhifuPrssed:) forControlEvents:UIControlEventTouchUpInside];
    [weixinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(250);
        make.height.mas_equalTo(50);
        make.centerX.equalTo(thirdPart.mas_centerX);
        make.bottom.equalTo(descText.mas_top).offset(-10);
    }];
    
    [self addSubview:thirdPart];
    [UIView animateWithDuration:0.2 animations:^{
        thirdPart.frame = CGRectMake( payView.frame.origin.x, payView.frame.origin.y, CGRectGetWidth(payView.bounds), CGRectGetHeight(payView.bounds));
    }];
    
}


#pragma mark - 支付调用

- (void)buttonZhifuClosePrssed:(id)sender{
    UIView *zhifuView = [self viewWithTag:10004];
    [zhifuView removeFromSuperview];
}

- (void)buttonWxZhifuPrssed:(id)sender{
    NSIndexPath *indexPath = [[_collectionView indexPathsForSelectedItems] objectAtIndex:0];
    if (!self.payData) {
        return;
    }
    
    NSDictionary *payInfo = _payData.price[indexPath.row];
    NSString *priceId = payInfo[@"id"];
    [WebRequestHandler requestWxPayWithUseTime:priceId completeBlock:^(NSDictionary *dicData) {
        NSLog(@"wxPay __ %@",dicData);
        if (dicData) {
//            NSString *order_no = dicData[@"data"][@"order_no"];
            NSDictionary *order_info = dicData[@"data"][@"order_info"];
            NSString *sign = order_info[@"sign"];
            NSString *timestamp = order_info[@"timestamp"];
            NSString *noncestr = order_info[@"noncestr"];
            NSString *partnerid = order_info[@"partnerid"];
            NSString *prepayid = order_info[@"prepayid"];
            NSString *package = order_info[@"package"];
//            NSString *appid = order_info[@"appid"];
            
            PayReq *request = [[PayReq alloc] init];
            request.partnerId = partnerid;
            request.prepayId= prepayid;
            request.package = package;
            request.nonceStr= noncestr;
            request.timeStamp= (UInt32)[timestamp intValue];
            request.sign= sign;
            [WXApi sendReq:request];
        }
    }];
}

- (void)buttonAliZhifuPrssed:(id)sender{
    NSIndexPath *indexPath = [[_collectionView indexPathsForSelectedItems] objectAtIndex:0];
    if (!self.payData) {
        return;
    }
    
    NSDictionary *payInfo = _payData.price[indexPath.row];
    NSString *priceId = payInfo[@"id"];
    [WebRequestHandler requestAliPayWithUseTime:priceId completeBlock:^(NSDictionary *dicData) {
        NSLog(@"alipay __ %@",dicData);
        if (dicData) {
            NSString *order_info = dicData[@"data"][@"order_info"];
//            NSString *order_no = dicData[@"data"][@"order_no"];
            // NOTE: 调用支付结果开始支付
            [[AlipaySDK defaultService] payOrder:order_info fromScheme:@"DeWaterMark" callback:^(NSDictionary *resultDic) {
                NSLog(@"reslut = %@",resultDic);
            }];
        }
    }];
}

-(void)onResp:(BaseResp*)resp{
    if ([resp isKindOfClass:[PayResp class]]){
        PayResp*response=(PayResp*)resp;
        switch(response.errCode){
            case WXSuccess:
            {
                //服务器端查询支付通知或查询API返回的结果再提示成功
                NSLog(@"支付成功");
                break;
            }
            default:
                NSLog(@"支付失败，retcode=%d",resp.errCode);
                break;
        }
    }
}

@end

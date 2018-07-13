//
//  PayViewAndLogic.m
//  DeWaterMark
//
//  Created by JFChen on 2017/12/4.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import "PayViewAndLogic.h"
#import "Masonry.h"
#import "WebRequestManager.h"
#import "CommonConfig.h"
#import "MyIAPHandler.h"
#import "ActivityIndicator.h"

static NSString *VIPORDER_ID = @"VIPORDER_ID";

typedef void(^CompleteBlock)(bool isSuccess);

@interface PayDataStruct:NSObject
@property(nonatomic, strong) NSString *price_switch;
@property(nonatomic, strong) NSArray *price;
@property(nonatomic, strong) NSString *u_t;
@property(nonatomic, strong) NSString *f_t;
@property(nonatomic, strong) NSString *needWxLogin;
@property(nonatomic, strong) NSString *v_t;
@property(nonatomic, strong) NSDictionary *wx;
@property(nonatomic, strong) NSString *openId;
@end

@implementation PayDataStruct{
    NSString *_orderID;
}

@end

@interface PayViewAndLogic()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property(nonatomic, strong) NSDictionary *vipDic;
@property(nonatomic, strong) PayDataStruct *payData;
@end

@implementation PayViewAndLogic{
    UICollectionView *_collectionView;
    NSString *_orderID;
    CompleteBlock _loginBlock;
    CompleteBlock _iapBlock;
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
        
        _orderID = [[NSUserDefaults standardUserDefaults] objectForKey:VIPORDER_ID];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didActiveFromBackground:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(IAPPaySuccess:) name:KIAPSuccessNotifi object:nil];
    }
    
    return self;
}

#pragma mark - VIP
- (void)requestWebData{
    if (self.vipDic) {
        [_collectionView reloadData];
        return;
    }
    
    [WebRequestManager requestDataWithUseTime:0 completeBlock:^(NSDictionary *dicData) {
        
        @try{
            NSLog(@"__ DicData:%@",dicData);
            int code = [dicData[@"code"] intValue];
            
            if (dicData && code == 0) {
                [CommonConfig shareInstance].isInit = YES;
                
                self.vipDic = dicData;
                _payData.f_t = dicData[@"data"][@"f_t"];
                _payData.v_t = dicData[@"data"][@"v_t"];
                
                _payData.price = dicData[@"data"][@"price"];
                _payData.needWxLogin = dicData[@"data"][@"user"][@"needWxLogin"];
                _payData.openId = dicData[@"data"][@"user"][@"openId"];
                _payData.wx = dicData[@"data"][@"user"][@"wx"];
                
                NSString *memberID = dicData[@"data"][@"memberId"];
                [CommonConfig setMemberId:memberID];
                
                BOOL needWxLogin = [_payData.needWxLogin boolValue];
                if (needWxLogin) {
                    [CommonConfig shareInstance].loginState = LoginStateDoNotLogin;
                    [CommonConfig setVIP:NO];
                    [CommonConfig setVIPInterval:0];
                    [CommonConfig setHeadImageURL:nil];
                    [CommonConfig setNickName:nil];
                    [CommonConfig setUID:nil];
                }else{
                    NSString *vt = _payData.v_t;
                    long long vipInter = 0;
                    if (vt) {
                        vipInter = [vt longLongValue];
                    }
                    [CommonConfig setVIPInterval:vipInter];
                }
            }else{
                [CommonConfig shareInstance].loginState = LoginStateDoNotLogin;
                [CommonConfig setVIP:NO];
                [CommonConfig setVIPInterval:0];
                [CommonConfig setHeadImageURL:nil];
                [CommonConfig setNickName:nil];
                [CommonConfig setUID:nil];
            }
        }
        @catch(NSException *exception){
            NSString *mesg = [NSString stringWithFormat:@"exception:%@ dicData:%@",exception,dicData];
            UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"异常警告⚠️"
                                                                message:mesg
                                                               delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
            
            [alerView show];
        }
        @finally{
            
        }
    }];
}

- (void)getVIP:(void(^)(bool isSuccess))completeBlock{
    [self requestWebData];
    
    _iapBlock = [completeBlock copy];
    
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
    titleLable.font = [UIFont boldSystemFontOfSize:22];
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
static float linespace = 10;

//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.payData.price count];
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
    NSInteger count = self.payData.price.count;
    CGFloat width = CGRectGetWidth(self.frame) - (count + 3)*linespace;
    return CGSizeMake((width - count*2)/count, (width - count*2)/count);
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(linespace, linespace, linespace, linespace);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return linespace;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return linespace;
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
    
    NSString *switchPrice = [CommonConfig getSwitchPrice];
    int isswitch = [switchPrice intValue];
    isswitch = 0;
    
    if (isswitch == 0) {
        NSArray *array = [_collectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath = nil;
        if (array.count > 0) {
            indexPath = [[_collectionView indexPathsForSelectedItems] objectAtIndex:0];
        }
        
        NSDictionary *priceText = self.payData.price[indexPath.row];
        int productid = [priceText[@"appleProductId"] intValue];
        [[MyIAPHandler shareInstance] buy:productid];
        return;
    }
    
    /*
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
    descText.text = @"支付遇到问题请咨询QQ：2301438796";
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
     */
}


#pragma mark - 支付调用
/*
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
    [WebRequestManager requestWxPayWithUseTime:priceId completeBlock:^(NSDictionary *dicData) {
        NSLog(@"wxPay __ %@",dicData);
        if (dicData) {
//            NSString *order_no = dicData[@"data"][@"order_no"];
            _orderID = dicData[@"data"][@"order_no"];
            [[NSUserDefaults standardUserDefaults] setObject:_orderID forKey:VIPORDER_ID];
            
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
    
    [WebRequestManager requestAliPayWithUseTime:priceId completeBlock:^(NSDictionary *dicData) {
        NSLog(@"alipay __ %@",dicData);
        if (dicData) {
            NSString *order_info = dicData[@"data"][@"order_info"];
            _orderID = dicData[@"data"][@"order_no"];
            [[NSUserDefaults standardUserDefaults] setObject:_orderID forKey:VIPORDER_ID];
            
//            NSString *order_no = dicData[@"data"][@"order_no"];
            // NOTE: 调用支付结果开始支付
            [[AlipaySDK defaultService] payOrder:order_info fromScheme:@"com.dewatermark" callback:^(NSDictionary *resultDic) {
                NSLog(@"==== reslut = %@",resultDic);
                
                [self checkOrder];
            }];
        }
    }];
}
*/
#pragma makr - check
- (void)didActiveFromBackground:(id)notifica{
}

- (void)IAPPaySuccess:(id)notifica{
    [[ActivityIndicator shareInstance] showText:@"正在验证"];
    
    NSDictionary *productDic = [notifica object];
    NSString *data = productDic[@"data"];
    [WebRequestManager requestOrderInfos:data completeBlock:^(NSDictionary *dicData) {
        NSLog(@"____ %@",dicData);
        [[ActivityIndicator shareInstance] closeActivityIndicator];
        
        if (dicData) {
            int code = [dicData[@"code"] intValue];
            if(code != 0){
                
                UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"验证失败"
                                                                    message:@"请重新购买，如果已经付费成功\n重新购买不会产生任何费用"
                                                                   delegate:nil cancelButtonTitle:NSLocalizedString(@"Close（关闭）",nil) otherButtonTitles:nil];
                [alerView show];
                return;
            }
            
            NSString *vt = dicData[@"data"][@"v_t"];
            long long vipInter = 0;
            if (vt) {
                vipInter = [vt longLongValue];
            }
            [CommonConfig setVIPInterval:vipInter];
            
            /*
            NSString *vipFinishDa = [CommonConfig getVIPFinishDate];
            NSString *msg = [NSString stringWithFormat:@"购买成功： 会员到期时间 %@",vipFinishDa];
            
            UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                message:msg
                                                               delegate:nil cancelButtonTitle:NSLocalizedString(@"Close（关闭）",nil) otherButtonTitles:nil];
            [alerView show];
             */
            
            if ([CommonConfig isVIP]) {
                [self removeFromSuperview];
                _iapBlock(YES);
                return;
            }
        }else{
            UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                message:@"网络发生错误\n如果已经扣了费用。请重启App"
                                                               delegate:nil cancelButtonTitle:NSLocalizedString(@"Close（关闭）",nil) otherButtonTitles:nil];
            [alerView show];
        }
    }];
}

#pragma mark - 微信接口回调
-(void)onReq:(BaseReq*)req{
    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
        GetMessageFromWXReq *temp = (GetMessageFromWXReq *)req;
        
        // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App提供内容"];
        NSString *strMsg = [NSString stringWithFormat:@"openID: %@", temp.openID];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 1000;
        [alert show];
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
        WXMediaMessage *msg = temp.message;
        
        //显示微信传过来的内容
        WXAppExtendObject *obj = msg.mediaObject;
        
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App显示内容"];
        NSString *strMsg = [NSString stringWithFormat:@"openID: %@, 标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%td bytes\n附加消息:%@\n", temp.openID, msg.title, msg.description, obj.extInfo, msg.thumbData.length, msg.messageExt];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if([req isKindOfClass:[LaunchFromWXReq class]])
    {
        LaunchFromWXReq *temp = (LaunchFromWXReq *)req;
        WXMediaMessage *msg = temp.message;
        
        //从微信启动App
        NSString *strTitle = [NSString stringWithFormat:@"从微信启动"];
        NSString *strMsg = [NSString stringWithFormat:@"openID: %@, messageExt:%@", temp.openID, msg.messageExt];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark 微信登

static NSString *kAuthScope = @"snsapi_userinfo";
static NSString *kAuthOpenID = @"这个我现在没使用";
static NSString *kAuthState = @"123";
//微信登陆
- (void)wxLoginWithCompleteBlock:(void(^)(bool isSuccess))completeBlock
{
    _loginBlock = [completeBlock copy];
    
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    req.scope = kAuthScope;
    req.state = kAuthState;
    req.openID = kAuthOpenID;
    
    UIViewController *rootVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    BOOL succeed = [WXApi sendAuthReq:req viewController:rootVC delegate:self];
    if (succeed) {
        
    }
}

-(void) onResp:(BaseResp*)resp{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        NSString *strTitle = [NSString stringWithFormat:@"提醒"];
        NSString *strMsg = @"";
        if (0 == resp.errCode) {
            strMsg = @"分享成功";
        }else{
            strMsg = @"分享失败";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if([resp isKindOfClass:[SendAuthResp class]])
    {
        SendAuthResp *temp = (SendAuthResp*)resp;
        [self loginSuccessByCode:temp.code];
    }
    else if ([resp isKindOfClass:[AddCardToWXCardPackageResp class]])
    {
        AddCardToWXCardPackageResp* temp = (AddCardToWXCardPackageResp*)resp;
        NSMutableString* cardStr = [[NSMutableString alloc] init];
        for (WXCardItem* cardItem in temp.cardAry) {
            [cardStr appendString:[NSString stringWithFormat:@"cardid:%@ cardext:%@ cardstate:%d\n",cardItem.cardId,cardItem.extMsg,(unsigned int)cardItem.cardState]];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"add card resp" message:cardStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
}

#pragma mark 微信登录回调。
-(void)loginSuccessByCode:(NSString *)code{
    if (!code) {
        return;
    }
    
    NSLog(@"code %@",code);
    [WebRequestManager requestWebChatLogin:code completeBlock:^(NSDictionary *dicData) {
        if (dicData) {
            NSString *icon = dicData[@"data"][@"wx"][@"headimgurl"];
            NSString *openid = dicData[@"data"][@"wx"][@"openid"];
            NSString *nickName = dicData[@"data"][@"wx"][@"nickname"];
            
            NSString *vt = dicData[@"v_t"];
            long long vipInter = 0;
            if (vt) {
                vipInter = [vt longLongValue];
            }
            [CommonConfig setVIPInterval:vipInter];
            [CommonConfig shareInstance].loginState = LoginStateSuccess;
            [CommonConfig setNickName:nickName];
            [CommonConfig setHeadImageURL:icon];
            [CommonConfig setUID:openid];
            
            _loginBlock(YES);
        }else{
            _loginBlock(NO);
        }
    }];
}
@end

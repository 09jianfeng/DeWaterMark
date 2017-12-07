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
    payView.backgroundColor = [UIColor grayColor];
    payView.tag = 10001;
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
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
    [buyBtn setTitle:@"立即开通" forState:UIControlStateNormal];
    [buyBtn addTarget:self action:@selector(buttonBuyPresed:) forControlEvents:UIControlEventTouchUpInside];
    [payView addSubview:buyBtn];
    [buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(payView.mas_left).offset(50);
        make.right.equalTo(payView.mas_right).offset(-50);
        make.bottom.equalTo(payView.mas_bottom);
        make.height.mas_equalTo(50);
    }];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:payView.bounds collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor grayColor];
    _collectionView.showsVerticalScrollIndicator = NO;
    
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"paycollecviewcell"];
    [payView addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLable.mas_bottom);
        make.bottom.equalTo(buyBtn.mas_top);
        make.left.equalTo(payView.mas_left);
        make.right.equalTo(payView.mas_right);
    }];
    
    self.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5];
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
    UILabel *label = [[UILabel alloc] initWithFrame:cell.bounds];
    label.numberOfLines = 3;
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = 10003;
    label.textColor = [UIColor blackColor];
    if (self.vipDic) {
        NSDictionary *priceText = self.payData.price[indexPath.row];
        label.text = priceText[@"appDesc"];
    }
    
    [cell addSubview:label];
    [cell addSubview:label];
    return cell;
    
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = CGRectGetWidth(self.frame)-60;
    return CGSizeMake((width -6)/3, (width - 6)/3);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(collectionView.frame.size.width, 20);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(collectionView.frame.size.width,30);
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
    return 0;
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
    cell.backgroundColor = [UIColor blueColor];
    cell.selected = YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"deselect item is :%td",indexPath.row);
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)buttonClosePrssed:(id)sender{
    [self removeFromSuperview];
}

- (void)buttonBuyPresed:(id)sender{
    NSLog(@"buy");
}

@end

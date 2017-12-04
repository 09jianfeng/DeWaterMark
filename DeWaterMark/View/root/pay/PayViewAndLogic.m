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

@implementation PayViewAndLogic

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
    }
    
    return self;
}

#pragma mark -
- (void)getVIP{
    [WebRequestHandler requestDataWithUseTime:0 completeBlock:^(NSDictionary *dicData) {
        NSLog(@"__ DicData:%@",dicData);
    }];
    
    CGFloat width = self.frame.size.width;
    CGFloat heigh = self.frame.size.height;
    
    UIView *payView = [[UIView alloc] initWithFrame:CGRectMake(10, heigh/2.0 - width/3, width - 20, width*2/3)];
    payView.backgroundColor = [UIColor grayColor];
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
    
    self.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5];
    [self addSubview:payView];
}

- (void)buttonClosePrssed:(id)sender{
    [self removeFromSuperview];
}

- (void)buttonBuyPresed:(id)sender{
    NSLog(@"buy");
}


@end

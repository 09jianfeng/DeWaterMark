//
//  PayViewAndLogic.h
//  DeWaterMark
//
//  Created by JFChen on 2017/12/4.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

@interface PayViewAndLogic : UIView<WXApiDelegate>

//全屏大小
+ (instancetype)shareInstance;

//先设置frame后再调用getVIP
- (void)getVIP;

@end

//
//  ChoosingRectView.h
//  DeWaterMark
//
//  Created by JFChen on 2017/11/5.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChoosingRectView<NSObject>
- (void)choosingRect:(CGRect)rect;
@end

@interface ChoosingRectView : UIView
@property(nonatomic, weak) id<ChoosingRectView> delegate;
@end

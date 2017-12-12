//
//  EditSliderView.h
//  DeWaterMark
//
//  Created by JFChen on 2017/11/4.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditSliderViewDelegate<NSObject>
- (void)valuehangeing:(float)duration x1Posi:(float)x1Posi x2Posi:(float)x2Posi;
- (void)drafCallback:(BOOL)backward endPosi:(float)endPosi;

- (void)positionValueChangeing:(CGFloat)position;
@end

@interface EditSliderView : UIView
@property(nonatomic, assign) float duration;
@property(nonatomic, weak)   id<EditSliderViewDelegate> delegate;
@property(nonatomic, assign)  float progress;
@property(nonatomic, assign)  CGFloat selectedLineX;
@property(nonatomic, assign)  CGFloat selectedLineLastX;
@end

//
//  DialogView+UsingAnimation.h
//  BasicClassLibrary
//
//  Created by DoubleZ on 13-11-14.
//  Copyright (c) 2013年 陈建峰. All rights reserved.
//

//  一切全屏显示View的基类
// 这个类主要都是用
#import <UIKit/UIKit.h>

typedef enum {
    DialogViewAnimationTransitionNone = 0,  // no animation
    DialogViewAnimationTransitionZoomIn,
    DialogViewAnimationTransitionZoomOut,
    DialogViewAnimationTransitionFade,
    DialogViewAnimationTransitionPushFromBottom,
    DialogViewAnimationTransitionPushFromTop,
    DialogViewAnimationTransitionCount
} DialogViewAnimationTransition;     //动画效果

@interface DialogView : UIView {
 @protected
    UIViewController            *_platformViewController;
    
    UIInterfaceOrientation              _orientation;
    BOOL                                _isShowing;
    
}   
@property(nonatomic, assign) id delegate;
@property(nonatomic, assign, readonly, getter = isShowing) BOOL                    isShowing;
@property(nonatomic, assign, readonly) UIInterfaceOrientation  orientation;

///视图显示window
@property (nonatomic, retain) UIWindow *window;
///用于扩展类目的动画使用,保存显示的时候的视图动画
@property (nonatomic, assign) DialogViewAnimationTransition transition;

- (void)show;
- (void)showInView:(UIView*)view;
- (void)hide;
@end

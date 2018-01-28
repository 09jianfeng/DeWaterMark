//
//  DialogView+UsingAnimation.h
//  BasicClassLibrary
//
//  Created by DoubleZ on 13-11-14.
//  Copyright (c) 2013年 陈建峰. All rights reserved.
//

#import "DialogView.h"

CGAffineTransform RotateTransformForOrientation(UIInterfaceOrientation orientation) {
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(M_PI*1.5);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI/2);
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return CGAffineTransformMakeRotation(-M_PI);
    } else {
        return CGAffineTransformIdentity;
    }
}

@implementation DialogView
@synthesize delegate    = _delegate;
@synthesize isShowing   = _isShowing;
@synthesize orientation = _orientation;
#pragma mark -
#pragma mark Protected Methods
- (BOOL)_shouldRotateToOrientation:(UIInterfaceOrientation)orientation {
    if (orientation == _orientation) {
        return NO;
    } else {
        return orientation == UIInterfaceOrientationLandscapeLeft
        || orientation == UIInterfaceOrientationLandscapeRight
        || orientation == UIInterfaceOrientationPortrait
        || orientation == UIInterfaceOrientationPortraitUpsideDown;
    }
}

//适应方向，转换界面
- (void)_sizeToFitOrientation:(BOOL)transform {
    if (!_platformViewController) return; // 不是全屏显示的不处理
    if (transform) {
        self.transform = CGAffineTransformIdentity;
    }
    CGRect frame = [UIScreen mainScreen].bounds;
    _platformViewController.view.frame = frame;
    self.center = CGPointMake(frame.size.width/2, frame.size.height/2);
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    _orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(_orientation)) {
        self.bounds = CGRectMake(0.0f, 0.0f, height, width);
    } else {
        self.bounds = CGRectMake(0.0f, 0.0f, width, height);
    }
    if (transform) {
        self.transform = RotateTransformForOrientation(_orientation);
    }
}

//接收到设备方向发生变化的通知
- (void)_deviceOrientationDidChange:(NSNotification *)note {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if ( [self _shouldRotateToOrientation:orientation]) {
        _orientation = orientation;
        CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:duration];
        [self _sizeToFitOrientation:YES];
        [self setNeedsLayout];
        [UIView commitAnimations];
    }
}

#pragma mark -
#pragma mark 公开的方法

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}
#pragma mark -
- (BOOL)isShowing {
    if (!self.window) return _isShowing;
    if (self.window.hidden) return NO;
    if (self.window.alpha == 0.0f) return NO;
    return _isShowing;
}

- (void)_dismissViewController {
    // _platformViewController此时不能销毁, 它的view后面将会返回给上层代码
    if (_platformViewController) {
        [_platformViewController.view setHidden:YES];
        [_platformViewController.view removeFromSuperview];
    }
    self.window = nil;
}

#pragma mark -
#pragma mark - Show and Hide Without Animated
- (void)show {
    // 修复连续2次显示阻塞主屏幕的bug
    if (self.isShowing) {
        return;
    }
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.windowLevel = UIWindowLevelStatusBar - 1;
    self.window.userInteractionEnabled = YES;
    self.window.hidden = NO;
    self.window.alpha = 1;
    self.window.backgroundColor = [UIColor clearColor];
    if (self.superview) [self removeFromSuperview];
    _platformViewController = [UIViewController new];
    _platformViewController.view.backgroundColor = [UIColor clearColor];
    //window->platformVC->self(TargetView)
    [self.window addSubview:_platformViewController.view];
    [self showInView:_platformViewController.view];
}

- (void)showInView:(UIView*)view {
    [self removeFromSuperview];
    self.transform = CGAffineTransformIdentity;
    self.alpha = 1.0;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
    if (_platformViewController) {
        // 如果是全屏显示 则调整大小
        [self _sizeToFitOrientation:YES];
    }
    if (!_isShowing) {
        _isShowing = YES;
        [view addSubview:self];  //传进来的view是在keywindow上的controller的view
    }
}

- (void)hide {
    if (_isShowing) {
        _isShowing = NO;
        [self removeFromSuperview];
        [self _dismissViewController];
    }
}
@end

//
//  ChoosingRectView.m
//  DeWaterMark
//
//  Created by JFChen on 2017/11/5.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import "ChoosingRectView.h"

@implementation ChoosingRectView{
    UIView *_choosingView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addMySubviews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addMySubviews];
    }
    return self;
}

- (void)addMySubviews{
}

- (void)layoutSubviews{
    if (!_choosingView) {
        _choosingView = [[UIView alloc] initWithFrame:self.bounds];
        _choosingView.backgroundColor = [UIColor blackColor];
        _choosingView.alpha = 0.5;
        [self addSubview:_choosingView];

        _choosingView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds)/2.0, CGRectGetHeight(self.bounds)/2.0);
        _choosingView.center = CGPointMake( CGRectGetWidth(self.bounds)/2.0, CGRectGetHeight(self.bounds)/2.0);
    }
    [super layoutSubviews];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSEnumerator *enumerator = [touches objectEnumerator];
    UITouch *toucher = enumerator.nextObject;
    CGPoint location = [toucher locationInView:self];
    
    CGFloat choViewWidth = CGRectGetWidth(_choosingView.bounds);
    CGFloat choViewHeigh = CGRectGetHeight(_choosingView.bounds);
    CGFloat chosViewLeftTopX = _choosingView.frame.origin.x;
    CGFloat chosViewLeftTopY = _choosingView.frame.origin.y;
    CGFloat chosViewRighTopX = _choosingView.frame.origin.x + CGRectGetWidth(_choosingView.bounds);
    CGFloat chosViewRighTopY = _choosingView.frame.origin.y;
    CGFloat chosViewLeftBottomX = _choosingView.frame.origin.x;
    CGFloat chosViewLeftBottomY = _choosingView.frame.origin.y + CGRectGetHeight(_choosingView.bounds);
    CGFloat chosViewRighBottomX = _choosingView.frame.origin.x + CGRectGetWidth(_choosingView.bounds);
    CGFloat chosViewRighBottomY = _choosingView.frame.origin.y + CGRectGetHeight(_choosingView.bounds);
    
    if (fabs(chosViewLeftTopX - location.x) < 30 && fabs(chosViewLeftTopY - location.y) < 30 ) {
        _choosingView.frame = CGRectMake(location.x, location.y, choViewWidth + chosViewLeftTopX - location.x, choViewHeigh + chosViewLeftTopY - location.y);
        
    }else if (fabs(chosViewRighTopX - location.x) < 30 && fabs(chosViewRighTopY - location.y) < 30){
        _choosingView.frame = CGRectMake(chosViewLeftTopX, location.y, location.x - chosViewLeftTopX, choViewHeigh + chosViewLeftTopY - location.y);
        
    }else if (fabs(chosViewLeftBottomX - location.x) < 30 && fabs(chosViewLeftBottomY - location.y) < 30){
        _choosingView.frame = CGRectMake(location.x, chosViewLeftTopY, choViewWidth + chosViewLeftTopX - location.x, location.y - chosViewLeftTopY);
        
    }else if (fabs(chosViewRighBottomX - location.x) < 30 && fabs(chosViewRighBottomY - location.y) < 30){
        _choosingView.frame = CGRectMake(chosViewLeftTopX, chosViewLeftTopY, location.x -chosViewLeftTopX, location.y - chosViewLeftTopY);
    }
    
    [self setNeedsDisplay];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
    if ([self pointInside:point withEvent:event]) {
        return self;
    }
    
    return [super hitTest:point withEvent:event];
}

@end

//
//  ChoosingRectView.m
//  DeWaterMark
//
//  Created by JFChen on 2017/11/5.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import "ChoosingRectView.h"
#import "Masonry.h"

@implementation ChoosingRectView{
    UIView *_choosingView;
    CGPoint _beginPoint;
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
        _choosingView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self addSubview:_choosingView];

        _choosingView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds)/2.0, CGRectGetHeight(self.bounds)/2.0);
        _choosingView.center = CGPointMake( CGRectGetWidth(self.bounds)/2.0, CGRectGetHeight(self.bounds)/2.0);
        
        float heigh = 5;
        float width = 20;
        UIView *borderViewT1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, heigh)];
        borderViewT1.backgroundColor = [UIColor whiteColor];
        UIView *borderViewT2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, heigh)];
        borderViewT2.backgroundColor = [UIColor whiteColor];
        UIView *borderViewB1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, heigh)];
        borderViewB1.backgroundColor = [UIColor whiteColor];
        UIView *borderViewB2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, heigh)];
        borderViewB2.backgroundColor = [UIColor whiteColor];
        
        [_choosingView addSubview:borderViewT1];
        [_choosingView addSubview:borderViewT2];
        [_choosingView addSubview:borderViewB1];
        [_choosingView addSubview:borderViewB2];
        [borderViewT1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_choosingView.mas_left);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(heigh);
            make.bottom.equalTo(_choosingView.mas_top);
        }];
        [borderViewT2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_choosingView.mas_right);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(heigh);
            make.bottom.equalTo(_choosingView.mas_top);
        }];
        [borderViewB1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_choosingView.mas_left);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(heigh);
            make.top.equalTo(_choosingView.mas_bottom);
        }];
        [borderViewB2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_choosingView.mas_right);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(heigh);
            make.top.equalTo(_choosingView.mas_bottom);
        }];

        
        float sideHeigh = 25;
        float sideWidth = 5;
        UIView *borderViewR1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sideWidth, sideHeigh)];
        borderViewR1.backgroundColor = [UIColor whiteColor];
        UIView *borderViewR2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sideWidth, sideHeigh)];
        borderViewR2.backgroundColor = [UIColor whiteColor];
        UIView *borderViewL1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sideWidth, sideHeigh)];
        borderViewL1.backgroundColor = [UIColor whiteColor];
        UIView *borderViewL2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sideWidth, sideHeigh)];
        borderViewL2.backgroundColor = [UIColor whiteColor];
        [_choosingView addSubview:borderViewR1];
        [_choosingView addSubview:borderViewR2];
        [_choosingView addSubview:borderViewL1];
        [_choosingView addSubview:borderViewL2];
        [borderViewR1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(sideWidth);
            make.height.mas_equalTo(sideHeigh);
            make.right.equalTo(_choosingView.mas_left);
            make.top.equalTo(_choosingView.mas_top).offset(-heigh);
        }];
        
        [borderViewR2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(sideWidth);
            make.height.mas_equalTo(sideHeigh);
            make.right.equalTo(_choosingView.mas_left);
            make.bottom.equalTo(_choosingView.mas_bottom).offset(heigh);
        }];

        [borderViewL1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(sideWidth);
            make.height.mas_equalTo(sideHeigh);
            make.left.equalTo(_choosingView.mas_right);
            make.top.equalTo(_choosingView.mas_top).offset(-heigh);
        }];

        [borderViewL2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(sideWidth);
            make.height.mas_equalTo(sideHeigh);
            make.left.equalTo(_choosingView.mas_right);
            make.bottom.equalTo(_choosingView.mas_bottom).offset(heigh);
        }];

    }
    [super layoutSubviews];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSEnumerator *enumerator = [touches objectEnumerator];
    UITouch *toucher = enumerator.nextObject;
    CGPoint location = [toucher locationInView:self];
    _beginPoint = location;

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
    
    if (fabs(chosViewLeftTopX - location.x) < 20 && fabs(chosViewLeftTopY - location.y) < 20 ) {
        _choosingView.frame = CGRectMake(location.x, location.y, choViewWidth + chosViewLeftTopX - location.x, choViewHeigh + chosViewLeftTopY - location.y);
        
    }else if (fabs(chosViewRighTopX - location.x) < 20 && fabs(chosViewRighTopY - location.y) < 20){
        _choosingView.frame = CGRectMake(chosViewLeftTopX, location.y, location.x - chosViewLeftTopX, choViewHeigh + chosViewLeftTopY - location.y);
        
    }else if (fabs(chosViewLeftBottomX - location.x) < 20 && fabs(chosViewLeftBottomY - location.y) < 20){
        _choosingView.frame = CGRectMake(location.x, chosViewLeftTopY, choViewWidth + chosViewLeftTopX - location.x, location.y - chosViewLeftTopY);
        
    }else if (fabs(chosViewRighBottomX - location.x) < 20 && fabs(chosViewRighBottomY - location.y) < 20){
        _choosingView.frame = CGRectMake(chosViewLeftTopX, chosViewLeftTopY, location.x -chosViewLeftTopX, location.y - chosViewLeftTopY);
    }else{
        CGPoint _choosingPoint = [_choosingView convertPoint:location fromView:self];
        if ([_choosingView pointInside:_choosingPoint withEvent:event]){
            _choosingView.frame = CGRectMake(location.x-_beginPoint.x+chosViewLeftTopX, location.y-_beginPoint.y+chosViewLeftTopY, choViewWidth, choViewHeigh);
            _beginPoint = location;
        }
    }
    
    [self setNeedsDisplay];
    [_delegate choosingRect:_choosingView.frame];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
    if ([self pointInside:point withEvent:event]) {
        return self;
    }
    
    return [super hitTest:point withEvent:event];
}

@end

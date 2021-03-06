//
//  ActivityIndicator.m
//  storyBoardBook
//
//  Created by 陈建峰 on 14-8-27.
//  Copyright (c) 2014年 陈建峰. All rights reserved.
//

#import "ActivityIndicator.h"
@interface ActivityIndicator()
@property(nonatomic ,strong) UIActivityIndicatorView *activityIndicator;
@end

@implementation ActivityIndicator
+(ActivityIndicator *)shareInstance{
    static ActivityIndicator *acti = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        acti = [ActivityIndicator new];
    });
    return acti;
}

-(id)init{
    self = [super init];
    if (self) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] init];
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.activityIndicator.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
        [self addSubview:self.activityIndicator];
    }
    return self;
}

-(void)showActivityIndicator{
    [self show];
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    [self.activityIndicator startAnimating];
}

-(void)closeActivityIndicator{
    [self.activityIndicator stopAnimating];
    [self hide];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

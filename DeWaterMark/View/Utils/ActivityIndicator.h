//
//  ActivityIndicator.h
//  storyBoardBook
//
//  Created by 陈建峰 on 14-8-27.
//  Copyright (c) 2014年 陈建峰. All rights reserved.
//

#import "DialogView.h"

@interface ActivityIndicator : DialogView
+(ActivityIndicator *)shareInstance;

-(void)showActivityIndicator;
-(void)closeActivityIndicator;
@end

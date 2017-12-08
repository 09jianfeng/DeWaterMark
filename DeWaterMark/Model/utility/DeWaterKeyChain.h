//
//  DeWaterKeyChain.h
//  DeWaterMark
//
//  Created by JFChen on 2017/12/8.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeWaterKeyChain : NSObject

+ (void)setValue:(NSString *)value forKey:(NSString *)key;
+ (NSString *)getValueForKey:(NSString *)key;

@end

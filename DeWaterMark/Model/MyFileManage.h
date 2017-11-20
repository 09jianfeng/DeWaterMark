//
//  MyFileManage.h
//  DeWaterMark
//
//  Created by JFChen on 2017/11/4.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>



@interface MyFileManage : NSObject

+(NSString *)rootDirDoc;
+(NSString *)getDir:(NSString *)dirName rootDir:(NSString *)rootDir;

+(void)getVideoPathFromPHAsset:(PHAsset *)asset fileName:(NSString *)fileName fileDir:(NSString *)fileDir rootDir:(NSString *)rootDir complete:(void (^)(NSString *, NSString *))result failure:(void (^)(NSString *))failure cancell:(void (^)(void))cancell;
@end

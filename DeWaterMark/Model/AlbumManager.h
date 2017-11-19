//
//  AlbumManager.h
//  DeWaterMark
//
//  Created by JFChen on 2017/11/19.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumManager : NSObject

- (NSDictionary *)getVideosFromAlbum;
- (NSDictionary *)getPhotosFromAlbum;

- (void)writeVideoToAlbum:(NSData *)videoData;
- (void)writePhotoToAlbum:(NSData *)photoData;
@end

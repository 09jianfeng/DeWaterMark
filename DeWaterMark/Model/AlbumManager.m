//
//  AlbumManager.m
//  DeWaterMark
//
//  Created by JFChen on 2017/11/19.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import "AlbumManager.h"
#import <Photos/Photos.h>

@implementation AlbumManager


- (NSDictionary *)getVideosFromAlbum{
    // 列出所有相册智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    // 列出所有用户创建的相册
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    // 获取所有资源的集合，并按资源的创建时间排序
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];

    return nil;
}

- (NSDictionary *)getPhotosFromAlbum{
    return nil;
}

- (void)writeVideoToAlbum:(NSData *)videoData{
    
}

- (void)writePhotoToAlbum:(NSData *)photoData{
    
}

@end

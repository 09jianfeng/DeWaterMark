//
//  MyFileManage.m
//  DeWaterMark
//
//  Created by JFChen on 2017/11/4.
//  Copyright © 2017年 JFChen. All rights reserved.
//


#import "MyFileManage.h"
#import <Photos/Photos.h>

NSString *RootFileCache = @"rootfilecache";
NSString *DefautlDir = @"defaultdir";


@implementation MyFileManage

+(NSString *)rootDirDoc{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *rootDir = [documentsDirectory stringByAppendingPathComponent:RootFileCache];
    [[NSFileManager defaultManager] createDirectoryAtPath:rootDir withIntermediateDirectories:YES attributes:nil error:nil];
    return rootDir;
}

//获取Library目录
+(NSString *)rootDirLib{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *rootDir = [libraryDirectory stringByAppendingPathComponent:RootFileCache];
    [[NSFileManager defaultManager] createDirectoryAtPath:rootDir withIntermediateDirectories:YES attributes:nil error:nil];
    return rootDir;
}

//获取Cache目录
+(NSString *)rootDirCache{
    NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cacPath objectAtIndex:0];
    NSString *rootDir = [cachePath stringByAppendingPathComponent:RootFileCache];
    [[NSFileManager defaultManager] createDirectoryAtPath:rootDir withIntermediateDirectories:YES attributes:nil error:nil];
    return rootDir;
}

//获取Tmp目录
+(NSString *)rootDirTmp{
    NSString *tmpDirectory = NSTemporaryDirectory();
    NSString *rootDir = [tmpDirectory stringByAppendingPathComponent:RootFileCache];
    [[NSFileManager defaultManager] createDirectoryAtPath:rootDir withIntermediateDirectories:YES attributes:nil error:nil];
    return rootDir;
}

+(NSString *)getDir:(NSString *)dirName rootDir:(NSString *)rootDir{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = false;
    NSString *dirPath = [rootDir stringByAppendingPathComponent:dirName];
    BOOL isDirExist = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    if(!(isDirExist && isDir))
    {
        BOOL createDir = [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!createDir){
            //dirPath = nil;
        }
    }
    
    return dirPath;
}

+(NSString *)createPathWithFileName:(NSString *)fileName direName:(NSString *)dirName rootDir:(NSString *)rootDir{
    NSString *targetDir = [self getDir:dirName rootDir:rootDir];
    return [targetDir stringByAppendingPathComponent:fileName];
}

+(NSString *)createPathWithFileName:(NSString *)fileName rootDir:(NSString *)rootDir{
    return [self createPathWithFileName:fileName direName:DefautlDir rootDir:rootDir];
}

+(NSString *)createPathWithFileName:(NSString *)fileName{
    return [self createPathWithFileName:fileName direName:DefautlDir rootDir:[self rootDirCache]];
}

+(void)enumeratorFiles:(NSString *)path block:(void(^)(NSString *path))block{
    // 1.判断文件还是目录
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        // 2. 判断是不是目录
        if (isDir) {
            NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:path error:nil];
            NSString * subPath = nil;
            for (NSString * str in dirArray) {
                subPath= [path stringByAppendingPathComponent:str];
                BOOL issubDir = NO;
                [fileManger fileExistsAtPath:subPath isDirectory:&issubDir];
                [self enumeratorFiles:subPath block:block];
            }
        }else{
            if (block) {
                block(path);
            }
        }
    }
}

+(NSMutableArray *)filePathsWithDirPath:(NSString *)dirPath{
    NSMutableArray *filePaths = [NSMutableArray new];
    if (dirPath) {
        [self enumeratorFiles:dirPath block:^(NSString *path) {
            [filePaths addObject:path];
        }];
    }
    return filePaths;
    
}

+(NSMutableArray *)filePathsWithDirName:(NSString *)dirName rootDir:(NSString *)rootDir{
    NSMutableArray *filePaths = [NSMutableArray new];
    NSString *dirPath = [self getDir:dirName rootDir:rootDir];
    if (dirPath) {
        [self enumeratorFiles:dirPath block:^(NSString *path) {
            [filePaths addObject:path];
        }];
    }
    return filePaths;
    
}

+(NSString *)saveFile:(NSData *)tempData WithName:(NSString *)fileName
{
    NSString* fullPathToFile = [self createPathWithFileName:fileName];
    [self writeData:tempData toPath:fullPathToFile];
    return fullPathToFile;
    
}

+(void)saveFile:(NSData *)data savePath:(NSString *)filePath{
    [self writeData:data toPath:filePath];
}

+(NSString *)saveFile:(NSData *)tempData name:(NSString *)fileName rootDir:(NSString *)rootDir
{
    NSString* fullPathToFile = [self createPathWithFileName:fileName rootDir:rootDir];
    [self writeData:tempData toPath:fullPathToFile];
    return fullPathToFile;
}

+(NSData *)dataForPath:(NSString *)path{
    @synchronized (self) {
        return [NSData dataWithContentsOfFile:path options:0 error:NULL];
    }
}

+(void)writeData:(NSData*)data toPath:(NSString *)path {
    @synchronized (self) {
        [data writeToFile:path atomically:YES];
    }
}

+(void)deleteDataAtPath:(NSString *)path {
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

//+(void)deleteWithFileName:(NSString *)fileName{

//

//NSString* documentsDirectory = [self FileCacheDirectory];

//

//NSFileManager *defaultManager;

//

//defaultManager = [NSFileManager defaultManager];

//NSArray *contents = [defaultManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];

//NSEnumerator *e = [contents objectEnumerator];

//

//NSString *filename;

//NSArray *tempArray= [fileName componentsSeparatedByString:@"/"];

//NSString * distinationFileName;

//if ([tempArray count]>=2) {

//distinationFileName=[tempArray objectAtIndex:[tempArray count]-1];

//}else{

//distinationFileName=fileName;

//}

//

//while ((filename = [e nextObject])) {

//

//if ([filename isEqualToString:distinationFileName]) {

//

//[defaultManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];

//break;

//}

//

//}

//

//}

+(void)deleteWithFileName:(NSString *)fileName rootDir:(NSString *)rootDir{
    NSFileManager *defaultManager;
    defaultManager = [NSFileManager defaultManager];
    NSArray *contents = [defaultManager contentsOfDirectoryAtPath:rootDir error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    NSArray *tempArray= [fileName componentsSeparatedByString:@"/"];
    NSString * distinationFileName;
    if ([tempArray count]>=2) {
        distinationFileName=[tempArray objectAtIndex:[tempArray count]-1];
    }else{
        distinationFileName=fileName;
    }
    
    while ((filename = [e nextObject])) {
        if ([filename isEqualToString:distinationFileName]) {
            [defaultManager removeItemAtPath:[rootDir stringByAppendingPathComponent:filename] error:NULL];
            break;
        }
    }
}

+(void)deleteWithFilePath:(NSString *)filePath{
    if (filePath) {
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        [defaultManager removeItemAtPath:filePath error:NULL];
    }
}

+(void)clearCacheWithDirPath:(NSString*)dirPath{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    BOOL isDir = false;
    BOOL isDirExist = [defaultManager fileExistsAtPath:dirPath isDirectory:&isDir];
    if(!(isDirExist && isDir))
    {
        return;
    }
    NSArray *contents = [defaultManager contentsOfDirectoryAtPath:dirPath error:NULL];
    for (NSString *path in contents) {
        [defaultManager removeItemAtPath:[dirPath stringByAppendingPathComponent:path] error:NULL];
    }
}

+(void)clearCache{
    NSString* documentsDirectory = [self rootDirCache];
    NSFileManager *defaultManager;
    defaultManager = [NSFileManager defaultManager];
    NSArray *contents = [defaultManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    for (NSString *path in contents) {
        [defaultManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:path] error:NULL];
    }
}

+(BOOL)isFileExit:(NSString*)filePath{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    BOOL isDir = false;
    BOOL isDirExist = [defaultManager fileExistsAtPath:filePath isDirectory:&isDir];
    return isDirExist;
}

+(NSDate *) getFileCreateTime:(NSString*) path
{
    NSDate *date;
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        if ([attributes objectForKey:NSFileCreationDate])
        {
            date = [attributes objectForKey:NSFileCreationDate];
        }
    }
    return date;
}

+(NSInteger) getFileSize:(NSString*) path
{
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return[theFileSize intValue];
        else
            return -1;
    }
    else
    {
        return -1;
    }
}

#pragma mark - video
+ (float) getVideoDuration:(NSURL*) URL
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:URL options:opts];
    float second = 0;
    second = urlAsset.duration.value/urlAsset.duration.timescale;
    return second;
}

/*
 *mov to mp4 ;presstName:AVAssetExportPresetLowQuality,AVAssetExportPresetMediumQuality,AVAssetExportPresetHighestQuality
 *
 */
+(void)asyncConvertMovToMp4VideoWithVideoURL:(NSURL *)videoURL presetName:(NSString *)presetName failure:(void (^)(NSString *))failure success:(void (^)(NSString *))success cancell:(void (^)(void))cancell{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyyMMddHHmmss"];
    NSString *fileName = [[formater stringFromDate:[NSDate date]] stringByAppendingString:@".mp4"];
    [self asyncConvertMovToMp4VideoWithVideoURL:videoURL fileName:fileName fileDir:DefautlDir rootDir:[self rootDirCache] presetName:presetName failure:failure success:success cancell:cancell];
}

+(void)asyncConvertMovToMp4VideoWithVideoURL:(NSURL *)videoURL fileName:(NSString *)fileName fileDir:(NSString *)fileDir rootDir:(NSString *)rootDir presetName:(NSString *)presetName failure:(void (^)(NSString *))failure success:(void (^)(NSString *))success cancell:(void (^)(void))cancell{
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    if ([compatiblePresets containsObject:presetName]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:presetName];
        NSString *path = [self createPathWithFileName:fileName direName:fileDir rootDir:rootDir];
        exportSession.outputURL = [NSURL fileURLWithPath:path];
        exportSession.shouldOptimizeForNetworkUse = NO;
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                {
                    if (failure) {
                        NSError *e = [exportSession error];
                        NSLog(@"%@",e);
                        failure([[exportSession error] localizedDescription]);
                    }
                    break;
                }
                case AVAssetExportSessionStatusCancelled:
                {
                    if (cancell) {
                        cancell();
                    }
                    break;
                }
                    
                case AVAssetExportSessionStatusCompleted:
                {
                    if (success) {
                        success(path);
                    }
                    
                    break;
                }
                    
                default:
                    break;
            }
        }];
    }else{
        if (failure) {
            failure([NSString stringWithFormat:@"not exit %@ resource",presetName]);
        }
    }
}

//+(void)cafToMP3:(NSString *)mp3FilePath cafFilePath:(NSString *)cafFilePath sampleRate:(int)sampleRate{
//
//    @try {
//
//        int read, write;
//
//        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");//source 被转换的音频文件位置
//
//        fseek(pcm, 4*1024, SEEK_CUR);//skip file header
//
//        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");//output 输出生成的Mp3文件位置
//
//        const int PCM_SIZE = 8192;
//
//        const int MP3_SIZE = 8192;
//
//        short int pcm_buffer[PCM_SIZE*2];
//
//        unsigned char mp3_buffer[MP3_SIZE];
//
//        lame_t lame = lame_init();
//
//        lame_set_in_samplerate(lame, sampleRate);
//
//        lame_set_VBR(lame, vbr_default);
//
//        lame_init_params(lame);
//
//        do {
//
//            read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
//
//            if (read == 0)
//
//                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
//
//            else
//
//                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
//
//            fwrite(mp3_buffer, write, 1, mp3);
//
//        } while (read != 0);
//
//        lame_close(lame);
//
//        fclose(mp3);
//
//        fclose(pcm);
//
//    }
//
//    @catch (NSException *exception) {
//
//        NSLog(@"%@",[exception description]);
//
//    }
//
//    @finally {
//
//        [self deleteDataAtPath:cafFilePath];
//
//    }
//
//}

+(void)getImagePathFromPHAsset:(PHAsset *)asset fileName:(NSString *)fileName fileDir:(NSString *)fileDir rootDir:(NSString *)rootDir complete:(void (^)(NSString *, NSString *))result{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    //options.version = PHImageRequestOptionsVersionOriginal;
    
    //options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    //
    
    CGSize size = CGSizeMake(asset.pixelWidth,asset.pixelHeight);
    __block NSString *savePath =[self createPathWithFileName:fileName direName:fileDir rootDir:rootDir];
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        NSData *data = UIImageJPEGRepresentation(result, 0.5f);
//        [FileUtils saveFile:data savePath:savePath];
    }];
    
    if (result) {
        result(savePath,fileName);
    }
}

+(void)getVideoPathFromPHAsset:(PHAsset *)asset fileName:(NSString *)fileName fileDir:(NSString *)fileDir rootDir:(NSString *)rootDir complete:(void (^)(NSString *, NSString *))result failure:(void (^)(NSString *))failure cancell:(void (^)(void))cancell{
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestExportSessionForVideo:asset options:options exportPreset:AVAssetExportPresetMediumQuality resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
        NSString *savePath = [self createPathWithFileName:fileName direName:fileDir rootDir:rootDir];
//        [FileUtils deleteDataAtPath:savePath];
        exportSession.outputURL = [NSURL fileURLWithPath:savePath];
        exportSession.shouldOptimizeForNetworkUse = NO;
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                {
                    if (failure) {
                        NSError *e = [exportSession error];
                        NSLog(@"%@",e);
                        failure([[exportSession error] localizedDescription]);
                        if (e.code == -11823) {
                            result(savePath,[savePath lastPathComponent]);
                        }
                    }
                    break;
                }
                    
                case AVAssetExportSessionStatusCancelled:
                {
                    if (cancell) {
                        cancell();
                    }
                    break;
                }
                    
                case AVAssetExportSessionStatusCompleted:
                {
                    if (result) {
                        result(savePath,[savePath lastPathComponent]);
                    }
                    break;
                }
                default:
                    break;
            }
        }];
    }];
}

#pragma mark - 额外的接口
+(NSString *)getOriginVideoDirPath{
    //originvideo
    NSString *documentPath =[MyFileManage rootDirDoc];
    NSString *originString = [MyFileManage getDir:@"originvideo" rootDir:documentPath];
    return originString;
}

+(NSString *)getFFMPEGTransformDirPath{
    NSString *documentPath =[MyFileManage rootDirDoc];
    NSString *productString = [MyFileManage getDir:@"transform" rootDir:documentPath];
    return productString;
}

+(NSString *)getMyProductionsDirPath{
    NSString *documentPath =[MyFileManage rootDirDoc];
    NSString *productString = [MyFileManage getDir:@"products" rootDir:documentPath];
    return productString;
}

+(NSArray *)getMyProductionsVideoPaths{
    NSString *producDirPath = [MyFileManage getMyProductionsDirPath];
    return [MyFileManage filePathsWithDirPath:producDirPath];
}


@end

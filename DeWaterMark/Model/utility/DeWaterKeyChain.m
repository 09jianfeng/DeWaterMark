//
//  DeWaterKeyChain.m
//  DeWaterMark
//
//  Created by JFChen on 2017/12/8.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import "DeWaterKeyChain.h"
#import <Security/Security.h>

static NSString * const kPDKeyChainKey = @"com.watermark.keychainKey";

@implementation DeWaterKeyChain

+ (void)removeall{
    [DeWaterKeyChain keyChainDelete];
}

+ (void)setValue:(NSString *)value forKey:(NSString *)key{
    NSMutableDictionary *tempDic = [[DeWaterKeyChain keyChainLoad] mutableCopy];
    if (!tempDic) {
        tempDic = [NSMutableDictionary new];
    }
    [tempDic setObject:value forKey:key];
    [DeWaterKeyChain keyChainSave:tempDic];
}

+ (NSString *)getValueForKey:(NSString *)key{
    NSDictionary *tempDic = [DeWaterKeyChain keyChainLoad];
    return [tempDic objectForKey:key];
}

+ (void)keyChainSave:(NSMutableDictionary *)mutDic{
    [self save:kPDKeyChainKey data:mutDic];
}

+ (NSDictionary *)keyChainLoad{
    NSMutableDictionary *tempDic = (NSMutableDictionary *)[self load:kPDKeyChainKey];
    return tempDic;
}

+ (void)keyChainDelete{
    [self delete:kPDKeyChainKey];
}

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}

+ (void)save:(NSString *)service data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}

+ (void)delete:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}@end

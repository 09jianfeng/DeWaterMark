//
//  CommonConfig.m
//  DeWaterMark
//
//  Created by JFChen on 2017/11/30.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import "CommonConfig.h"
#import <memory.h>
#import <AdSupport/AdSupport.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "sys/utsname.h"
#import <sys/socket.h>
#import <sys/utsname.h>
#import <sys/sysctl.h>
#import <UIKit/UIKit.h>
#import "DeWaterKeyChain.h"


static NSString *NEIBUVERCODE = @"1";
static NSString *MEMBERID = @"memberID";
static NSString *RESTTIME = @"RESTTIME";
static NSString *GETISVIP = @"GETISVIP";

@implementation CommonConfig

+ (NSString *)getIMEIorIDFA{
    return [self getIDFA];
}

+ (NSString *)getMemberId{
    NSString *userMember = [DeWaterKeyChain getValueForKey:MEMBERID];
    if (!userMember) {
        return @"";
    }
    return userMember;
}

+ (void)setMemberId:(NSString *)memberid{
    [DeWaterKeyChain setValue:memberid forKey:MEMBERID];
}

+ (void)decreaseOneChance{
    NSString *restTime = [DeWaterKeyChain getValueForKey:RESTTIME];
    if (!restTime) {
        [DeWaterKeyChain setValue:@"2" forKey:RESTTIME];
        return;
    }
    
    int rest = [restTime intValue];
    rest--;
    [DeWaterKeyChain setValue:[NSString stringWithFormat:@"%d",rest] forKey:RESTTIME];
}

+ (int)restChance{
    NSString *restTime = [DeWaterKeyChain getValueForKey:RESTTIME];
    if (!restTime) {
        [DeWaterKeyChain setValue:@"3" forKey:RESTTIME];
    }
    
    return [restTime intValue];
}

+ (void)setVIP:(BOOL)isvip{
    [DeWaterKeyChain setValue:@"1" forKey:GETISVIP];
}

+ (BOOL)isVIP{
    BOOL isVIP = [DeWaterKeyChain getValueForKey:GETISVIP];
    return isVIP;
}

+ (NSString *)versionName{
    return [self appVersion];
}

+ (NSString *)versionCode{
    return NEIBUVERCODE;
}

+ (NSString *)sv{
    return [self systemVersion];
}

+ (NSString *)phoneModel{
    return [self modelName];
}

+ (NSString *)mobileType{
    return @"iphone";
}

+ (NSString *)modelName
{
    static NSString *modelName = nil;
    if (!modelName) {
        struct utsname systemInfo;
        uname(&systemInfo);
        modelName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    }
    return modelName;
}

+ (NSString *)getIDFA{
    NSString *idfa = [DeWaterKeyChain getValueForKey:@"IDFA"];
    if (!idfa) {
        idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        [DeWaterKeyChain setValue:idfa forKey:@"IDFA"];
    }
    return idfa;
}

+ (NSString *)getIDFV{
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return idfv;
}

+ (NSString *)bundleID{
    NSString *bundleid = [[NSBundle mainBundle] bundleIdentifier];
    return bundleid;
}

+ (NSString *)appVersion{
    NSString *ver = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return ver;
}

+ (NSString *)getNetWorkInfo{
    //获取本机运营商名称
    
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
    
    if (!carrier.isoCountryCode) {
        return @"";
    }
    
    NSString* mobileCountryCode = [carrier mobileCountryCode];
    NSString* mobileNetworkCode = [carrier mobileNetworkCode];
    NSString *mobile = [NSString stringWithFormat:@"%@:%@",mobileCountryCode,mobileNetworkCode];
    
    return mobile;
}

+ (NSString *)systemVersion{
    NSString *sysVer = [[UIDevice currentDevice] systemVersion];
    return sysVer;
}

static NSUInteger GetSysInfo(uint typeSpecifier) {
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, HW_CPU_FREQ};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}

+ (NSUInteger)cpuFrequency{
    return GetSysInfo(HW_CPU_FREQ);
}

@end

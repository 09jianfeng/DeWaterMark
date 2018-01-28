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
static NSString *VIPDAYS = @"VIPDAYS";
static NSString *SETVIPDAYINTER = @"SETVIPDAYINTER";
static NSString *SWITCHPRICE = @"SWITCHPRICE";

@implementation CommonConfig{
}

+ (instancetype)shareInstance{
    static CommonConfig *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [CommonConfig new];
    });
    return instance;
}

+ (void)setUID:(NSString *)uid{
    if(!uid || [uid isEqualToString:@""]){
        return;
    }
    
    [DeWaterKeyChain setValue:uid forKey:@"UID"];
}
+ (NSString *)getUID{
    NSString *uid = [DeWaterKeyChain getValueForKey:@"UID"];
    return uid;
}

+ (void)setHeadImageURL:(NSString *)headImageURL{
    if(!headImageURL || [headImageURL isEqualToString:@""]){
        return;
    }
    [DeWaterKeyChain setValue:headImageURL forKey:@"headImageURL"];
}
+ (NSString *)getHeadImageURL{
    NSString *headImageURL = [DeWaterKeyChain getValueForKey:@"headImageURL"];
    return headImageURL;
}

+ (void)setNickName:(NSString *)nickName{
    if(!nickName || [nickName isEqualToString:@""]){
        return;
    }
    [DeWaterKeyChain setValue:nickName forKey:@"nickName"];

}
+ (NSString *)getNickName{
    NSString *nickName = [DeWaterKeyChain getValueForKey:@"nickName"];
    return nickName;
}

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

+ (void)setSwitchPrice:(NSString *)switchPrice{
    [DeWaterKeyChain setValue:switchPrice forKey:SWITCHPRICE];
}

+ (NSString *)getSwitchPrice{
    NSString *userMember = [DeWaterKeyChain getValueForKey:SWITCHPRICE];
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
        restTime = @"3";
    }
    
    return [restTime intValue];
}

+ (void)setVIP:(BOOL)isvip{
    [DeWaterKeyChain setValue:@"1" forKey:GETISVIP];
}

+ (void)setVIPInterval:(long long)vipinterval{
    [DeWaterKeyChain setValue:[NSString stringWithFormat:@"%lld",vipinterval] forKey:SETVIPDAYINTER];
    [CommonConfig setVIP:1];
}

+ (NSString *)getVIPFinishDate{
    long long vipInterval = [[DeWaterKeyChain getValueForKey:SETVIPDAYINTER] longLongValue];
    if (vipInterval < 100) {
        return nil;
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:vipInterval];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    NSString *stringDate = [format stringFromDate:date];
    return stringDate;
}

+ (BOOL)isVIP{
    BOOL isVIP = [[DeWaterKeyChain getValueForKey:GETISVIP] boolValue];
    if (!isVIP) {
        return NO;
    }
    
    long long now = [NSDate date].timeIntervalSince1970;
    long long vipInterval = [[DeWaterKeyChain getValueForKey:SETVIPDAYINTER] longLongValue];
    
    if (now > vipInterval) {
        return NO;
    }
    
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
    NSString *uid = [CommonConfig getUID];
    if(uid){
        return uid;
    }
    
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

//
//  URLManager.m
//  DeWaterMark
//
//  Created by JFChen on 2017/11/30.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import "URLManager.h"
#import "CommonConfig.h"
#import "MyFileManage.h"

@implementation URLManager

+ (NSString *)getCommondString{
    NSString *imei = [CommonConfig getIMEIorIDFA];
    NSString *memberId = [CommonConfig getMemberId];
    NSString *verName = [CommonConfig versionName];
    NSString *verCode = [CommonConfig versionCode];
    NSString *sv = [CommonConfig sv];
    NSString *m = [CommonConfig phoneModel];
    NSString *b = [CommonConfig mobileType];
    NSString *path = [NSString stringWithFormat:@"imei=%@&memberId=%@&verName=%@&vercode=%@&sv=%@&m=%@&b=%@",imei,memberId,verName,verCode,sv,m,b];
    return path;
}

/*
 {
 "price_switch":true,
 "price":[
 {
     "id":24,
     "name":"1个月VIP",
     "amount":1700,
     "appDesc":"1个月VIP\r\n17元"
 },
 {
     "id":25,
     "name":"3个月VIP",
     "amount":4100,
     "appDesc":"3个月VIP\r\n41元"
 },
 {
     "id":26,
     "name":"12个月VIP",
     "amount":12300,
     "appDesc":"一年VIP\r\n123元"
 } ],
 "v_t":0,
 "f_t":2,
 "memberId":"5a1cc7029cbeb62e2c4084e2"
 }
 */
+ (NSString *)getInitURL:(NSString *)u_t{
    NSString *path = [NSString stringWithFormat:@"http://www.shulantech.com/ios/remove/init?u_t=%@&od=%@&%@",u_t,[CommonConfig getUID],[self getCommondString]];
    return path;
}

///*
// {
// "order_no":"20171128111344",
//     "order_info":{
//         "package":"Sign=WXPay",
//         "appid":"wx821e82e041420de8",
//         "sign":"7210917492F7EE77F02C8FD43E091BF3",
//         "partnerid":"1491261952",
//         "prepayid":"wx2017112811135879e7da795f0471851898",
//         "noncestr":"3l3mP0ThPuym0yLLp7vmt7j2qhgjNT",
//         "timestamp":"1511838835"
//     }
// }
// */
//+ (NSString *)getWeXPaURL:(NSString *)priceId{
//    NSString *path = [NSString stringWithFormat:@"http://www.shulantech.com/remove_ios/wechat_pay?priceId=%@&%@",priceId,[self getCommondString]];
//    return path;
//}
//
//
///*
// {
//     "order_no":"20171128113100",
//     "order_info":"app_id=2017102409498762×tamp=2017‐11‐
//     28+11%3A31%3A00¬ify_url=http%3A%2F%2Fu22.oboard.net%3A8888%2Fapi%2Fpush%2F20171128113100&biz_con
//     tent=%7B%22timeout_express%22%3A%2230m%22%2C%22product_code%22%3A%22QUICK_MSECURITY_PAY%22%2C%22
//     total_amount%22%3A%2217.00%22%2C%22subject%22%3A%22%E8%B4%AD%E4%B9%B0%E5%8E%BB%E6%B0%B4%E5%8D%B0
//     1%E4%B8%AA%E6%9C%88%E4%BC%9A%E5%91%98%22%2C%22body%22%3A%22%E5%8E%BB%E6%B0%B4%E5%8D%B01%E4%B8%AA
//     %E6%9C%88%E4%BC%9A%E5%91%98%22%2C%22out_trade_no%22%3A%2220171128113100%22%7D&charset=utf‐
//     8&method=alipay.trade.app.pay&sign_type=RSA2&version=1.0&sign=bRR5k5o%2F65R%2FcL6ef7sUIGumT04%2B
//     ix8rXHz3ni6bOIr4Yac8KHtB%2FDn0z1QK%2F4IBmv2llVJFLv31%0AEuwrCVGDdP46XEtM%2FtFBYOAGwkCelv8FDX24RNY
//     w%2BChFmDX4bpu16X8%2BXftvbDQn8Dgxpq6IwpCZ%0AeNCZE1cpb%2FTCMWC2dsw%2BdMm4PwrMpbqV3OEAn%2BTGLRvrVp
//     ailT8OTKfeddrom%2BKNOKVQ3rOhRO6T%0Aze7VuyouqUd8%2F7r7qmxDPXzSUom3TrcyQr%2FewcIjcz%2BCqHX4tqJX%2F
//     6S%2B29DJDJNy3jl%2BXHvWyGle%0A2aULYNcY%2BW40AwrrBArVgDVFtrecqLe8ZAnr%2Fg%3D%3D%0A"
// }
// */
//+ (NSString *)getAliPURL:(NSString *)priceId{
//    NSString *path = [NSString stringWithFormat:@"http://www.shulantech.com/remove_ios/ali_pay?priceId=%@&%@",priceId,[self getCommondString]];
//    return path;
//}


/*
 {
     "v_t":1539180203236,
     "m_id":"59dcd259da4fb171ba0690ea"
 }
 */

+ (NSString *)getCheckIAPURL:(NSString *)IAPData{
    NSString * encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)IAPData,NULL,(CFStringRef)@"!*'();@&+$,/?%#[]~=_-.:",kCFStringEncodingUTF8 ));
    NSString *path = [NSString stringWithFormat:@"http://www.shulantech.com/ios/remove/check_iap?data=%@&openId=%@",encodedString,[CommonConfig getUID]];
    return path;
}

+ (NSString *)getWxLoginURL:(NSString *)code{
    NSString *path = [NSString stringWithFormat:@"http://www.shulantech.com/ios/remove/wx_login?code=%@",code];
    return path;
}

@end

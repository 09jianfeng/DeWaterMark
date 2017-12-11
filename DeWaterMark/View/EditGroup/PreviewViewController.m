//
//  PreviewViewController.m
//  DeWaterMark
//
//  Created by JFChen on 2017/12/8.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import "PreviewViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Masonry.h"
#import "MyFileManage.h"
#import "PayViewAndLogic.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PreviewViewController ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *preBaseView;

@end

@implementation PreviewViewController{
    MPMoviePlayerViewController *_mpMoview;
    NSURL *_assetURL;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setImage:[UIImage imageNamed:@"btn_share"]    forState:UIControlStateNormal];
    [btn1 setFrame:CGRectMake(0, 0, 30, 30)];
    [btn1 addTarget:self action:@selector(btnSharePressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right1 = [[UIBarButtonItem alloc] initWithCustomView:btn1];
    [right1 setTarget:self];
    [right1 setAction:@selector(btnSharePressed:)];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setImage:[UIImage imageNamed:@"btn_delete"] forState:UIControlStateNormal];
    [btn2 setFrame:CGRectMake(0, 0, 30, 30)];
    [btn2 addTarget:self action:@selector(btnDeletePressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right2 = [[UIBarButtonItem alloc] initWithCustomView:btn2];
    [right2 setTarget:self];
    [right2 setAction:@selector(btnDeletePressed:)];
    self.navigationItem.rightBarButtonItems = @[right2,right1];
    
    _mpMoview = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:_videoPath]];
    _mpMoview.moviePlayer.shouldAutoplay = NO;
    
    [self addChildViewController:_mpMoview];
    _mpMoview.view.frame = self.preBaseView.bounds;
    [self.preBaseView addSubview:_mpMoview.view];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [[NSNotificationCenter defaultCenter] removeObserver:_mpMoview
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:_mpMoview
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:nil];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    _mpMoview.view.frame = self.preBaseView.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - barBtn

/*
 微信
 
 - (void)SSDKSetupWeChatParamsByText:(NSString *)text
 title:(NSString *)title
 url:(NSURL *)url
 thumbImage:(id)thumbImage
 image:(id)image
 musicFileURL:(NSURL *)musicFileURL
 extInfo:(NSString *)extInfo
 fileData:(id)fileData
 emoticonData:(id)emoticonData
 type:(SSDKContentType)type
 forPlatformSubType:(SSDKPlatformType)platformSubType;

 QQ
 
 - (void)SSDKSetupQQParamsByText:(NSString *)text
 title:(NSString *)title
 url:(NSURL *)url
 audioFlashURL:(NSURL *)audioFlashURL
 videoFlashURL:(NSURL *)videoFlashURL
 thumbImage:(id)thumbImage
 images:(id)images
 type:(SSDKContentType)type
 forPlatformSubType:(SSDKPlatformType)platformSubType;
 */

- (void)btnSharePressed:(id)sender{
    if (!_assetURL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先保存到相册才能分享" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //1、创建分享参数
    NSArray* imageArray = @[[UIImage imageNamed:@"Icon-513"]];
//    （注意：图片必须要在Xcode左边目录里面，名称必须要传正确，如果要分享网络图片，可以这样传iamge参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]）
    if (imageArray) {
        
//        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
//        NSURL *videoURL = [NSURL fileURLWithPath:_videoPath];
//        [shareParams SSDKSetupWeChatParamsByText:@"分享视频" title:@"视频" url:_assetURL thumbImage:[UIImage imageNamed:@"Icon-513"] image:[UIImage imageNamed:@"Icon-513"] musicFileURL:nil extInfo:@".mp4" fileData:_assetURL emoticonData:nil                 sourceFileExtension:@"mp4" sourceFileData:_assetURL type:SSDKContentTypeFile forPlatformSubType:SSDKPlatformSubTypeWechatSession];
//
//        [shareParams SSDKSetupWeChatParamsByText:@"分享视频" title:@"视频" url:_assetURL thumbImage:[UIImage imageNamed:@"Icon-513"] image:[UIImage imageNamed:@"Icon-513"] musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeVideo forPlatformSubType:SSDKPlatformSubTypeWechatTimeline];
//
////        [shareParams SSDKSetupQQParamsByText:@"分享视频" title:@"视频" url:_assetURL audioFlashURL:nil videoFlashURL:_assetURL thumbImage:[UIImage imageNamed:@"Icon-513"] image:[UIImage imageNamed:@"Icon-513"] type:SSDKContentTypeVideo forPlatformSubType:SSDKPlatformSubTypeQQFriend];
//        [shareParams SSDKSetupQQParamsByText:@"去水印" title:@"水印" url:_assetURL audioFlashURL:nil videoFlashURL:_assetURL thumbImage:[UIImage imageNamed:@"Icon-513"] images:[UIImage imageNamed:@"Icon-513"] type:SSDKContentTypeVideo forPlatformSubType:SSDKPlatformSubTypeQQFriend];
        
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:@"视频去水印"
                                         images:imageArray
                                            url:[NSURL URLWithString:@"http://www.baidu.com"]
                                          title:@"视频去水印软件"
                                           type:SSDKContentTypeAuto];
        //2、分享（可以弹出我们的分享菜单和编辑界面）
        [ShareSDK showShareActionSheet:nil //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
                                 items:nil
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       
                       switch (state) {
                           case SSDKResponseStateSuccess:
                           {
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                                   message:nil
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"确定"
                                                                         otherButtonTitles:nil];
                               [alertView show];
                               break;
                           }
                           case SSDKResponseStateFail:
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:[NSString stringWithFormat:@"%@",error]
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           default:
                               break;
                }
        }];
    }
}

- (void)btnDeletePressed:(id)sender{
    NSLog(@"___ delete");
    UIAlertView *alerVi = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定文件吗" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alerVi show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        
        [MyFileManage deleteWithFilePath:_videoPath];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)saveToAlbum:(id)sender {
    [self saveVideo:_videoPath];
}

//videoPath为视频下载到本地之后的本地路径
- (void)saveVideo:(NSString *)videoPath{
    __block ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    [lib writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:_videoPath] completionBlock:^(NSURL *assetURL, NSError *error) {
        if (!error) {
            _assetURL = assetURL;
            
            NSLog(@"____ assetURL:%@",_assetURL);
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
            });
        }
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

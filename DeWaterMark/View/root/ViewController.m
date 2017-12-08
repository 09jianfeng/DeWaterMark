//
//  ViewController.m
//  DeWaterMark
//
//  Created by JFChen on 2017/11/4.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import "ViewController.h"
#import "AlbumManager.h"
#import "YZYPhotoPicker.h"
#import "EditViewController.h"
#import "MBProgressHUD.h"
#import "MyFileManage.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "PayViewAndLogic.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTopLay;

@property (weak, nonatomic) IBOutlet UIView *introlView;
@end

@implementation ViewController{
    NSString *_videoPath;
    MBProgressHUD *HUD;
    UIView *_baseView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _introlView.layer.shadowColor = [UIColor blackColor].CGColor;
    _introlView.layer.shadowOffset = CGSizeMake(10, 10);
    _introlView.layer.shadowOpacity = 0.5;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.backgroundColor = [UIColor redColor];
    
    [self addSubViews];
    
    MMDrawerBarButtonItem *button = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(buttonPressed:)];
    [button setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = button;
//    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_goback"] style:UIBarButtonItemStyleDone target:self action:@selector(buttonPressedDown:)];
//    [left setTintColor:[UIColor whiteColor]];
//    self.navigationItem.leftBarButtonItem = left;
    [[PayViewAndLogic shareInstance] requestWebData];

}

- (void)buttonPressed:(id)sender{
    if (self.mm_drawerController.openSide != MMDrawerSideRight) {
        [self.mm_drawerController openDrawerSide:MMDrawerSideRight animated:YES completion:^(BOOL finished) {
        }];
        
    }else{
        [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        }];
    }
}


- (void)addSubViews{
    
    _baseView = [UIView new];
    _baseView.frame = self.view.bounds;
    _baseView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _baseView.hidden = YES;
    [self.view addSubview:_baseView];
    
    HUD = [[MBProgressHUD alloc] init];
    [_baseView addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;//进度条
    HUD.square = YES;
    //14,设置显示和隐藏动画类型  有三种动画效果，如下
    HUD.animationType = MBProgressHUDAnimationZoomIn; //和上一个相反，前近，最后淡化消失
    HUD.removeFromSuperViewOnHide = NO;
    HUD.label.textColor = [UIColor blueColor];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    _topViewTopLay.constant = (CGRectGetHeight(self.view.frame) - 418)/2.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)myVideos:(id)sender {
}


- (IBAction)beginEditVideo:(id)sender {
    YZYPhotoPicker *photoPicker = [[YZYPhotoPicker alloc] init];
    
    photoPicker.isImgType = NO;
    [photoPicker showPhotoPickerWithController:self maxSelectCount:1 completion:^(NSArray *imageSources, BOOL isImgType) {
        
        //        [_view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        NSInteger i = 0;
        if (isImgType) { // 如果是UIImage
            for (UIImage *img in imageSources) {
                UIImageView *imgView = [[UIImageView alloc] initWithFrame: CGRectMake(i % 3 * 105, i / 3 * 105, 100, 100)];
                imgView.image = img;
                i ++;
            }
        } else {  // 是照片资源 iOS8 以下为AlAsset  iOS8以上为PHAsset
            //            for (id asset in imageSources) {
            //                [[YZYPhotoDataManager shareInstance] fetchImageFromAsset: asset type: ePhotoResolutionTypeScreenSize targetSize: [UIScreen mainScreen].bounds.size result:^(UIImage *img) {
            //                    UIImageView *imgView = [[UIImageView alloc] initWithFrame: CGRectMake(i % 3 * 105, i / 3 * 105, 100, 100)];
            //
            //                    imgView.image = img;
            //                }];
            //                i ++;
            //            }
            
            _baseView.hidden = NO;
            [HUD showAnimated:YES];
            HUD.label.text = @"正在从相册导入";
            
            for (id asset in imageSources) {
                [[YZYPhotoDataManager shareInstance] fetchVideoPathFromAsset:asset result:^(NSString *path) {
                    
                    NSLog(@"____ videoPath:%@",path);
                    _videoPath = path;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _baseView.hidden = YES;
                        [HUD hideAnimated:YES];
                        
                        UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        EditViewController *editCon = [main instantiateViewControllerWithIdentifier:@"EditViewController"];
                        editCon.videoPath = _videoPath;
                        [self.navigationController pushViewController:editCon animated:YES];
                    });
                } progressblock:^(float progress) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HUD.label.text = [NSString stringWithFormat:@"正在从相册导入 %%%d",(int)(progress*100)];
                    });
                }];
            }
        }
    }];
}

- (IBAction)buttonMorePressed:(id)sender {
    NSLog(@"清理视频");
    NSString *originPath = [MyFileManage getOriginVideoDirPath];
    [MyFileManage deleteWithFilePath:originPath];
}


@end

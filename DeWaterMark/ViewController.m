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

@interface ViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTopLay;

@property (weak, nonatomic) IBOutlet UIView *introlView;
@end

@implementation ViewController{
    NSString *_videoPath;
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
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    _topViewTopLay.constant = CGRectGetWidth(self.view.frame)/4.0;
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
            
            for (id asset in imageSources) {
                [[YZYPhotoDataManager shareInstance] fetchVideoPathFromAsset:asset result:^(NSString *path) {
                    NSLog(@"____ videoPath:%@",path);
                    _videoPath = path;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        EditViewController *editCon = [main instantiateViewControllerWithIdentifier:@"EditViewController"];
                        editCon.videoPath = _videoPath;
                        [self.navigationController pushViewController:editCon animated:YES];
                    });
                }];
            }
        }
    }];
}

- (IBAction)buttonMorePressed:(id)sender {
    NSLog(@"");
}


@end

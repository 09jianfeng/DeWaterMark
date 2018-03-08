//
//  MyVideosController.m
//  DeWaterMark
//
//  Created by JFChen on 2017/11/25.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import "MyVideosController.h"
#import "MyFileManage.h"
#import "Masonry.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SelectedViewController.h"

@interface MyVideosController ()
@property(nonatomic, strong) NSArray *myVideosPath;
@end

@implementation MyVideosController

static NSString * const reuseIdentifier = @"MyVideosControllerCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 10;
    float width = CGRectGetWidth(self.view.frame);
    layout.itemSize = CGSizeMake((width-43.0)/3.0, (width-22.0)/3.0);
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
    [self.collectionView setCollectionViewLayout:layout];
}

- (void)viewWillAppear:(BOOL)animated{
    _myVideosPath = [MyFileManage getMyProductionsVideoPaths];
    [self.collectionView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _myVideosPath.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView = [UIImageView new];
    [cell addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.topMargin.mas_equalTo(cell.mas_topMargin);
        make.bottomMargin.mas_equalTo(cell.mas_bottomMargin);
        make.leftMargin.mas_equalTo(cell.mas_leftMargin);
        make.rightMargin.mas_equalTo(cell.mas_rightMargin);
    }];
    
    NSString *videoPath = [_myVideosPath objectAtIndex:indexPath.row];
    UIImage *videoImage = [self getImage:videoPath];
    imageView.image = videoImage;
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *videoPath = [_myVideosPath objectAtIndex:indexPath.row];
    SelectedViewController *selecVieCon = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectedViewController"];
    selecVieCon.videoPath = videoPath;
    [self.navigationController pushViewController:selecVieCon animated:YES];
}

#pragma mark - 工具
- (UIImage *)getImage:(NSString *)videoURL
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumb;
}

@end

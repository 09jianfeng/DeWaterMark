//
//  RightDrawerTableViewController.m
//  Dafaguoji888
//
//  Created by JFChen on 2017/6/20.
//  Copyright © 2017年 JFChen. All rights reserved.
//

#import "RightDrawerTableViewController.h"
#import "MyTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import "QRCodeGenerateVC.h"
#import "SGQRCodeScanningVC.h"
#import "MMDrawerController.h"
#import "AboutViewController.h"
#import "WebRequestHandler.h"
#import "Masonry.h"
#import "PayViewAndLogic.h"
#import "MyFileManage.h"

@interface RightDrawerTableViewController ()

@end

@implementation RightDrawerTableViewController{
    UIView *_baseView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sz_bj"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
    [self.tableView registerClass:[MyTableViewCell class] forCellReuseIdentifier:@"MyTableViewCell"];
    
    [self.tableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyTableViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    switch (indexPath.row) {
        case 0:
        {
            cell.imageView.image = [UIImage imageNamed:@"db_12a"];
            cell.textLabel.text = @"关于";
            cell.textLabel.textColor = [UIColor blackColor];
        }
            break;
        case 1:
        {
            cell.imageView.image = [UIImage imageNamed:@"db_14a"];
            cell.textLabel.text = @"清空所有缓存";
            cell.textLabel.textColor = [UIColor blackColor];
        }
            break;
        case 2:
        {
            cell.imageView.image = [UIImage imageNamed:@"db_14a"];
//            cell.textLabel.text = @"购买会员";
            cell.textLabel.textColor = [UIColor blackColor];
        }
            break;
            
        default:
            break;
    }
    // Configure the cell...
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            AboutViewController *aboutCon = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AboutViewController"];
            MMDrawerController *mmdrawer = (MMDrawerController*)[UIApplication sharedApplication].keyWindow.rootViewController;
            [mmdrawer closeDrawerAnimated:YES completion:nil];
            [(UINavigationController *)mmdrawer.centerViewController pushViewController:aboutCon animated:YES];
        }
            break;
        case 1:
        {
//            [self scanningQRCode];
            [MyFileManage deleteAllCacheFile];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"成功清除所有缓存" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
            break;
        case 2:
        {
//            [self getVIP];
        }
            break;
            
        default:
            break;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
    {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - 
/** 扫描二维码方法 */
- (void)scanningQRCode {
    // 1、 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SGQRCodeScanningVC *vc = [[SGQRCodeScanningVC alloc] init];
                        [self.navigationController pushViewController:vc animated:YES];
                    });
                    
                    NSLog(@"当前线程 - - %@", [NSThread currentThread]);
                    // 用户第一次同意了访问相机权限
                    NSLog(@"用户第一次同意了访问相机权限");
                    
                } else {
                    
                    // 用户第一次拒绝了访问相机权限
                    NSLog(@"用户第一次拒绝了访问相机权限");
                }
            }];
        } else if (status == AVAuthorizationStatusAuthorized) { // 用户允许当前应用访问相机
            SGQRCodeScanningVC *vc = [[SGQRCodeScanningVC alloc] init];
            MMDrawerController *mmdrawer = (MMDrawerController*)[UIApplication sharedApplication].keyWindow.rootViewController;
            [mmdrawer closeDrawerAnimated:YES completion:nil];
            [(UINavigationController *)mmdrawer.centerViewController pushViewController:vc animated:YES];
        } else if (status == AVAuthorizationStatusDenied) { // 用户拒绝当前应用访问相机
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请去-> [设置 - 隐私 - 相机 - SGQRCodeExample] 打开访问开关" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertC addAction:alertA];
            [self presentViewController:alertC animated:YES completion:nil];
            
        } else if (status == AVAuthorizationStatusRestricted) {
            NSLog(@"因为系统原因, 无法访问相册");
        }
    } else {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未检测到您的摄像头" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertC addAction:alertA];
        [self presentViewController:alertC animated:YES completion:nil];
    }
    
}

- (void)getVIP{
    PayViewAndLogic *payView = [PayViewAndLogic shareInstance];
    payView.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [payView getVIP];
    
    [self.view addSubview:payView];
    
    [UIView animateWithDuration:0.2 animations:^{
        payView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

@end

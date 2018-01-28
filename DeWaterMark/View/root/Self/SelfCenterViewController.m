//
//  SelfCenterViewController.m
//  DeWaterMark
//
//  Created by JFChen on 2018/1/28.
//  Copyright © 2018年 JFChen. All rights reserved.
//

#import "SelfCenterViewController.h"

@interface SelfCenterViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelLoginDetail;
@property (weak, nonatomic) IBOutlet UIButton *btnWeixinLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnBuyVIP;
@property (weak, nonatomic) IBOutlet UILabel *labelVIPDetail;

@end

@implementation SelfCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
- (IBAction)btnWeixinLogin:(id)sender {

}

- (IBAction)btnBuyVIP:(id)sender {

}

@end

//
//  OneViewController.m
//  HFNavigationController
//
//  Created by xhf on 16/5/11.
//  Copyright © 2016年 xuhongfei. All rights reserved.
//

#import "OneViewController.h"

#import "OnePushViewController.h"

@interface OneViewController ()


@end

@implementation OneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"首页";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)push {
    
    OnePushViewController *onePushVC = [[OnePushViewController alloc] initWithNibName:@"OnePushViewController" bundle:nil];
    
    [self.navigationController pushViewController:onePushVC animated:YES];
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

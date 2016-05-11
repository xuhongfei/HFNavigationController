//
//  TabBarController.m
//  HFNavigationController
//
//  Created by xhf on 16/5/11.
//  Copyright © 2016年 xuhongfei. All rights reserved.
//

#import "TabBarController.h"

#import "HFNavigationController.h"
#import "OneViewController.h"
#import "TwoViewController.h"

@implementation TabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    OneViewController *oneVC = [[OneViewController alloc]  initWithNibName:@"OneViewController" bundle:nil];
    HFNavigationController *navC1 = [[HFNavigationController alloc] initWithRootViewController:oneVC];
    navC1.title = @"首页";
    navC1.tabBarItem.image = [UIImage imageNamed:@"bookmark_unselect"];
    navC1.tabBarItem.selectedImage = [UIImage imageNamed:@"bookmark_select"];
    [self addChildViewController:navC1];
    
    TwoViewController *twoVC = [[TwoViewController alloc] initWithNibName:@"TwoViewController" bundle:nil];
    HFNavigationController *navC2 = [[HFNavigationController alloc] initWithRootViewController:twoVC];
    navC2.title = @"设置";
    navC2.tabBarItem.image = [UIImage imageNamed:@"user_unselect"];
    navC2.tabBarItem.selectedImage = [UIImage imageNamed:@"user_select"];
    [self addChildViewController:navC2];
}

@end

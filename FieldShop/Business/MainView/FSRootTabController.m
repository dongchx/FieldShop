//
//  FSRootTabController.m
//  FieldShop
//
//  Created by dongchx on 18/01/2018.
//  Copyright © 2018 dongchx. All rights reserved.
//

#import "FSRootTabController.h"
#import "FSPrepareTVC.h"
#import "FSShopVC.h"

@interface FSRootTabController ()

@end

@implementation FSRootTabController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupSubviews:self.view];
}

#pragma mark - subviews

- (void)setupSubviews:(UIView *)parentView
{
    parentView.backgroundColor = [UIColor whiteColor];
    
    FSPrepareTVC *firstVC  = [[FSPrepareTVC alloc] init];
//    firstVC.tabBarItem.title = @"prepare";
//    firstVC.tabBarItem.image = nil;
    
    FSShopVC    *secondVC = [[FSShopVC alloc] init];
//    secondVC.tabBarItem.title = @"shop";
    
    UINavigationController *firstNC =
    [[UINavigationController alloc] initWithRootViewController:firstVC];
    UINavigationController *secondNC =
    [[UINavigationController alloc] initWithRootViewController:secondVC];
    
    firstNC.tabBarItem.title = @"prepare";
    secondNC.tabBarItem.title = @"shop";
    
    self.viewControllers = @[firstNC, secondNC];
}

#pragma mark - UITabBarControllerDelegate

//- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
//{
//    if ([item.title isEqualToString:@"prepare"]) {
//        self.navigationItem.title = @"Prepare";
//    }
//    else if ([item.title isEqualToString:@"shop"]) {
//        self.navigationItem.title = @"Shop";
//    }
//}



@end

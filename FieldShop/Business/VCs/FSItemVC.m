//
//  FSItemVC.m
//  FieldShop
//
//  Created by dongchx on 23/01/2018.
//  Copyright © 2018 dongchx. All rights reserved.
//

#import "FSItemVC.h"
#import <Masonry.h>

@interface FSItemVC ()

@end

@implementation FSItemVC

- (void)viewDidLoad
{
    FSDebug;
    [super viewDidLoad];
    
    self.title = @"FSItemVC";
    
    [self setupSubviews:self.view];
}

#pragma mark - subviews

- (void)setupSubviews:(UIView *)parentView
{
    FSDebug;
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [parentView addSubview:scrollView];
    
    //
    //
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(parentView);
    }];
}

@end

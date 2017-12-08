//
//  FSMigrationViewController.m
//  FieldShop
//
//  Created by dongchx on 08/12/2017.
//  Copyright © 2017 dongchx. All rights reserved.
//

#import "FSMigrationViewController.h"

@interface FSMigrationViewController ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIProgressView *progress;

@end

@implementation FSMigrationViewController

- (void)viewDidLoad
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    [super viewDidLoad];
    [self setupSubviews:self.view];
}

#pragma mark - subviews

- (void)setupSubviews:(UIView *)parentView
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    parentView.backgroundColor = [UIColor whiteColor];
    
    CGFloat height = 25.;
    CGFloat width  = [UIScreen mainScreen].bounds.size.width - 32;
    CGFloat viewX = 16.;
    CGFloat viewY = 160.;
    
    UILabel *label =
    [[UILabel alloc] initWithFrame:CGRectMake(viewX, viewY, width, height)];
    [parentView addSubview:label];
    
    viewY += height + 6.;
    UIProgressView *progress =
    [[UIProgressView alloc] initWithFrame:CGRectMake(viewX, viewY, width, height)];
    [parentView addSubview:progress];
    
    label.text = @"Migration Progress 0%";
    
    _label = label;
    _progress = progress;
}


@end

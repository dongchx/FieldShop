//
//  FSUnitVC.m
//  FieldShop
//
//  Created by dongchx on 25/01/2018.
//  Copyright © 2018 dongchx. All rights reserved.
//

#import "FSUnitVC.h"
#import "Unit+CoreDataClass.h"
#import "AppDelegate.h"
#import <Masonry.h>

@interface FSUnitVC () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *nameTF;

@end

@implementation FSUnitVC

- (void)viewDidLoad
{
    FSDebug;
    [super viewDidLoad];
    [self setupNavigationBar];
    [self setupSubviews:self.view];
    [self hideKeyboardWhenBackgroundIsTapped];
}

- (void)viewWillAppear:(BOOL)animated
{
    FSDebug;
    [super viewWillAppear:animated];
    [self refreshInterface];
    [self.nameTF becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    FSDebug;
    [super viewDidDisappear:animated];
    FSCoreDataHelper *cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    [cdh saveContext];
}

- (void)refreshInterface
{
    FSDebug;
    if (self.selectedObjectID) {
        FSCoreDataHelper *cdh =
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        
        Unit *unit =
        (Unit *)[cdh.context existingObjectWithID:self.selectedObjectID
                                            error:nil];
        
        self.nameTF.text = unit.name;
    }
}

#pragma mark - subviews

- (void)setupNavigationBar
{
    self.title = @"UnitVC";
    UIBarButtonItem *rightButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(done:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.hidesBackButton = YES;
}

- (void)setupSubviews:(UIView *)parentView
{
    parentView.backgroundColor = [UIColor whiteColor];
    
    _nameTF = [self customTextField];
    [parentView addSubview:_nameTF];
    _nameTF.placeholder = @"Name";
    
    [_nameTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(parentView).offset(64. + 16.);
        make.left.equalTo(parentView).offset(16.);
        make.right.equalTo(parentView).offset(-16.);
        make.height.mas_equalTo(48);
    }];
}

- (UITextField *)customTextField
{
    UITextField *textField = [[UITextField alloc] init];
    textField.font = [UIFont boldSystemFontOfSize:17.];
    textField.textAlignment = NSTextAlignmentCenter;
    textField.borderStyle = UITextBorderStyleLine;
    textField.delegate = self;
    textField.backgroundColor = [UIColor lightGrayColor];
    
    return textField;
}

#pragma mark - textFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    FSDebug;
    
    FSCoreDataHelper *cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    
    Unit *unit =
    (Unit *)[cdh.context existingObjectWithID:self.selectedObjectID
                                        error:nil];
    
    if (textField == self.nameTF) {
        unit.name = self.nameTF.text;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kFSSomethingChangedNotification
                       object:nil];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    FSDebug;
    
    FSCoreDataHelper *cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    
    Unit *unit =
    (Unit *)[cdh.context existingObjectWithID:self.selectedObjectID
                                        error:nil];
    
    unit.name = self.nameTF.text;
}

#pragma mark - interaction

- (void)done:(id)sender
{
    FSDebug;
    [self hideKeyboard];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)hideKeyboardWhenBackgroundIsTapped
{
    FSDebug;
    UITapGestureRecognizer *tap
    = [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(hideKeyboard)];
    
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)hideKeyboard
{
    FSDebug;
    [self.view endEditing:YES];
}

@end

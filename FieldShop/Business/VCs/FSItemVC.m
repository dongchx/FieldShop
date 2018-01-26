//
//  FSItemVC.m
//  FieldShop
//
//  Created by dongchx on 23/01/2018.
//  Copyright © 2018 dongchx. All rights reserved.
//

#import "FSItemVC.h"
#import <Masonry.h>
#import "AppDelegate.h"
#import "Item+CoreDataClass.h"
#import "LocationAtHome+CoreDataClass.h"
#import "LocationAtShop+CoreDataClass.h"
#import "FSUnitTVC.h"
#import "FSLocationsAtHomeTVC.h"
#import "FSLocationAtShopTVC.h"

@interface FSItemVC ()

@property (nonatomic, strong) UITextField *nameTF;
@property (nonatomic, strong) UITextField *quantityTF;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton  *addUnit;
@property (nonatomic, strong) UIButton  *addHomeLocation;
@property (nonatomic, strong) UIButton  *addShopLocation;

@end

@implementation FSItemVC

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
    
    [self ensureItemHomeLocationIsNotNull];
    [self ensureItemShopLocationIsNotNull];
    [self refreshInterface];
    
    if ([self.nameTF.text isEqualToString:@"New Item"]) {
        self.nameTF.text = @"";
        [self.nameTF becomeFirstResponder];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    FSDebug;
    [super viewDidDisappear:animated];
    
    [self ensureItemHomeLocationIsNotNull];
    [self ensureItemShopLocationIsNotNull];
    FSCoreDataHelper *cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    [cdh saveContext];
}

- (void)refreshInterface
{
    FSDebug;
    if (self.selectedItemID) {
        FSCoreDataHelper *cdh =
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        Item *item = (Item *)[cdh.context existingObjectWithID:self.selectedItemID
                                                         error:nil];
        
        self.nameTF.text = item.name;
        self.quantityTF.text = item.quantity.stringValue;
    }
}

#pragma mark - subviews

- (void)setupNavigationBar
{
    self.title = @"FSItemVC";
    UIBarButtonItem *rightButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(done:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.navigationItem.hidesBackButton = YES;
}

- (void)setupSubviews:(UIView *)parentView
{
    FSDebug;
    parentView.backgroundColor = [UIColor whiteColor];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [parentView addSubview:scrollView];
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(parentView);
    }];
    
    _nameTF = [self customTextField];
    [scrollView addSubview:_nameTF];
    _nameTF.placeholder = @"Name";
    
    _quantityTF = [self customTextField];
    [scrollView addSubview:_quantityTF];
    _quantityTF.placeholder = @"Qty";
    _quantityTF.keyboardType = UIKeyboardTypeDecimalPad;
    _quantityTF.clearsOnBeginEditing = YES;
    
    [_nameTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(scrollView).offset(16.);
        make.left.equalTo(scrollView).offset(16.);
        make.width.equalTo(scrollView.mas_width).sizeOffset(CGSizeMake(-32, 0));
        make.height.mas_equalTo(48);
    }];
    
    [_quantityTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nameTF.mas_bottom).offset(6.);
        make.left.equalTo(_nameTF);
        make.height.mas_equalTo(48);
        make.width.mas_equalTo(60);
    }];
    
    [self setupButtons:scrollView];
}

- (void)setupButtons:(UIView *)parentView
{
    _addUnit = [UIButton buttonWithType:UIButtonTypeCustom];
    [parentView addSubview:_addUnit];
    [_addUnit setTitle:@"Unit" forState:UIControlStateNormal];
    [_addUnit addTarget:self
                 action:@selector(handleAddUnit:)
       forControlEvents:UIControlEventTouchUpInside];
    
    _addHomeLocation = [UIButton buttonWithType:UIButtonTypeCustom];
    [parentView addSubview:_addHomeLocation];
    [_addHomeLocation setTitle:@"Hom" forState:UIControlStateNormal];
    [_addHomeLocation addTarget:self
                         action:@selector(handleAddHomeLocation:)
               forControlEvents:UIControlEventTouchUpInside];
    
    _addShopLocation = [UIButton buttonWithType:UIButtonTypeCustom];
    [parentView addSubview:_addShopLocation];
    [_addShopLocation setTitle:@"Shop" forState:UIControlStateNormal];
    [_addShopLocation addTarget:self
                         action:@selector(handleAddShopLocation:)
               forControlEvents:UIControlEventTouchUpInside];
    
    //
    //
    [_addUnit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_quantityTF);
        make.right.equalTo(_nameTF);
        make.width.height.mas_equalTo(48);
    }];
    
    [_addHomeLocation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_addUnit.mas_bottom).offset(6);
        make.right.width.height.equalTo(_addUnit);
    }];
    
    [_addShopLocation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_addHomeLocation.mas_bottom).offset(6);
        make.right.width.height.equalTo(_addHomeLocation);
    }];
    
    _addUnit.backgroundColor = [UIColor lightGrayColor];
    _addShopLocation.backgroundColor = [UIColor lightGrayColor];
    _addHomeLocation.backgroundColor = [UIColor lightGrayColor];
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

- (void)handleAddUnit:(id)sneder
{
    FSUnitTVC *unitTVC = [[FSUnitTVC alloc] init];
    [self.navigationController pushViewController:unitTVC animated:YES];
}

- (void)handleAddHomeLocation:(id)sender
{
    FSLocationsAtHomeTVC *homeTVC = [[FSLocationsAtHomeTVC alloc] init];
    [self.navigationController pushViewController:homeTVC animated:YES];
}

- (void)handleAddShopLocation:(id)sender
{
    FSLocationAtShopTVC *shopTVC = [[FSLocationAtShopTVC alloc] init];
    [self.navigationController pushViewController:shopTVC animated:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    FSDebug;
    
    if (textField == self.nameTF) {
        if ([self.nameTF.text isEqualToString:@"New Item"]) {
            self.nameTF.text = @"";
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    FSDebug;
    FSCoreDataHelper *cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    
    Item *item = (Item *)[cdh.context existingObjectWithID:self.selectedItemID
                                                     error:nil];
    
    if (textField == self.nameTF) {
        if ([self.nameTF.text isEqualToString:@""]) {
            self.nameTF.text = @"New Item";
        }
        item.name = self.nameTF.text;
    }
    else if (textField == self.quantityTF) {
        item.quantity = @(self.quantityTF.text.floatValue);
    }
}

#pragma mark - data

- (void)ensureItemHomeLocationIsNotNull
{
    FSDebug;
    
    if (self.selectedItemID) {
        FSCoreDataHelper *cdh =
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        
        Item *item = (Item *)[cdh.context existingObjectWithID:self.selectedItemID
                                                         error:nil];
        
        if (!item.locationAtHome) {
            NSFetchRequest *request =
            [cdh.model fetchRequestTemplateForName:@"UnknownLocationAtHome"];
            NSArray *fetchedObjects = [cdh.context executeFetchRequest:request
                                                                 error:nil];
            
            if ([fetchedObjects count] > 0) {
                item.locationAtHome = [fetchedObjects objectAtIndex:0];
            }
            else {
                LocationAtHome *locationAtHome =
                [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtHome"
                                              inManagedObjectContext:cdh.context];
                
                NSError *error = nil;
                if (![cdh.context obtainPermanentIDsForObjects:@[locationAtHome]
                                                         error:&error]) {
                    FSLog(@"Couldn't obtain a permanent ID for object %@", error);
                }
                locationAtHome.storedIn = @"..Unknown Location..";
                item.locationAtHome = locationAtHome;
            }
        }
    }
}

- (void)ensureItemShopLocationIsNotNull
{
    FSDebug;
    
    if (self.selectedItemID) {
        FSCoreDataHelper *cdh =
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        
        Item *item = (Item *)[cdh.context existingObjectWithID:self.selectedItemID
                                                         error:nil];
        
        if (!item.locationAtShop) {
            NSFetchRequest *request =
            [cdh.model fetchRequestTemplateForName:@"UnknownLocationAtShop"];
            NSArray *fetchedObjects = [cdh.context executeFetchRequest:request
                                                                 error:nil];
            
            if ([fetchedObjects count] > 0) {
                item.locationAtShop = [fetchedObjects objectAtIndex:0];
            }
            else {
                LocationAtShop *locationAtShop =
                [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtShop"
                                              inManagedObjectContext:cdh.context];
                
                NSError *error = nil;
                if (![cdh.context obtainPermanentIDsForObjects:@[locationAtShop]
                                                         error:&error]) {
                    FSLog(@"Couldn't obtain a permanent ID for object %@", error);
                }
                locationAtShop.aisle = @"..Unknown Location..";
                item.locationAtShop = locationAtShop;
            }
        }
    }
    
}

@end

















































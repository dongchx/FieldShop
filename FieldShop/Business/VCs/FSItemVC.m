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
#import "Unit+CoreDataClass.h"
#import "LocationAtHome+CoreDataClass.h"
#import "LocationAtShop+CoreDataClass.h"
#import "FSUnitTVC.h"
#import "FSLocationsAtHomeTVC.h"
#import "FSLocationAtShopTVC.h"
#import "FSUnitPickerTF.h"
#import "FSLocationAtHomePickerTF.h"
#import "FSLocationAtShopPickerTF.h"
#import "Item_Photo+CoreDataClass.h"

@interface FSItemVC ()
<
UITextFieldDelegate,
FSCoreDataPickerTFDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate
>

@property (nonatomic, strong) UITextField *nameTF;
@property (nonatomic, strong) UITextField *quantityTF;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton  *addUnit;
@property (nonatomic, strong) UIButton  *addHomeLocation;
@property (nonatomic, strong) UIButton  *addShopLocation;
@property (nonatomic, strong) UIButton  *addImage;
@property (nonatomic, strong) UIImageView   *imageView;
@property (nonatomic, strong) FSUnitPickerTF *unitPickerTF;
@property (nonatomic, strong) FSLocationAtHomePickerTF *homePickerTF;
@property (nonatomic, strong) FSLocationAtShopPickerTF *shopPickerTF;
@property (nonatomic, strong) UITextField *activeField;

@property (nonatomic, strong) UIImagePickerController *camera;

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
    
    [self registerNotifications];
}

- (void)viewDidDisappear:(BOOL)animated
{
    FSDebug;
    [super viewDidDisappear:animated];
    
    [self ensureItemHomeLocationIsNotNull];
    [self ensureItemShopLocationIsNotNull];
    FSCoreDataHelper *cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    [cdh backgroundSaveContext];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSError *error = nil;
    Item *item =
    (Item *)[cdh.context existingObjectWithID:self.selectedItemID
                                        error:&error];
    
    if (error) {
        FSLog(@"ERROR!!! --> %@", error.localizedDescription);
    }
    else {
        [cdh.context refreshObject:item.photo mergeChanges:NO];
        [cdh.context refreshObject:item mergeChanges:NO];
    }
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
        self.unitPickerTF.text = item.unit.name;
        self.unitPickerTF.selectedObjectID = item.unit.objectID;
        self.homePickerTF.text = item.locationAtHome.storedIn;
        self.homePickerTF.selectedObjectID = item.locationAtHome.objectID;
        self.shopPickerTF.text = item.locationAtShop.aisle;
        self.shopPickerTF.selectedObjectID = item.locationAtShop.objectID;
        
        [cdh.context performBlock:^{
            self.imageView.image = [UIImage imageWithData:item.photo.data];
        }];
        
        [self checkCamera];
    }
}

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
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
    [self setupPickers:scrollView];
    
    _imageView = [[UIImageView alloc] init];
    [parentView addSubview:_imageView];
    _imageView.backgroundColor = [UIColor lightGrayColor];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_shopPickerTF.mas_bottom).offset(6.);
        make.left.width.equalTo(_shopPickerTF);
        make.height.equalTo(_imageView.mas_width);
    }];
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
    
    _addImage = [UIButton buttonWithType:UIButtonTypeCustom];
    [parentView addSubview:_addImage];
    [_addImage setTitle:@"Img" forState:UIControlStateNormal];
    [_addImage addTarget:self
                  action:@selector(showCamera:)
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
    
    [_addImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_addShopLocation.mas_bottom).offset(6);
        make.right.width.height.equalTo(_addShopLocation);
    }];
    
    _addUnit.backgroundColor = [UIColor lightGrayColor];
    _addShopLocation.backgroundColor = [UIColor lightGrayColor];
    _addHomeLocation.backgroundColor = [UIColor lightGrayColor];
    _addImage.backgroundColor = [UIColor lightGrayColor];
}

- (void)setupPickers:(UIView *)parentView
{
    _unitPickerTF = [[FSUnitPickerTF alloc] initWithFrame:CGRectZero];
    [parentView addSubview:_unitPickerTF];
    [self setupPickerTF:_unitPickerTF];
    _unitPickerTF.placeholder = @"Unit";
    
    _homePickerTF = [[FSLocationAtHomePickerTF alloc] initWithFrame:CGRectZero];
    [parentView addSubview:_homePickerTF];
    [self setupPickerTF:_homePickerTF];
    _homePickerTF.placeholder = @"Location at Home";
    
    _shopPickerTF = [[FSLocationAtShopPickerTF alloc] initWithFrame:CGRectZero];
    [parentView addSubview:_shopPickerTF];
    [self setupPickerTF:_shopPickerTF];
    _shopPickerTF.placeholder = @"Location at Shop";
    
    [_unitPickerTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_quantityTF);
        make.left.equalTo(_quantityTF.mas_right).offset(6.);
        make.right.equalTo(_addUnit.mas_left).offset(-6.);
        make.height.mas_equalTo(48.);
    }];
    
    [_homePickerTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_unitPickerTF.mas_bottom).offset(6.);
        make.left.equalTo(_quantityTF);
        make.right.equalTo(_unitPickerTF);
        make.height.mas_equalTo(48.);
    }];
    
    [_shopPickerTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_homePickerTF.mas_bottom).offset(6.);
        make.left.right.height.equalTo(_homePickerTF);
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

- (FSCoreDataPickerTF *)setupPickerTF:(FSCoreDataPickerTF *)pickerTF
{
    pickerTF.font = [UIFont boldSystemFontOfSize:17.];
    pickerTF.textAlignment = NSTextAlignmentCenter;
    pickerTF.borderStyle = UITextBorderStyleLine;
    pickerTF.backgroundColor = [UIColor lightGrayColor];
    pickerTF.delegate = self;
    pickerTF.pickerDelegate = self;
    
    return pickerTF;
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

- (void)keyboardDidShow:(NSNotification *)noti
{
    FSDebug;
    CGRect keyboardRect =
    [[[noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    CGFloat keyboardTop = keyboardRect.origin.y;
    
    CGRect newScrollViewFrame =
    CGRectMake(0, 0, self.view.bounds.size.width, keyboardTop);
    newScrollViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    self.scrollView.frame = newScrollViewFrame;
    
    [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)noti
{
    FSDebug;
    CGRect defaultFrame = CGRectMake(self.scrollView.frame.origin.x,
                                     self.scrollView.frame.origin.y,
                                     self.view.frame.size.width,
                                     self.view.frame.size.height);
    
    self.scrollView.frame = defaultFrame;
    [self.scrollView scrollRectToVisible:self.nameTF.frame animated:YES];
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
    
    if (textField == self.unitPickerTF && self.unitPickerTF.picker) {
        [self.unitPickerTF fetch];
        [self.unitPickerTF.picker reloadAllComponents];
    }
    else if (textField == self.homePickerTF && self.homePickerTF.picker) {
        [self.homePickerTF fetch];
        [self.homePickerTF.picker reloadAllComponents];
    }
    else if (textField == self.shopPickerTF && self.shopPickerTF.picker) {
        [self.shopPickerTF fetch];
        [self.shopPickerTF.picker reloadAllComponents];
    }
    
    self.activeField = textField;
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
    
    self.activeField = nil;
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

#pragma mark - pickers

- (void)selectedObjectID:(NSManagedObjectID *)objectID
      changedForPickerTF:(FSCoreDataPickerTF *)pickedTF
{
    FSDebug;
    
    if (self.selectedItemID) {
        FSCoreDataHelper *cdh =
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        Item *item = (Item *)[cdh.context existingObjectWithID:self.selectedItemID
                                                         error:nil];
        
        NSError *error = nil;
        if (pickedTF == self.unitPickerTF) {
            Unit *unit = (Unit *)[cdh.context existingObjectWithID:objectID
                                                             error:&error];
            item.unit = unit;
            self.unitPickerTF.text = item.unit.name;
        }
        else if (pickedTF == self.homePickerTF) {
            LocationAtHome *locationAtHome =
            (LocationAtHome *)[cdh.context existingObjectWithID:objectID
                                                          error:&error];
            item.locationAtHome = locationAtHome;
            self.homePickerTF.text = item.locationAtHome.storedIn;
        }
        else if (pickedTF == self.shopPickerTF) {
            LocationAtShop *locationAtShop =
            (LocationAtShop *)[cdh.context existingObjectWithID:objectID
                                                          error:&error];
            item.locationAtShop = locationAtShop;
            self.shopPickerTF.text = item.locationAtShop.aisle;
        }
        
        [self refreshInterface];
        
        if (error) {
            FSLog(@"Error selecting object on picker: %@, %@",
                  error, error.localizedDescription);
        }
    }
}

- (void)selectedObjectClearedForPickerTF:(FSCoreDataPickerTF *)pickerTF
{
    FSDebug;
    
    if (self.selectedItemID) {
        FSCoreDataHelper *cdh =
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        Item *item = (Item *)[cdh.context existingObjectWithID:self.selectedItemID
                                                         error:nil];
        
        if (pickerTF == self.unitPickerTF) {
            item.unit = nil;
            self.unitPickerTF.text = @"";
        }
        else if (pickerTF == self.homePickerTF) {
            item.locationAtHome = nil;
            self.homePickerTF.text = @"";
        }
        else if (pickerTF == self.shopPickerTF) {
            item.locationAtShop = nil;
            self.shopPickerTF.text = @"";
        }
        
        [self refreshInterface];
    }
}

#pragma mark - CAMERA

- (void)checkCamera
{
    FSDebug;
    self.addImage.enabled =
    [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (void)showCamera:(id)sender
{
    FSDebug;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        FSLog(@"Camera is available");
        _camera = [[UIImagePickerController alloc] init];
        _camera.sourceType = UIImagePickerControllerSourceTypeCamera;
        _camera.mediaTypes =
        [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        _camera.allowsEditing = YES;
        _camera.delegate = self;
        [self.navigationController presentViewController:_camera
                                                animated:YES
                                              completion:nil];
    }
    else {
        FSLog(@"Camera not avaliable");
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    FSDebug;
    
    FSCoreDataHelper *cdh =
    [(AppDelegate *) [[UIApplication sharedApplication] delegate] cdh];
    
    Item *item =
    (Item *)[cdh.context existingObjectWithID:self.selectedItemID error:nil];
    
    UIImage *photo =
    (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
    
    FSLog(@"Captured %f x %f photo", photo.size.width, photo.size.height);
    
    if (!item.photo) {
        Item_Photo *newPhoto =
        [NSEntityDescription insertNewObjectForEntityForName:@"Item_Photo"
                                      inManagedObjectContext:cdh.context];
        item.photo = newPhoto;
    }
    item.thumbnail = nil;
    item.photo.data = UIImageJPEGRepresentation(photo, 0.5);
    
    self.imageView.image = photo;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    FSDebug;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end

















































//
//  FSCoreDataPickerTF.m
//  FieldShop
//
//  Created by dongchx on 29/01/2018.
//  Copyright © 2018 dongchx. All rights reserved.
//

#import "FSCoreDataPickerTF.h"

@interface FSCoreDataPickerTF ()

@property (nonatomic, strong) UIPickerView *picker;
@property (nonatomic, strong) UIToolbar *toolBar;

@end

@implementation FSCoreDataPickerTF

- (instancetype)initWithFrame:(CGRect)frame
{
    FSDebug;
    
    if (self = [super initWithFrame:frame]) {
        self.inputView = [self createInputView];
        self.inputAccessoryView = [self createInputAccessoryView];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    FSDebug;
    
    if (self = [super initWithCoder:aDecoder]) {
        self.inputView = [self createInputView];
        self.inputAccessoryView = [self createInputAccessoryView];
    }
    
    return self;
}

#pragma mark - view

- (UIView *)createInputView
{
    FSDebug;
    
    self.picker = [[UIPickerView alloc] init];
    self.picker.showsSelectionIndicator = YES;
    self.picker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.picker.dataSource = self;
    self.picker.delegate = self;
    [self fetch];
    
    return self.picker;
}

- (UIView *)createInputAccessoryView
{
    FSDebug;
    
    self.showToolbar = YES;
    if (!self.toolBar && self.showToolbar) {
        self.toolBar = [[UIToolbar alloc] init];
        self.toolBar.barStyle = UIBarStyleBlackTranslucent;
        self.toolBar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.toolBar sizeToFit];
        CGRect frame = self.toolBar.frame;
        frame.size.height = 44.f;
        self.toolBar.frame = frame;
        
        UIBarButtonItem *clearBtn =
        [[UIBarButtonItem alloc] initWithTitle:@"Clear"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(clear)];
        UIBarButtonItem *spacer =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                      target:nil
                                                      action:nil];
        UIBarButtonItem *doneBar =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self
                                                      action:@selector(done)];
        self.toolBar.items = @[clearBtn, spacer, doneBar];
    }
    
    return self.toolBar;
}

- (void)deviceDidRotate:(NSNotification *)notification
{
    FSDebug;
    [self.picker setNeedsLayout];
}

#pragma mark - interaction

- (void)done
{
    FSDebug;
    [self resignFirstResponder];
}

- (void)clear
{
    FSDebug;
    [self.pickerDelegate selectedObjectClearedForPickerTF:self];
    [self resignFirstResponder];
}

#pragma mark - data

- (void)fetch
{
    // override
}

- (void)selectDefaultRow
{
    // override
}

#pragma mark - UIPickerViewDelegate/DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    FSDebug;
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    FSDebug;
    return self.pickerData.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView
rowHeightForComponent:(NSInteger)component
{
    FSDebug;
    return 44.f;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView
    widthForComponent:(NSInteger)component
{
    FSDebug;
    return 280.f;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    FSDebug;
    return [self.pickerData objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    FSDebug;
    NSManagedObject *object = [self.pickerData objectAtIndex:row];
    [self.pickerDelegate selectedObjectID:object.objectID
                       changedForPickerTF:self];
}

@end
































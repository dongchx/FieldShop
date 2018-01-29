//
//  FSCoreDataPickerTF.h
//  FieldShop
//
//  Created by dongchx on 29/01/2018.
//  Copyright © 2018 dongchx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCoreDataHelper.h"

@class FSCoreDataPickerTF;

@protocol FSCoreDataPickerTFDelegate <NSObject>

- (void)selectedObjectID:(NSManagedObjectID *)objectID
      changedForPickerTF:(FSCoreDataPickerTF *)pickedTF;

@optional
- (void)selectedObjectClearedForPickerTF:(FSCoreDataPickerTF *)pickerTF;

@end

@interface FSCoreDataPickerTF : UITextField
<
UIKeyInput,
UIPickerViewDelegate,
UIPickerViewDataSource
>

@property (nonatomic, weak) id<FSCoreDataPickerTFDelegate> pickerDelegate;
@property (nonatomic, strong) NSManagedObjectID *selectedObjectID;
@property (nonatomic, strong) NSArray *pickerData;
@property (nonatomic, assign) BOOL showToolbar;
@property (nonatomic, strong, readonly) UIToolbar *toolBar;
@property (nonatomic, strong, readonly) UIPickerView *picker;

- (void)fetch;

@end

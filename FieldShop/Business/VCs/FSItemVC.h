//
//  FSItemVC.h
//  FieldShop
//
//  Created by dongchx on 23/01/2018.
//  Copyright © 2018 dongchx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCoreDataHelper.h"

@interface FSItemVC : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) NSManagedObjectID *selectedItemID;

@end

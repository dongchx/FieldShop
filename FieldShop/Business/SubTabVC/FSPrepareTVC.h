//
//  FSPrepareTVC.h
//  FieldShop
//
//  Created by dongchx on 18/01/2018.
//  Copyright © 2018 dongchx. All rights reserved.
//

#import "FSCoreDataTVC.h"

@interface FSPrepareTVC : FSCoreDataTVC <UIActionSheetDelegate>

@property (nonatomic, strong) UIActionSheet *clearconfirmActionSheet;

@end

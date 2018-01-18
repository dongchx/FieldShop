//
//  AppDelegate.h
//  FieldShop
//
//  Created by dongchx on 05/12/2017.
//  Copyright © 2017 dongchx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCoreDataHelper.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) FSCoreDataHelper *coreDataHelper;

- (FSCoreDataHelper *)cdh;

@end


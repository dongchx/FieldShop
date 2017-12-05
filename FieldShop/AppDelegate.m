//
//  AppDelegate.m
//  FieldShop
//
//  Created by dongchx on 05/12/2017.
//  Copyright © 2017 dongchx. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.cdh saveContext];
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.cdh saveContext];
}

#pragma mark - coreData

- (FSCoreDataHelper *)cdh
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    if (!_coreDataHelper) {
        _coreDataHelper = [[FSCoreDataHelper alloc] init];
        [_coreDataHelper setupCoreData];
    }
    
    return _coreDataHelper;
}


@end

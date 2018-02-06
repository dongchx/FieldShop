//
//  AppDelegate.m
//  FieldShop
//
//  Created by dongchx on 05/12/2017.
//  Copyright © 2017 dongchx. All rights reserved.
//

#import "AppDelegate.h"
#import "FSRootViewController.h"
#import "FSRootTabController.h"
#import "Item+CoreDataProperties.h"
#import "Unit+CoreDataProperties.h"
#import "LocationAtHome+CoreDataProperties.h"
#import "LocationAtShop+CoreDataProperties.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)demo
{
    FSDebug;
    
//    FSCoreDataHelper *cdh = [self cdh];
//
//    NSArray *homeLocations = @[@"Fruit Bowl", @"Pantry", @"Nuresery", @"Bathroom", @"Fridge"];
//    NSArray *shopLocations = @[@"Product", @"Aisle 1", @"Aisle 2", @"Aisle3", @"Deli"];
//    NSArray *unitNames = @[@"g", @"pkt", @"box", @"ml", @"kg"];
//    NSArray *itemNames = @[@"Grapes", @"Biscuits", @"Nappies", @"Shampoo", @"Sausages"];
//
//
//    for (int i = 0; i < 5; i++) {
//        LocationAtHome *locationAtHome =
//        [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtHome"
//                                      inManagedObjectContext:cdh.context];
//        LocationAtShop *locationAtShop =
//        [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtShop"
//                                      inManagedObjectContext:cdh.context];
//        Unit *unit =
//        [NSEntityDescription insertNewObjectForEntityForName:@"Unit"
//                                      inManagedObjectContext:cdh.context];
//        Item *item =
//        [NSEntityDescription insertNewObjectForEntityForName:@"Item"
//                                      inManagedObjectContext:cdh.context];
//
//        locationAtHome.storedIn = [homeLocations objectAtIndex:i];
//        locationAtShop.aisle = [shopLocations objectAtIndex:i];
//        unit.name = [unitNames objectAtIndex:i];
//        item.name = [itemNames objectAtIndex:i];
//
//        item.locationAtHome = locationAtHome;
//        item.locationAtShop = locationAtShop;
//        item.unit = unit;
//    }
//
//
//    [cdh saveContext];
    
    // 创建托管对象
//    NSArray *newItemNames =
//    @[@"Apples", @"Milk", @"Bread", @"Cheese", @"Sausages", @"Butter",
//      @"Orange Juice", @"Cereal", @"Coffee", @"Eggs", @"Tomatoes", @"Fish"];
//    
//    for (NSString *newItemName in newItemNames) {
//        Item *newItem =
//        [NSEntityDescription insertNewObjectForEntityForName:@"Item"
//                                      inManagedObjectContext:self.cdh.context];
//
//        newItem.name = newItemName;
//        
//        FSLog(@"Inserted New Managed object for '%@'", newItem.name);
//    }
    
    // 插入测试数据
//    for (int i = 1; i < 50000; i++) {
//        Measurement *newMeasurement =
//        [NSEntityDescription insertNewObjectForEntityForName:@"Measurement"
//                                      inManagedObjectContext:self.cdh.context];
//        newMeasurement.abc =
//        [NSString stringWithFormat:@"-->> LOTS OF TEST DATA x%i", i];
//        
//        FSLog(@"Inserted %@", newMeasurement.abc);
//        
//        [self.cdh saveContext];
//    }
    
    /* 获取托管对象 */
//    NSFetchRequest *request =
//    [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
//    request.fetchLimit = 50;
    
//    // 排序描述符
//    NSSortDescriptor *sort =
//    [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
//    request.sortDescriptors = @[sort,];
    
    // 获取请求模板
//    NSFetchRequest *request =
//    [[self.cdh.model fetchRequestTemplateForName:@"Test"] copy];
    
    // 筛选
//    NSPredicate *filter =
//    [NSPredicate predicateWithFormat:@"name != %@", @"Coffee"];
//    request.predicate = filter;
    
//    NSError *error = nil;
//    NSArray *fetchedObjects =
//    [self.cdh.context executeFetchRequest:request error:&error];
//    
//    if (error) {
//        FSLog(@"%@", error);
//    }
//    else {
//        for (Unit *item in fetchedObjects) {
//            FSLog(@"Fetched Object = %@", item.name);
//            
//            // 删除托管对象
//            //        [self.cdh.context deleteObject:item];
//        }
//    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
//    FSRootViewController *rootVC = [[FSRootViewController alloc] init];
    FSRootTabController *rootVC = [[FSRootTabController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.cdh backgroundSaveContext];
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    [self cdh];
    [self demo];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.cdh backgroundSaveContext];
}

#pragma mark - coreData

- (FSCoreDataHelper *)cdh
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    if (!_coreDataHelper) {
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{
            _coreDataHelper = [[FSCoreDataHelper alloc] init];
        });
        [_coreDataHelper setupCoreData];
    }
    
    return _coreDataHelper;
}


@end

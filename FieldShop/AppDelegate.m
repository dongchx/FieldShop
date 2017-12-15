//
//  AppDelegate.m
//  FieldShop
//
//  Created by dongchx on 05/12/2017.
//  Copyright © 2017 dongchx. All rights reserved.
//

#import "AppDelegate.h"
#import "FSRootViewController.h"
#import "Item+CoreDataProperties.h"
#import "Measurement+CoreDataProperties.h"
#import "Amount+CoreDataProperties.h"
#import "Unit+CoreDataProperties.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)demo
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    Unit *kg =
    [NSEntityDescription insertNewObjectForEntityForName:@"Unit"
                                  inManagedObjectContext:self.cdh.context];
    
    Item *oranges =
    [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                  inManagedObjectContext:self.cdh.context];
    
    Item *bananas =
    [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                  inManagedObjectContext:self.cdh.context];
    
    kg.name = @"Kg";
    oranges.name = @"Oranges";
    bananas.name = @"Bananas";
    oranges.quantity = @1;
    bananas.quantity = @4;
    oranges.listed = @YES;
    bananas.listed = @YES;
    oranges.unit = kg;
    oranges.unit = kg;
    
    FSLog(@"Inserted %@%@ %@",
          oranges.quantity, oranges.unit.name, oranges.name);
    FSLog(@"Inserted %@%@ %@",
          bananas.quantity, bananas.unit.name, bananas.name);
    
    [self.cdh saveContext];
    
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
    
    FSRootViewController *rootVC = [[FSRootViewController alloc] init];
    UINavigationController *navi =
    [[UINavigationController alloc] initWithRootViewController:rootVC];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.window.rootViewController = navi;
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
    [self.cdh saveContext];
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

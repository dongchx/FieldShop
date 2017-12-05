//
//  FSCoreDataHelper.m
//  FieldShop
//
//  Created by dongchx on 05/12/2017.
//  Copyright © 2017 dongchx. All rights reserved.
//

#import "FSCoreDataHelper.h"


@implementation FSCoreDataHelper

#pragma mark - FILES
// 持久化存储区文件名
NSString *storeFilename = @"Field-Shop.sqlite";

#pragma mark - PATHS
// 持久化存储区文件路径
- (NSString *)applicationDocumentsDirectory
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    return
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSURL *)applicationStoresDirectory
{
    FSLog(@"Runing %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    NSURL *storesDirectory =
    [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]] URLByAppendingPathComponent:@"Stores"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[storesDirectory path]]) {
        NSError *error = nil;
        if ([fileManager createDirectoryAtURL:storesDirectory
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:&error]) {
            
            FSLog(@"Successfully created Stores dire");
        }
        else {
            
            FSLog(@"Failed to create Stores directiry : %@", error);
        }
    }
    
    return storesDirectory;
}

- (NSURL *)storeURL
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    return
    [[self applicationStoresDirectory] URLByAppendingPathComponent:storeFilename];
}

#pragma mark - SETUP

- (instancetype)init
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    if (self = [super init]) {
        _model = [NSManagedObjectModel mergedModelFromBundles:nil];
        _coordinator =
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
        
        _context =
        [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_context setPersistentStoreCoordinator:_coordinator];
    }
    
    return self;
}

- (void)loadStore
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    if (_store) { return; }
    
    NSError *error = nil;
    _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                        configuration:nil
                                                  URL:[self storeURL]
                                              options:nil
                                                error:&error];
    
    if (_store) {
        FSLog(@"Successfully added store : %@", _store);
    }
    else {
        FSLog(@"Failed to add store! Error: %@", error);
    }
}

- (void)setupCoreData
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    [self loadStore];
}

#pragma mark - SAVING

- (void)saveContext
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));;
    
    if ([_context hasChanges]) {
        NSError *error = nil;
        if ([_context save:&error]) {
            FSLog(@"_context SAVED changes to persistent store");
        }
        else {
            FSLog(@"Failed to save _context: %@", error);
        }
    }
    else {
        FSLog(@"There are no changes on _context!");
    }
}

@end





































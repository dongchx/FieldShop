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
    
    BOOL useMigrationManager = YES;
    if (useMigrationManager &&
        [self isMigrationNecessaryForStore:[self storeURL]]) {
        // migration
        [self performBackgroundManagedMigrationForStore:[self storeURL]];
    }
    else {
        NSDictionary *options =
        @{
          NSMigratePersistentStoresAutomaticallyOption : @YES,
          NSInferMappingModelAutomaticallyOption       : @NO,
          NSSQLitePragmasOption : @{@"journal_mode" : @"DELETE"},
          };
        
        NSError *error = nil;
        _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                            configuration:nil
                                                      URL:[self storeURL]
                                                  options:options
                                                    error:&error];
        
        if (_store) {
            FSLog(@"Successfully added store : %@", _store);
        }
        else {
            FSLog(@"Failed to add store! Error: %@", error);
        }
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
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
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

#pragma mark - MIGRATION MANAGER

- (BOOL)isMigrationNecessaryForStore:(NSURL *)storeUrl
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.storeURL.path]) {
        FSLog(@"SKIPPED MIGRATION : Source database missing.");
        return NO;
    }
    
    NSError *error = nil;
    NSDictionary *sourceMetadata =
    [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                               URL:storeUrl
                                                             error:&error];
    NSManagedObjectModel *destinationModel =
    _coordinator.managedObjectModel;
    
    if ([destinationModel isConfiguration:nil
              compatibleWithStoreMetadata:sourceMetadata]) {
        FSLog(@"SKIPPED MIGRATION : Source is already compatible");
        return NO;
    }
    
    return YES;
}

- (BOOL)migrateStore:(NSURL *)sourceStore
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    BOOL success = NO;
    NSError *error = nil;
    
    // Step 1 - gather the source, destination and mapping model
    NSDictionary *sourceMetadata =
    [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                               URL:sourceStore
                                                             error:&error];
    NSManagedObjectModel *sourceModel =
    [NSManagedObjectModel mergedModelFromBundles:nil
                                forStoreMetadata:sourceMetadata];
    
    NSManagedObjectModel *destinModel = _model;
    
    NSMappingModel *mappingModel =
    [NSMappingModel mappingModelFromBundles:nil
                             forSourceModel:sourceModel
                           destinationModel:destinModel];
    
    // Step 2 - Perform migration, assuming the mapping model is not null
    if (mappingModel) {
        NSError *error = nil;
        NSMigrationManager *migrationManager =
        [[NSMigrationManager alloc] initWithSourceModel:sourceModel
                                       destinationModel:destinModel];
        
        [migrationManager addObserver:self
                           forKeyPath:@"migrationProgress"
                              options:NSKeyValueObservingOptionNew
                              context:NULL];
        
        NSURL *destinStore =
        [[self applicationStoresDirectory] URLByAppendingPathComponent:@"Temp.sqlite"];
        
        success =
        [migrationManager migrateStoreFromURL:sourceStore
                                         type:NSSQLiteStoreType
                                      options:nil
                             withMappingModel:mappingModel
                             toDestinationURL:destinStore
                              destinationType:NSSQLiteStoreType
                           destinationOptions:nil
                                        error:&error];
        
        // Step 3 - replace the old store with the new migrated store
        if (success) {
            if ([self replaceStore:sourceStore withStore:destinStore]) {
                FSLog(@"Successfully Migrated %@ to the current model", sourceStore.path);
                [migrationManager removeObserver:self forKeyPath:@"migrationProgress"];
            }
        }
        else {
            FSLog(@"Failed Migration: %@", error);
        }
    }
    else {
        FSLog(@"Failed Migrated: Mapping Model is null");
    }
    
    return YES;
}

- (BOOL)replaceStore:(NSURL *)old withStore:(NSURL *)new
{
    BOOL success = NO;
    NSError *error = nil;
    if ([[NSFileManager defaultManager] removeItemAtURL:old error:&error]) {
        
        error = nil;
        if ([[NSFileManager defaultManager] moveItemAtURL:new toURL:old error:&error]) {
            success = YES;
        }
        else {
            FSLog(@"Failed to re-home new store %@", error);
        }
    }
    else {
        FSLog(@"Failed to remove old store %@ : error %@", old, error);
    }
    
    return success;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"migrationProgress"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            float progress =
            [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
            self.migrationVC.progress.progress = progress;
            
            int percentage = progress * 100;
            NSString *string =
            [NSString stringWithFormat:@"Migration Progress %i%%", percentage];
            self.migrationVC.label.text = string;
            FSLog(@"%@", string);
        });
    }
}

- (void)performBackgroundManagedMigrationForStore:(NSURL *)storeURL
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    // Show migration progress view preventing the user from using the app
    self.migrationVC = [[FSMigrationViewController alloc] init];
    UINavigationController *navi =
    (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [navi presentViewController:self.migrationVC animated:NO completion:nil];
    
    // Perform migration in the background, so it doesn't freeze the UI
    // This way progress can be shown to the user
    dispatch_async(
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                       BOOL done = [self migrateStore:storeURL];
                       if (done) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               NSError *error = nil;
                               _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                   configuration:nil
                                                                             URL:[self storeURL]
                                                                         options:nil
                                                                           error:&error];
                               
                               if (!_store) {
                                   FSLog(@"Failed to add a migrated store. Error: %@", error);
                                   abort();
                               }
                               else {
                                   FSLog(@"Successfully added a migrated store: %@", _store);
                                   [self.migrationVC dismissViewControllerAnimated:NO completion:nil];
                                   self.migrationVC = nil;
                               }
                           });
                       }
                   });
}

@end





































//
//  FSCoreDataHelper.m
//  FieldShop
//
//  Created by dongchx on 05/12/2017.
//  Copyright © 2017 dongchx. All rights reserved.
//

#import "FSCoreDataHelper.h"
#import "FSCoreDataImporter.h"

#define kFSCDHDefaultDataImportedKey @"DefaultDataImported"

@interface FSCoreDataHelper ()
@property (nonatomic, strong) UIAlertView *importAlertView;
@end

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
    FSDebug;
    
    if (self = [super init]) {
        _model = [NSManagedObjectModel mergedModelFromBundles:nil];
        _coordinator =
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
        
        _context =
        [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_context setPersistentStoreCoordinator:_coordinator];
        
        _importContext =
        [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_importContext performBlockAndWait:^{
            [_importContext setPersistentStoreCoordinator:_coordinator];
            [_importContext setUndoManager:nil];
        }];
    }
    
    return self;
}

- (void)loadStore
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    if (_store) { return; }
    
    BOOL useMigrationManager = NO;
    if (useMigrationManager &&
        [self isMigrationNecessaryForStore:[self storeURL]]) {
        // migration
        [self performBackgroundManagedMigrationForStore:[self storeURL]];
    }
    else {
        NSDictionary *options =
        @{
          NSMigratePersistentStoresAutomaticallyOption : @YES,
          NSInferMappingModelAutomaticallyOption       : @YES,
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
    FSDebug;
    
    [self loadStore];
    [self checkIfDefaultDataNeedsImporting];
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
            [self showValidationError:error];
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

- (void)showValidationError:(NSError *)anError
{
    if (anError && [anError.domain isEqualToString:@"NSCocoaErrorDomain"]) {
        NSArray  *errors = nil; // holds all errors
        NSString *txt = @"";   // the error message text of the alert
        
        if (anError.code == NSValidationMultipleErrorsError) {
            errors = [anError.userInfo objectForKey:NSDetailedErrorsKey];
        }
        else {
            errors = [NSArray arrayWithObject:anError];
        }
        
        if (errors && errors.count > 0) {
            // build error message text based on errors
            for (NSError *error in errors) {
                NSString *entity =
                [[[error.userInfo objectForKey:@"NSValidationErrorObject"] entity] name];
                
                NSString *property =
                [error.userInfo objectForKey:@"NSValidationErrorKey"];
                
                switch (error.code) {
                    case NSValidationRelationshipDeniedDeleteError:
                        txt =
                        [txt stringByAppendingFormat:
                         @"%@ delete was denied because there are associated %@\n(Error Code:%li)\n\n",
                         entity, property, error.code];
                        break;
                        
                    case NSValidationRelationshipLacksMinimumCountError:
                        txt =
                        [txt stringByAppendingFormat:
                         @"the '%@' relationship count is too small (Code %li)", property, error.code];
                        break;
                        
                    case NSValidationRelationshipExceedsMaximumCountError:
                        txt =
                        [txt stringByAppendingFormat:
                         @"the '%@' relationship count is too large (Code %li)", property, error.code];
                        break;
                        
                    case NSValidationMissingMandatoryPropertyError:
                        txt =
                        [txt stringByAppendingFormat:
                         @"the '%@' property is missing (Code %li)", property, error.code];
                        break;
                        
                    case NSValidationNumberTooSmallError:
                        txt =
                        [txt stringByAppendingFormat:
                         @"the '%@' number is too small (Code %li)", property, error.code];
                        break;
                   
                    case NSValidationNumberTooLargeError:
                        txt =
                        [txt stringByAppendingFormat:
                         @"the '%@' number is too large (Code %li)", property, error.code];
                        break;
                    
                    case NSValidationDateTooSoonError:
                        txt =
                        [txt stringByAppendingFormat:
                         @"the '%@' date is too soon (Code %li)", property, error.code];
                        break;
                        
                    case NSValidationDateTooLateError:
                        txt =
                        [txt stringByAppendingFormat:
                         @"the '%@' date is too late (Code %li)", property, error.code];
                        break;
                    
                    case NSValidationInvalidDateError:
                        txt =
                        [txt stringByAppendingFormat:
                         @"the '%@' date us invalid (Code %li)", property, error.code];
                        break;
                        
                    case NSValidationStringTooLongError:
                        txt =
                        [txt stringByAppendingFormat:
                         @"the '%@' text is too long (Code %li)", property, error.code];
                        break;
                        
                    case NSValidationStringTooShortError:
                        txt =
                        [txt stringByAppendingFormat:
                         @"the '%@' text is too short (Code %li)", property, error.code];
                        break;
                    
                    case NSValidationStringPatternMatchingError:
                        txt =
                        [txt stringByAppendingFormat:
                         @"the '%@' text doesn't match the specified pattern (Code %li)", property, error.code];
                        break;
                        
                    case NSManagedObjectValidationError:
                        txt =
                        [txt stringByAppendingFormat:
                         @"generated validation error (Code %li)", error.code];
                        break;
                        
                    default:
                        txt =
                        [txt stringByAppendingFormat:
                         @"Unhandled error code %li in showValidationError method", error.code];
                        break;
                }
            }
        }
    }
}

#pragma mark - DATA IMPORT

- (BOOL)isDefaultDataAlreadyImportedForStoredWithURL:(NSURL *)url
                                              ofType:(NSString *)type
{
    FSDebug;
    
    NSError *error;
    NSDictionary *dictionary =
    [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type
                                                               URL:url
                                                             error:&error];
    
    if (error) {
        FSLog(@"Error reading persistent store metadata : %@",
              error.localizedDescription);
    }
    else {
        NSNumber *defaultDataAlreadyImported =
        [dictionary objectForKey:kFSCDHDefaultDataImportedKey];
        if (![defaultDataAlreadyImported boolValue]) {
            FSLog(@"Default Data has NOT already been imported");
            return NO;
        }
    }
    
    FSLog(@"Default Data has already been imported");
    return YES;
}

- (void)checkIfDefaultDataNeedsImporting
{
    FSDebug;
    
    if (![self isDefaultDataAlreadyImportedForStoredWithURL:[self storeURL]
                                                     ofType:NSSQLiteStoreType]) {
        self.importAlertView =
        [[UIAlertView alloc] initWithTitle:@"Import Default Data?"
                                   message:@"..."
                                  delegate:self
                         cancelButtonTitle:@"cancel"
                         otherButtonTitles:@"Import", nil];
        
        [self.importAlertView show];
    }
}

- (void)importFromXML:(NSURL *)url
{
    FSDebug;
    
    self.parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    self.parser.delegate = self;
    
    NSLog(@"**** START PARSE OF %@", url.path);
    [self.parser parse];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFSSomethingChangedNotification
                                                        object:nil];
    NSLog(@"**** END PARSE OF %@", url.path);
}

- (void)setDefaultDataAsImportedForStore:(NSPersistentStore *)aStore
{
    FSDebug;
    
    NSMutableDictionary *dictionary =
    [NSMutableDictionary dictionaryWithDictionary:[[aStore metadata] copy]];
    
    FSLog(@"__Store Metadata Before changes__ \n %@", dictionary);
    
    [dictionary setObject:@(YES) forKey:kFSCDHDefaultDataImportedKey];
    [self.coordinator setMetadata:dictionary forPersistentStore:aStore];
    
    FSLog(@"__Store Metadata After changes__ \n %@", dictionary);
}

#pragma mark - UIAlertView Delegate

- (void)    alertView:(UIAlertView *)alertView
 clickedButtonAtIndex:(NSInteger)buttonIndex
{
    FSDebug;
    
    if (alertView == self.importAlertView) {
        if (buttonIndex == 1) {
            NSLog(@"Default Data Import Approved by User");
            [_importContext performBlock:^{
                [self importFromXML:[[NSBundle mainBundle] URLForResource:@"DefaultData"
                                                            withExtension:@"xml"]];
            }];
        }
        else {
            NSLog(@"Default Data Import Cancelled by User");
        }
        
        [self setDefaultDataAsImportedForStore:_store];
    }
}

#pragma mark - Unique Attribute Selection

- (NSDictionary *)selectedUniqueAttributes
{
    FSDebug;
    
    NSMutableArray *entities    = [NSMutableArray array];
    NSMutableArray *attributes  = [NSMutableArray array];
    
    [entities addObject:@"Item"];
    [attributes addObject:@"name"];
    
    [entities addObject:@"Unit"];
    [attributes addObject:@"name"];
    
    [entities addObject:@"LocationAtHome"];
    [attributes addObject:@"storedIn"];
    
    [entities addObject:@"LocationAtShop"];
    [attributes addObject:@"aisle"];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:attributes
                                                           forKeys:entities];
    
    return dictionary;
}

#pragma mark - NSXMLParser Delegate

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    FSDebug;
}

- (void)    parser:(NSXMLParser *)parser
   didStartElement:(NSString *)elementName
      namespaceURI:(NSString *)namespaceURI
     qualifiedName:(NSString *)qName
        attributes:(NSDictionary<NSString *,NSString *> *)attributeDict
{
    [self.importContext performBlockAndWait:^{
        if ([elementName isEqualToString:@"item"]) {
            // prepare the Core Data Importer
            FSCoreDataImporter *importer =
            [[FSCoreDataImporter alloc] initWithUniqueAttributes:
             [self selectedUniqueAttributes]];
            
            // insert a unique 'Item' object
            NSManagedObject *item =
            [importer insertBasicObjectInTargetEntity:@"Item"
                                targetEntityAttribute:@"name"
                                   sourceXMLAttribute:@"name"
                                        attributeDict:attributeDict
                                              context:_importContext];
            
            // insert a unique 'Unit' object
            NSManagedObject *unit =
            [importer insertBasicObjectInTargetEntity:@"Unit"
                                targetEntityAttribute:@"name"
                                   sourceXMLAttribute:@"unit"
                                        attributeDict:attributeDict
                                              context:_importContext];
            
            // insert a unique 'LocationAtHome' object
            NSManagedObject *locationAtHome =
            [importer insertBasicObjectInTargetEntity:@"LocationAtHome"
                                targetEntityAttribute:@"storedIn"
                                   sourceXMLAttribute:@"locationathome"
                                        attributeDict:attributeDict
                                              context:_importContext];
            
            // insert a unique 'LocationAtShop' object
            NSManagedObject *locationAtShop =
            [importer insertBasicObjectInTargetEntity:@"LocationAtShop"
                                targetEntityAttribute:@"aisle"
                                   sourceXMLAttribute:@"locationatshop"
                                        attributeDict:attributeDict
                                              context:_importContext];
            
            // Manually add extra attribute values
            [item setValue:@(NO) forKey:@"listed"];
            
            // create relationships
            [item setValue:unit forKey:@"unit"];
            [item setValue:locationAtHome forKey:@"locationAtHome"];
            [item setValue:locationAtShop forKey:@"locationAtShop"];
            
            // save new object to the persistent store
            [FSCoreDataImporter saveContext:_importContext];
            
            // turn objects into faults to save memory
            [_importContext refreshObject:item mergeChanges:NO];
            [_importContext refreshObject:unit mergeChanges:NO];
            [_importContext refreshObject:locationAtHome mergeChanges:NO];
            [_importContext refreshObject:locationAtShop mergeChanges:NO];
        }
    }];
}

@end





































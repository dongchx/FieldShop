//
//  FSCoreDataHelper.h
//  FieldShop
//
//  Created by dongchx on 05/12/2017.
//  Copyright © 2017 dongchx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface FSCoreDataHelper : NSObject

@property (nonatomic, readonly) NSManagedObjectContext          *context;
@property (nonatomic, readonly) NSManagedObjectModel            *model;
@property (nonatomic, readonly) NSPersistentStoreCoordinator    *coordinator;
@property (nonatomic, readonly) NSPersistentStore               *store;

- (void)setupCoreData;
- (void)saveContext;

@end

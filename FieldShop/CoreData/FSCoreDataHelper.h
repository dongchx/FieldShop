//
//  FSCoreDataHelper.h
//  FieldShop
//
//  Created by dongchx on 05/12/2017.
//  Copyright © 2017 dongchx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FSMigrationViewController.h"

@interface FSCoreDataHelper : NSObject
<UIAlertViewDelegate, NSXMLParserDelegate>

@property (nonatomic, readonly) NSManagedObjectContext          *context;
@property (nonatomic, readonly) NSManagedObjectContext          *importContext;
@property (nonatomic, readonly) NSManagedObjectModel            *model;
@property (nonatomic, readonly) NSPersistentStoreCoordinator    *coordinator;
@property (nonatomic, readonly) NSPersistentStore               *store;
@property (nonatomic, strong)   FSMigrationViewController       *migrationVC;
@property (nonatomic, readonly) UIAlertView                     *importAlertView;
@property (nonatomic, strong)   NSXMLParser                     *parser;

- (void)setupCoreData;
- (void)saveContext;

@end

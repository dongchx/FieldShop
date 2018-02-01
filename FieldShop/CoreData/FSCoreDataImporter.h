//
//  FSCoreDataImporter.h
//  FieldShop
//
//  Created by dongchx on 30/01/2018.
//  Copyright © 2018 dongchx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface FSCoreDataImporter : NSObject

@property (nonatomic, strong) NSDictionary *entitiesWithUniqueAttributes;

+ (void)saveContext:(NSManagedObjectContext *)context;
- (instancetype)initWithUniqueAttributes:(NSDictionary *)uniqueAttributes;
- (NSString *)uniqueAttributeForEntity:(NSString *)entity;

- (NSManagedObject *)insertUniqueObjectInTargetEntity:(NSString *)entity
                                 uniqueAttributeValue:(NSString *)uniqueAttributeValue
                                      attributeValues:(NSDictionary *)attributeValues
                                            inContext:(NSManagedObjectContext *)context;

- (NSManagedObject *)insertBasicObjectInTargetEntity:(NSString *)entity
                               targetEntityAttribute:(NSString *)targetentityAttribute
                                  sourceXMLAttribute:(NSString *)sourceXMLAttribute
                                       attributeDict:(NSDictionary *)attributeDict
                                             context:(NSManagedObjectContext *)context;

- (void)deepCopyEntities:(NSArray *)entities
             fromContext:(NSManagedObjectContext *)sourceContext
               toContext:(NSManagedObjectContext *)targetContext;

@end

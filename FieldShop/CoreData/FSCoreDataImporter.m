//
//  FSCoreDataImporter.m
//  FieldShop
//
//  Created by dongchx on 30/01/2018.
//  Copyright © 2018 dongchx. All rights reserved.
//

#import "FSCoreDataImporter.h"

@implementation FSCoreDataImporter

+ (void)saveContext:(NSManagedObjectContext *)context
{
    FSDebug;
    
    [context performBlockAndWait:^{
        if ([context hasChanges]) {
            NSError *error = nil;
            if ([context save:&error]) {
                NSLog(@"FSCoreDataImporter SAVED changes from context to persistent store");
            }
            else {
                NSLog(@"FSCoreDataImporter FAILED to save changes from context to persistent store: %@", error);
            }
        }
        else {
            NSLog(@"FSCoreDataImporter SKIPPED saving context as there are no changes");
        }
    }];
}

- (instancetype)initWithUniqueAttributes:(NSDictionary *)uniqueAttributes
{
    FSDebug;
    
    if (self = [super init]) {
        self.entitiesWithUniqueAttributes = uniqueAttributes;
        
        if (self.entitiesWithUniqueAttributes) {
            return self;
        }
        else {
            FSLog(@"FAILED to initialize FSCoreDataImporter : entutiesWithUniqueAttributes is nil");
        }
    }
    
    return nil;
}

- (NSString *)uniqueAttributeForEntity:(NSString *)entity
{
    FSDebug;
    return [self.entitiesWithUniqueAttributes objectForKey:entity];
}

- (NSManagedObject *)existingObjectInContext:(NSManagedObjectContext *)context
                                   forEntity:(NSString *)entity
                    withUniqueAttributeValue:(NSString *)uniqueAttributeValue
{
    FSDebug;
    
    NSString *uniqueAttribute = [self uniqueAttributeForEntity:entity];
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"%K==%@", uniqueAttribute, uniqueAttributeValue];
    
    NSFetchRequest *fetchRequest =
    [NSFetchRequest fetchRequestWithEntityName:entity];
    fetchRequest.predicate = predicate;
    fetchRequest.fetchLimit = 1;
    
    NSError *error = nil;
    NSArray *fetchRequestResults =
    [context executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        FSLog(@"Error: %@", error.localizedDescription);
    }
    if (fetchRequestResults.count == 0) {
        return nil;
    }
    
    return fetchRequestResults.lastObject;
}

- (NSManagedObject *)insertUniqueObjectInTargetEntity:(NSString *)entity
                                 uniqueAttributeValue:(NSString *)uniqueAttributeValue
                                      attributeValues:(NSDictionary *)attributeValues
                                            inContext:(NSManagedObjectContext *)context
{
    FSDebug;
    
    NSString *uniqueAttribute = [self uniqueAttributeForEntity:entity];
    if (uniqueAttributeValue.length > 0) {
        NSManagedObject *existingObject =
        [self existingObjectInContext:context
                            forEntity:entity
             withUniqueAttributeValue:uniqueAttributeValue];
        if (existingObject) {
            FSLog(@"%@ object with %@ value '%@' already exists",
                  entity, uniqueAttribute, uniqueAttributeValue);
            return existingObject;
        }
        else {
            NSManagedObject *newObject =
            [NSEntityDescription insertNewObjectForEntityForName:entity
                                          inManagedObjectContext:context];
            [newObject setValuesForKeysWithDictionary:attributeValues];
            return newObject;
        }
    }
    else {
        FSLog(@"Skipped %@ object creation : unique attribute value is 0 length", entity);
    }
    
    return nil;
}

- (NSManagedObject *)insertBasicObjectInTargetEntity:(NSString *)entity
                               targetEntityAttribute:(NSString *)targetentityAttribute
                                  sourceXMLAttribute:(NSString *)sourceXMLAttribute
                                       attributeDict:(NSDictionary *)attributeDict
                                             context:(NSManagedObjectContext *)context
{
    NSArray *attributes = [NSArray arrayWithObject:targetentityAttribute];
    NSArray *values =
    [NSArray arrayWithObject:[attributeDict objectForKey:sourceXMLAttribute]];
    
    NSDictionary *attributeValues =
    [NSDictionary dictionaryWithObjects:values forKeys:attributes];
    
    return [self insertUniqueObjectInTargetEntity:entity
                             uniqueAttributeValue:[attributeDict objectForKey:sourceXMLAttribute]
                                  attributeValues:attributeValues
                                        inContext:context];
}

@end






























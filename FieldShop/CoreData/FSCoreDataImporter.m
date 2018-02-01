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

#pragma mark - DEEP COPY

- (NSString *)objectInfo:(NSManagedObject *)object
{
    if (!object) { return nil; }
    
    NSString *entity = object.entity.name;
    NSString *uniqueAttribute = [self uniqueAttributeForEntity:entity];
    NSString *uniqueAttributeValue = [object valueForKey:uniqueAttribute];
    
    return [NSString stringWithFormat:@"%@ '%@'", entity, uniqueAttributeValue];
}

- (NSArray *)arrayForEntity:(NSString *)entity
                  inContext:(NSManagedObjectContext *)context
              withPredicate:(NSPredicate *)predicate
{
    FSDebug;
    
    NSFetchRequest *request =
    [NSFetchRequest fetchRequestWithEntityName:entity];
    [request setFetchBatchSize:50];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error) {
        FSLog(@"ERROR fetching objects: %@", error.localizedDescription);
    }
    
    return array;
}

- (NSManagedObject *)copyUniqueObject:(NSManagedObject *)object
                            toContext:(NSManagedObjectContext *)targetContext
{
    FSDebug;
    
    if (!object || !targetContext) {
        FSLog(@"FAILED to copy %@ to context %@",
              [self objectInfo:object], targetContext);
        return nil;
    }
    
    NSString *entity = object.entity.name;
    NSString *uniqueAttribute = [self uniqueAttributeForEntity:entity];
    NSString *uniqueAttributeValue = [object valueForKey:uniqueAttribute];
    
    if (uniqueAttributeValue.length > 0) {
        NSMutableDictionary *attributeValuesToCopy =
        [NSMutableDictionary dictionary];
        
        for (NSString *attribute in object.entity.attributesByName) {
            [attributeValuesToCopy setValue:[[object valueForKey:attribute] copy]
                                      forKey:attribute];
        }
        
        NSManagedObject *copiedObject =
        [self insertUniqueObjectInTargetEntity:entity
                          uniqueAttributeValue:uniqueAttributeValue
                               attributeValues:attributeValuesToCopy
                                     inContext:targetContext];
        
        return copiedObject;
    }
    
    return nil;
}

- (void)establishToOneRelationship:(NSString *)relationshipName
                        fromObject:(NSManagedObject *)object
                          toObject:(NSManagedObject *)relatedObject
{
    FSDebug;
    
    if (!relationshipName || !object || !relatedObject) {
        FSLog(@"SKIPPED establingsing To-One relationship '%@' between %@ and %@",
              relationshipName,
              [self objectInfo:object],
              [self objectInfo:relatedObject]);
        FSLog(@"Due to missing Info!");
        return;
    }
    
    NSManagedObject *existingRelatedObject =
    [object valueForKey:relationshipName];
    if (existingRelatedObject) {
        return;
    }
    
    NSDictionary *relationships = [object.entity relationshipsByName];
    NSRelationshipDescription *relationship =
    [relationships objectForKey:relationshipName];
    if (![relatedObject.entity isEqual:relationship.destinationEntity]) {
        FSLog(@"%@ is the wrong entity type to relate to %@",
              [self objectInfo:object], [self objectInfo:relatedObject]);
        return;
    }
    
    // establish the relationship
    [object setValue:relatedObject forKey:relationshipName];
    FSLog(@"ESTABLISHED %@ relationship from %@ to %@",
          relationshipName,
          [self objectInfo:object],
          [self objectInfo:relatedObject]);
    
    // remove the relationship from memory after committed to disk
    [FSCoreDataImporter saveContext:relatedObject.managedObjectContext];
    [FSCoreDataImporter saveContext:object.managedObjectContext];
    [object.managedObjectContext refreshObject:object mergeChanges:NO];
    [relatedObject.managedObjectContext refreshObject:object mergeChanges:NO];
}

- (void)establishToManyRelationship:(NSString *)relationshipName
                         fromObject:(NSManagedObject *)object
                      withSourceSet:(NSMutableSet *)sourceSet
{
    if (!object || !sourceSet || !relationshipName) {
        FSLog(@"SKIPPED establishing a To-many relationship from %@",
              [self objectInfo:object]);
        FSLog(@"Due to missing Info!");
        return;
    }
    
    NSMutableSet *copiedSet =
    [object mutableSetValueForKey:relationshipName];
    for (NSManagedObject *relatedObject in sourceSet) {
        NSManagedObject *copiedRelatedObject =
        [self copyUniqueObject:relatedObject toContext:object.managedObjectContext];
        
        if (copiedRelatedObject) {
            [copiedSet addObject:copiedRelatedObject];
            FSLog(@"A copy of %@ is now related via To-Many '%@' relationship to %@",
                  [self objectInfo:object],
                  relationshipName,
                  [self objectInfo:copiedRelatedObject]);
        }
    }
    
    // remove the relationship from memory after committed to disk
    [FSCoreDataImporter saveContext:object.managedObjectContext];
    [object.managedObjectContext refreshObject:object mergeChanges:NO];
}

- (void)establishOrderedToManyRelationship:(NSString *)relationshipName
                                fromObject:(NSManagedObject *)object
                             withSourceSet:(NSMutableOrderedSet *)sourceSet
{
    if (!object || !sourceSet || !relationshipName) {
        FSLog(@"SKIPPED establishing a To-many relationship from %@",
              [self objectInfo:object]);
        FSLog(@"Due to missing Info!");
        return;
    }
    
    NSMutableOrderedSet *copiedSet =
    [object mutableOrderedSetValueForKey:relationshipName];
    for (NSManagedObject *relatedObject in sourceSet) {
        NSManagedObject *copiedRelatedObject =
        [self copyUniqueObject:relatedObject toContext:object.managedObjectContext];
        
        if (copiedRelatedObject) {
            [copiedSet addObject:copiedRelatedObject];
            FSLog(@"A copy of %@ is now related via To-Many '%@' relationship to %@",
                  [self objectInfo:object],
                  relationshipName,
                  [self objectInfo:copiedRelatedObject]);
        }
    }
    
    // remove the relationship from memory after committed to disk
    [FSCoreDataImporter saveContext:object.managedObjectContext];
    [object.managedObjectContext refreshObject:object mergeChanges:NO];
}

- (void)copyRelationshipsFromObject:(NSManagedObject *)sourceObject
                          toContext:(NSManagedObjectContext *)targetContext
{
    FSDebug;
    
    if (!sourceObject || !targetContext) {
        FSLog(@"FAILED to copy relationships frome '%@' to context '%@'",
              [self objectInfo:sourceObject], targetContext);
        return;
    }
    
    // Skip establishing relationships from nil objects
    NSManagedObject *copiedObject =
    [self copyUniqueObject:sourceObject toContext:targetContext];
    if (!copiedObject) {
        return;
    }
    
    // Copy relationships
    NSDictionary *relationships = [sourceObject.entity relationshipsByName];
    for (NSString *relationshipName in relationships) {
        NSRelationshipDescription *relationship =
        [relationships objectForKey:relationshipName];
        if ([sourceObject valueForKey:relationshipName]) {
            if (relationship.isToMany && relationship.isOrdered) {
                // Copy To-Many Ordered
                NSMutableOrderedSet *sourceSet =
                [sourceObject mutableOrderedSetValueForKey:relationshipName];
                [self establishOrderedToManyRelationship:relationshipName
                                              fromObject:copiedObject
                                           withSourceSet:sourceSet];
            }
            else if (relationship.isToMany && !relationship.isOrdered) {
                // Copy To-Many
                NSMutableSet *sourceSet =
                [sourceObject mutableSetValueForKey:relationshipName];
                [self establishToManyRelationship:relationshipName
                                       fromObject:copiedObject
                                    withSourceSet:sourceSet];
            }
            else {
                // Copy To-One
                NSManagedObject *relatedSourceObject =
                [sourceObject valueForKey:relationshipName];
                NSManagedObject *relatedCopiedObject =
                [self copyUniqueObject:relatedSourceObject
                             toContext:targetContext];
                [self establishToOneRelationship:relationshipName
                                      fromObject:copiedObject
                                        toObject:relatedCopiedObject];
            }
        }
    }
}

- (void)deepCopyEntities:(NSArray *)entities
             fromContext:(NSManagedObjectContext *)sourceContext
               toContext:(NSManagedObjectContext *)targetContext
{
    FSDebug;
    
    for (NSString *entity in entities) {
        FSLog(@"COPYIG %@ objects to target context...", entity);
        NSArray *sourceObjects =
        [self arrayForEntity:entity inContext:sourceContext withPredicate:nil];
        
        for (NSManagedObject *sourceObject in sourceObjects) {
            if (sourceObject) {
                @autoreleasepool {
                    [self copyUniqueObject:sourceObject
                                 toContext:targetContext];
                    [self copyRelationshipsFromObject:sourceObject
                                            toContext:targetContext];
                }
            }
        }
    }
}

@end






























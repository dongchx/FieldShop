//
//  FSFaulter.m
//  FieldShop
//
//  Created by dongchx on 06/02/2018.
//  Copyright © 2018 dongchx. All rights reserved.
//

#import "FSFaulter.h"

@implementation FSFaulter

+ (void)faultObjectWithID:(NSManagedObjectID *)objectID
                inContext:(NSManagedObjectContext *)context
{
    if (!objectID || !context) {
        return;
    }
    
    [context performBlockAndWait:^{
        NSManagedObject *object = [context objectWithID:objectID];
        
        if (object.hasChanges) {
            NSError *error = nil;
            if (![context save:&error]) {
                FSLog(@"ERROR saving: %@", error);
            }
        }
        
        if (!object.isFault) {
            FSLog(@"Faulting object %@ in context %@", object.objectID, context);
        }
        else {
            FSLog(@"Skipped faulting an object that is already a fault");
        }
        
        if (context.parentContext) {
            [self faultObjectWithID:objectID inContext:context.parentContext];
        }
    }];
}

@end

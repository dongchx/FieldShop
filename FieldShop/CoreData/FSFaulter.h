//
//  FSFaulter.h
//  FieldShop
//
//  Created by dongchx on 06/02/2018.
//  Copyright © 2018 dongchx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface FSFaulter : NSObject

+ (void)faultObjectWithID:(NSManagedObjectID *)objectID
                inContext:(NSManagedObjectContext *)context;

@end

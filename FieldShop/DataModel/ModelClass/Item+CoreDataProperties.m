//
//  Item+CoreDataProperties.m
//  FieldShop
//
//  Created by dongchx on 06/12/2017.
//  Copyright © 2017 dongchx. All rights reserved.
//

#import "Item+CoreDataProperties.h"

@implementation Item (CoreDataProperties)

+ (NSFetchRequest<Item *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Item"];
}

@dynamic collected;
@dynamic listed;
@dynamic name;
@dynamic photoData;
@dynamic quantity;

@end

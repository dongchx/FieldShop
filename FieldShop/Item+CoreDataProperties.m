//
//  Item+CoreDataProperties.m
//  
//
//  Created by dongchx on 05/02/2018.
//
//

#import "Item+CoreDataProperties.h"

@implementation Item (CoreDataProperties)

+ (NSFetchRequest<Item *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Item"];
}

@dynamic collected;
@dynamic listed;
@dynamic name;
@dynamic quantity;
@dynamic thumbnail;
@dynamic locationAtHome;
@dynamic locationAtShop;
@dynamic unit;
@dynamic photo;

@end

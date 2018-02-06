//
//  Item_Photo+CoreDataProperties.m
//  
//
//  Created by dongchx on 05/02/2018.
//
//

#import "Item_Photo+CoreDataProperties.h"

@implementation Item_Photo (CoreDataProperties)

+ (NSFetchRequest<Item_Photo *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Item_Photo"];
}

@dynamic data;
@dynamic item;

@end

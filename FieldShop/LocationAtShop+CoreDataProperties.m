//
//  LocationAtShop+CoreDataProperties.m
//  
//
//  Created by dongchx on 05/02/2018.
//
//

#import "LocationAtShop+CoreDataProperties.h"

@implementation LocationAtShop (CoreDataProperties)

+ (NSFetchRequest<LocationAtShop *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"LocationAtShop"];
}

@dynamic aisle;
@dynamic items;

@end

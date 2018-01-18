//
//  LocationAtShop+CoreDataProperties.m
//  FieldShop
//
//  Created by dongchx on 18/12/2017.
//  Copyright © 2017 dongchx. All rights reserved.
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

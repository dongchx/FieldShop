//
//  LocationAtHome+CoreDataProperties.m
//  FieldShop
//
//  Created by dongchx on 18/12/2017.
//  Copyright © 2017 dongchx. All rights reserved.
//
//

#import "LocationAtHome+CoreDataProperties.h"

@implementation LocationAtHome (CoreDataProperties)

+ (NSFetchRequest<LocationAtHome *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"LocationAtHome"];
}

@dynamic storedIn;
@dynamic items;

@end

//
//  LocationAtHome+CoreDataProperties.m
//  
//
//  Created by dongchx on 05/02/2018.
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

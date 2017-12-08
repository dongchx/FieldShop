//
//  Measurement+CoreDataProperties.m
//  FieldShop
//
//  Created by dongchx on 07/12/2017.
//  Copyright © 2017 dongchx. All rights reserved.
//

#import "Measurement+CoreDataProperties.h"

@implementation Measurement (CoreDataProperties)

+ (NSFetchRequest<Measurement *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Measurement"];
}

@dynamic abc;

@end

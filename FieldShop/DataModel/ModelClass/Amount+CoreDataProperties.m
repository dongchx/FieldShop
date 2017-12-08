//
//  Amount+CoreDataProperties.m
//  FieldShop
//
//  Created by dongchx on 07/12/2017.
//  Copyright © 2017 dongchx. All rights reserved.
//

#import "Amount+CoreDataProperties.h"

@implementation Amount (CoreDataProperties)

+ (NSFetchRequest<Amount *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Amount"];
}

@dynamic xyz;

@end

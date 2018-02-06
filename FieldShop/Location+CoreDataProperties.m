//
//  Location+CoreDataProperties.m
//  
//
//  Created by dongchx on 05/02/2018.
//
//

#import "Location+CoreDataProperties.h"

@implementation Location (CoreDataProperties)

+ (NSFetchRequest<Location *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Location"];
}

@dynamic summary;

@end

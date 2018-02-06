//
//  Unit+CoreDataProperties.m
//  
//
//  Created by dongchx on 05/02/2018.
//
//

#import "Unit+CoreDataProperties.h"

@implementation Unit (CoreDataProperties)

+ (NSFetchRequest<Unit *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Unit"];
}

@dynamic name;
@dynamic items;

@end

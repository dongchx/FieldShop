//
//  Unit+CoreDataProperties.h
//  
//
//  Created by dongchx on 05/02/2018.
//
//

#import "Unit+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Unit (CoreDataProperties)

+ (NSFetchRequest<Unit *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSSet<Item *> *items;

@end

@interface Unit (CoreDataGeneratedAccessors)

- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSSet<Item *> *)values;
- (void)removeItems:(NSSet<Item *> *)values;

@end

NS_ASSUME_NONNULL_END

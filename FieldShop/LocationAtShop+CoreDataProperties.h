//
//  LocationAtShop+CoreDataProperties.h
//  
//
//  Created by dongchx on 05/02/2018.
//
//

#import "LocationAtShop+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface LocationAtShop (CoreDataProperties)

+ (NSFetchRequest<LocationAtShop *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *aisle;
@property (nullable, nonatomic, retain) NSSet<Item *> *items;

@end

@interface LocationAtShop (CoreDataGeneratedAccessors)

- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSSet<Item *> *)values;
- (void)removeItems:(NSSet<Item *> *)values;

@end

NS_ASSUME_NONNULL_END

//
//  Item+CoreDataProperties.h
//  FieldShop
//
//  Created by dongchx on 18/12/2017.
//  Copyright © 2017 dongchx. All rights reserved.
//
//

#import "Item+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Item (CoreDataProperties)

+ (NSFetchRequest<Item *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *collected;
@property (nullable, nonatomic, copy) NSNumber *listed;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSData *photoData;
@property (nullable, nonatomic, copy) NSNumber *quantity;
@property (nullable, nonatomic, retain) LocationAtHome *locationAtHome;
@property (nullable, nonatomic, retain) LocationAtShop *locationAtShop;
@property (nullable, nonatomic, retain) Unit *unit;

@end

NS_ASSUME_NONNULL_END
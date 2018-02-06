//
//  Item_Photo+CoreDataProperties.h
//  
//
//  Created by dongchx on 05/02/2018.
//
//

#import "Item_Photo+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Item_Photo (CoreDataProperties)

+ (NSFetchRequest<Item_Photo *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *data;
@property (nullable, nonatomic, retain) Item *item;

@end

NS_ASSUME_NONNULL_END

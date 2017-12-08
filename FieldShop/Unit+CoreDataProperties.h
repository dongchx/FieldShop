//
//  Unit+CoreDataProperties.h
//  FieldShop
//
//  Created by dongchx on 08/12/2017.
//  Copyright © 2017 dongchx. All rights reserved.
//
//

#import "Unit+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Unit (CoreDataProperties)

+ (NSFetchRequest<Unit *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END

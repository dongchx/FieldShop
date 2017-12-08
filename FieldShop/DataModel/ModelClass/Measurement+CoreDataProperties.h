//
//  Measurement+CoreDataProperties.h
//  FieldShop
//
//  Created by dongchx on 07/12/2017.
//  Copyright © 2017 dongchx. All rights reserved.
//

#import "Measurement+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Measurement (CoreDataProperties)

+ (NSFetchRequest<Measurement *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *abc;

@end

NS_ASSUME_NONNULL_END

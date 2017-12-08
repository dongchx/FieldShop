//
//  Amount+CoreDataProperties.h
//  FieldShop
//
//  Created by dongchx on 07/12/2017.
//  Copyright © 2017 dongchx. All rights reserved.
//

#import "Amount+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Amount (CoreDataProperties)

+ (NSFetchRequest<Amount *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *xyz;

@end

NS_ASSUME_NONNULL_END

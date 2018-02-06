//
//  Location+CoreDataProperties.h
//  
//
//  Created by dongchx on 05/02/2018.
//
//

#import "Location+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Location (CoreDataProperties)

+ (NSFetchRequest<Location *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *summary;

@end

NS_ASSUME_NONNULL_END

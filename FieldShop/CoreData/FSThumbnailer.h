//
//  FSThumbnailer.h
//  FieldShop
//
//  Created by dongchx on 06/02/2018.
//  Copyright © 2018 dongchx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface FSThumbnailer : NSObject

+ (void)createMissingThumbnailsForEntityName:(NSString*)entityName
                  withThumbnailAttributeName:(NSString*)thumbnailAttributeName
                   withPhotoRelationshipName:(NSString*)photoRelationshipName
                      withPhotoAttributeName:(NSString*)phototAttributeName
                         withSortDescriptors:(NSArray*)sortDescriptors
                           withImportContext:(NSManagedObjectContext*)importContext;

@end

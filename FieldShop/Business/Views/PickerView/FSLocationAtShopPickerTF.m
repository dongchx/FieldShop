//
//  FSLocationAtShopPickerTF.m
//  FieldShop
//
//  Created by dongchx on 29/01/2018.
//  Copyright © 2018 dongchx. All rights reserved.
//

#import "FSLocationAtShopPickerTF.h"
#import "FSCoreDataHelper.h"
#import "AppDelegate.h"
#import "LocationAtShop+CoreDataClass.h"

@implementation FSLocationAtShopPickerTF

- (void)fetch
{
    FSDebug;
    FSCoreDataHelper *cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    NSFetchRequest *request =
    [NSFetchRequest fetchRequestWithEntityName:@"LocationAtShop"];
    NSSortDescriptor *sort =
    [NSSortDescriptor sortDescriptorWithKey:@"aisle" ascending:YES];
    
    [request setSortDescriptors:@[sort]];
    [request setFetchBatchSize:50];
    
    NSError *error = nil;
    self.pickerData = [cdh.context executeFetchRequest:request error:&error];
    
    if (error) {
        FSLog(@"Error populating picker: %@, %@", error, error.localizedDescription);
    }
    
    [self selectDefaultRow];
}

- (void)selectDefaultRow
{
    FSDebug;
    
    if (self.selectedObjectID && self.pickerData.count > 0) {
        FSCoreDataHelper *cdh =
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        LocationAtShop *selectedObject =
        (LocationAtShop *)[cdh.context existingObjectWithID:self.selectedObjectID
                                                      error:nil];
        
        [self.pickerData enumerateObjectsUsingBlock:
         ^(LocationAtShop *locationAtShop, NSUInteger idx, BOOL * _Nonnull stop) {
             if ([locationAtShop.aisle compare:selectedObject.aisle] == NSOrderedSame) {
                 [self.picker selectRow:idx inComponent:0 animated:NO];
                 [self.pickerDelegate selectedObjectID:self.selectedObjectID
                                    changedForPickerTF:self];
                 *stop = YES;
             }
         }];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    FSDebug;
    LocationAtShop *locationAtShop = [self.pickerData objectAtIndex:row];
    return locationAtShop.aisle;
}


@end

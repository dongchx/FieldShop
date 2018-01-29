//
//  FSUnitPickerTF.m
//  FieldShop
//
//  Created by dongchx on 29/01/2018.
//  Copyright © 2018 dongchx. All rights reserved.
//

#import "FSUnitPickerTF.h"
#import "FSCoreDataHelper.h"
#import "AppDelegate.h"
#import "Unit+CoreDataClass.h"

@implementation FSUnitPickerTF

- (void)fetch
{
    FSDebug;
    FSCoreDataHelper *cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    NSFetchRequest *request =
    [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    NSSortDescriptor *sort =
    [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    
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
        Unit *selectedObject =
        (Unit *)[cdh.context existingObjectWithID:self.selectedObjectID
                                            error:nil];
        
        [self.pickerData enumerateObjectsUsingBlock:
         ^(Unit *unit, NSUInteger idx, BOOL * _Nonnull stop) {
             if ([unit.name compare:selectedObject.name] == NSOrderedSame) {
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
    Unit *unit = [self.pickerData objectAtIndex:row];
    return unit.name;
}

@end

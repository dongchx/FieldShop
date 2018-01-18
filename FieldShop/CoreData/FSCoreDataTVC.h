//
//  FSCoreDataTVC.h
//  FieldShop
//
//  Created by dongchx on 18/12/2017.
//  Copyright © 2017 dongchx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCoreDataHelper.h"

@interface FSCoreDataTVC : UITableViewController
<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *frc;
- (void)performFetch;

@end

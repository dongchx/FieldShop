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
<
NSFetchedResultsControllerDelegate,
UISearchBarDelegate,
UISearchDisplayDelegate
//UISearchControllerDelegate,
//UISearchResultsUpdating
>

@property (nonatomic, strong) NSFetchedResultsController *frc;
@property (nonatomic, strong) NSFetchedResultsController *searchFRC;
@property (nonatomic, strong) UISearchDisplayController  *searchDC;
//@property (nonatomic, strong) UISearchController         *searchSC;
//@property (nonatomic, strong) UITableView                *searchTV;

- (NSFetchedResultsController *)frcFromTV:(UITableView *)tableView;
- (UITableView *)TVFromFRC:(NSFetchedResultsController *)frc;
- (void)performFetch;

- (void)configureSearch;
- (void)reloadSearchFRCForPredicate:(NSPredicate *)predicate
                         withEntity:(NSString *)entity
                          inContext:(NSManagedObjectContext *)context
                withSortDescriptors:(NSArray *)sortDescriptors
             withSectionNameKeyPath:(NSString *)sectionNameKeyPath;

@end

//
//  FSCoreDataTVC.m
//  FieldShop
//
//  Created by dongchx on 18/12/2017.
//  Copyright © 2017 dongchx. All rights reserved.
//

#import "FSCoreDataTVC.h"

@interface FSCoreDataTVC ()

@end

@implementation FSCoreDataTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - FETCHING

- (void)performFetch
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    if (self.frc) {
        [self.frc.managedObjectContext performBlock:^{
            NSError *error = nil;
            if (![self.frc performFetch:&error]) {
                FSLog(@"Failed to perform fetch: %@", error);
            }
            [self.tableView reloadData];
        }];
    }
    else {
        FSLog(@"Failed to fetch, the fetched results controller is nil.");
    }
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    FSDebug;
    return [[[self frcFromTV:tableView] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    FSDebug;
    return [[[self frcFromTV:tableView].sections objectAtIndex:section] numberOfObjects];

}

- (NSInteger)       tableView:(UITableView *)tableView
  sectionForSectionIndexTitle:(NSString *)title
                      atIndex:(NSInteger)index
{
    FSDebug;
    return [[self frcFromTV:tableView] sectionForSectionIndexTitle:title atIndex:index];
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    FSDebug;
    return [[[self frcFromTV:tableView].sections objectAtIndex:section] name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    FSDebug;
    return [[self frcFromTV:tableView] sectionIndexTitles];
}

#pragma mark - DELEGATE : NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    FSDebug;
    [[self TVFromFRC:controller] beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    FSDebug;
    [[self TVFromFRC:controller] endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    FSDebug;
    
    UITableView *tableView = [self TVFromFRC:controller];
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                     withRowAnimation:UITableViewRowAnimationNone];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                     withRowAnimation:UITableViewRowAnimationNone];
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    FSDebug;
    
    UITableView *tableView = [self TVFromFRC:controller];
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationNone];
            
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationNone];
            break;
        
        case NSFetchedResultsChangeUpdate:
            if (!newIndexPath) {
                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                 withRowAnimation:UITableViewRowAnimationNone];
            }
            else {
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                 withRowAnimation:UITableViewRowAnimationNone];
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                 withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationNone];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationNone];
        
        default:
            break;
    }
}

#pragma mark - GENERAL

- (NSFetchedResultsController *)frcFromTV:(UITableView *)tableView
{
    return (tableView == self.tableView) ? self.frc : self.searchFRC;
}

- (UITableView *)TVFromFRC:(NSFetchedResultsController *)frc
{
    return (frc == self.frc) ? self.tableView : self.searchDC.searchResultsTableView;
}

#pragma mark - UISearchControllerDelegate

- (void)didDismissSearchController:(UISearchController *)searchController
{
    FSDebug;
    self.searchFRC.delegate = nil;
    self.searchFRC = nil;
}

#pragma mark - SEARCH

- (void)reloadSearchFRCForPredicate:(NSPredicate *)predicate
                         withEntity:(NSString *)entity
                          inContext:(NSManagedObjectContext *)context
                withSortDescriptors:(NSArray *)sortDescriptors
             withSectionNameKeyPath:(NSString *)sectionNameKeyPath
{
    FSDebug;
    NSFetchRequest *request =
    [[NSFetchRequest alloc] initWithEntityName:entity];
    request.sortDescriptors = sortDescriptors;
    request.predicate = predicate;
    request.fetchBatchSize = 15;
    self.searchFRC =
    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                        managedObjectContext:context
                                          sectionNameKeyPath:sectionNameKeyPath
                                                   cacheName:nil];
    self.searchFRC.delegate = self;
    
    [self.searchFRC.managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        if (![self.searchFRC performFetch:&error]) {
            FSLog(@"SEARCH FETCH ERROR: %@", error);
        }
    }];
}

- (void)configureSearch
{
    FSDebug;
    UISearchBar *searchBar =
    [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44.)];
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.tableView.tableHeaderView = searchBar;
    
    self.searchDC =
    [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    
    self.searchDC.delegate = self;
    self.searchDC.searchResultsDelegate = self;
    self.searchDC.searchResultsDataSource = self;
}

@end


























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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    return self.frc.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    return [[self.frc.sections objectAtIndex:section] numberOfObjects];
}

- (NSInteger)       tableView:(UITableView *)tableView
  sectionForSectionIndexTitle:(NSString *)title
                      atIndex:(NSInteger)index
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    return [self.frc sectionForSectionIndexTitle:title atIndex:index];
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    return [[self.frc.sections objectAtIndex:section] name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    return self.frc.sections;
}

#pragma mark - DELEGATE : NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationNone];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
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
    FSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    UITableView *tableView = self.tableView;
    
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

@end

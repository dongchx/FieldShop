//
//  FSUnitTVC.m
//  FieldShop
//
//  Created by dongchx on 24/01/2018.
//  Copyright © 2018 dongchx. All rights reserved.
//

#import "FSUnitTVC.h"
#import "AppDelegate.h"
#import "Unit+CoreDataClass.h"
#import "FSUnitVC.h"

@interface FSUnitTVC ()

@end

@implementation FSUnitTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self congigureFetch];
    [self performFetch];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(performFetch)
                                                 name:kFSSomethingChangedNotification
                                               object:nil];
    
    [self setupNavigationBar];
}

- (void)setupNavigationBar
{
    UIBarButtonItem *leftButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(done:)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    UIBarButtonItem *rightButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                  target:self
                                                  action:@selector(add:)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

#pragma mark - data

- (void)congigureFetch
{
    FSDebug;
    
    FSCoreDataHelper *cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    
    NSFetchRequest *request =
    [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    request.sortDescriptors  =
    [NSArray arrayWithObjects:
     [NSSortDescriptor sortDescriptorWithKey:@"name"
                                   ascending:YES],
     nil];
    [request setFetchBatchSize:50];
    self.frc =
    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                        managedObjectContext:cdh.context
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.frc.delegate = self;
}

#pragma mark - UITableViewDataDource

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSDebug;
    
    static NSString *cellReuseId = @"FSUnitTVCCell";
    
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:cellReuseId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellReuseId];
    }
    
    Unit *unit = [self.frc objectAtIndexPath:indexPath];
    cell.textLabel.text = unit.name;
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    FSDebug;
    return nil;
}

#pragma mark - UITableViewDlegate

- (void)    tableView:(UITableView *)tableView
   commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
    forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Unit *deleteTarget = [self.frc objectAtIndexPath:indexPath];
        [self.frc.managedObjectContext deleteObject:deleteTarget];
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)        tableView:(UITableView *)tableView
  didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSDebug;
    
    FSUnitVC *unitVC = [[FSUnitVC alloc] init];
    
    FSCoreDataHelper *cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    [cdh saveContext];
    
    unitVC.selectedObjectID =
    [[self.frc objectAtIndexPath:indexPath] objectID];
    
    [self.navigationController pushViewController:unitVC animated:YES];
}

#pragma mark - interaction

- (void)done:(id)sender
{
    FSDebug;
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)add:(id)sender
{
    FSDebug;
    
    FSUnitVC *unitVC = [[FSUnitVC alloc] init];
    
    FSCoreDataHelper *cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    [cdh saveContext];
    
    Unit *newUnit =
    [NSEntityDescription insertNewObjectForEntityForName:@"Unit"
                                  inManagedObjectContext:cdh.context];
    
    NSError *error = nil;
    if (![cdh.context obtainPermanentIDsForObjects:@[newUnit]
                                             error:&error]) {
        FSLog(@"Could't obtain a permanent ID for object %@", error);
    }
    
    unitVC.selectedObjectID = newUnit.objectID;
    
    [self.navigationController pushViewController:unitVC animated:YES];
}

@end










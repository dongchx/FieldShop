//
//  FSLocationsAtHomeTVC.m
//  FieldShop
//
//  Created by dongchx on 25/01/2018.
//  Copyright © 2018 dongchx. All rights reserved.
//

#import "FSLocationsAtHomeTVC.h"
#import "AppDelegate.h"
#import "LocationAtHome+CoreDataClass.h"
#import "FSLocationAtHomeVC.h"

@interface FSLocationsAtHomeTVC ()

@end

@implementation FSLocationsAtHomeTVC

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
    [NSFetchRequest fetchRequestWithEntityName:@"LocationAtHome"];
    request.sortDescriptors  =
    [NSArray arrayWithObjects:
     [NSSortDescriptor sortDescriptorWithKey:@"storedIn"
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
    
    static NSString *cellReuseId = @"FSLocationAtHomeTVCCell";
    
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:cellReuseId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellReuseId];
    }
    
    LocationAtHome *locationAtHome = [self.frc objectAtIndexPath:indexPath];
    cell.textLabel.text = locationAtHome.storedIn;
    
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
        LocationAtHome *deleteTarget = [self.frc objectAtIndexPath:indexPath];
        [self.frc.managedObjectContext deleteObject:deleteTarget];
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)        tableView:(UITableView *)tableView
  didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSDebug;
    
    FSLocationAtHomeVC *homeVC = [[FSLocationAtHomeVC alloc] init];
    
    FSCoreDataHelper *cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    [cdh saveContext];
    
    homeVC.selectedObjectID =
    [[self.frc objectAtIndexPath:indexPath] objectID];
    
    [self.navigationController pushViewController:homeVC animated:YES];
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
    
    FSLocationAtHomeVC *homeVC = [[FSLocationAtHomeVC alloc] init];
    
    FSCoreDataHelper *cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    [cdh saveContext];
    
    LocationAtHome *newLocationAtHome =
    [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtHome"
                                  inManagedObjectContext:cdh.context];
    
    NSError *error = nil;
    if (![cdh.context obtainPermanentIDsForObjects:@[newLocationAtHome]
                                             error:&error]) {
        FSLog(@"Could't obtain a permanent ID for object %@", error);
    }
    
    homeVC.selectedObjectID = newLocationAtHome.objectID;
    
    [self.navigationController pushViewController:homeVC animated:YES];
}


@end

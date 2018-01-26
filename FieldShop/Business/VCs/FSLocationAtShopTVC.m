//
//  FSLocationAtShopTVC.m
//  FieldShop
//
//  Created by dongchx on 25/01/2018.
//  Copyright © 2018 dongchx. All rights reserved.
//

#import "FSLocationAtShopTVC.h"
#import "AppDelegate.h"
#import "LocationAtShop+CoreDataClass.h"
#import "FSLocationAtShopVC.h"

@interface FSLocationAtShopTVC ()

@end

@implementation FSLocationAtShopTVC

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
    [NSFetchRequest fetchRequestWithEntityName:@"LocationAtShop"];
    request.sortDescriptors  =
    [NSArray arrayWithObjects:
     [NSSortDescriptor sortDescriptorWithKey:@"aisle"
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
    
    static NSString *cellReuseId = @"FSLocationAtShopTVCCell";
    
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:cellReuseId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellReuseId];
    }
    
    LocationAtShop *locationAtShop = [self.frc objectAtIndexPath:indexPath];
    cell.textLabel.text = locationAtShop.aisle;
    
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
        
        LocationAtShop *deleteTarget =
        [self.frc objectAtIndexPath:indexPath];
        [self.frc.managedObjectContext deleteObject:deleteTarget];
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)        tableView:(UITableView *)tableView
  didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSDebug;
    
    FSLocationAtShopVC *shopVC = [[FSLocationAtShopVC alloc] init];
    
    FSCoreDataHelper *cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    [cdh saveContext];
    
    shopVC.selectedObjectID =
    [[self.frc objectAtIndexPath:indexPath] objectID];
    
    [self.navigationController pushViewController:shopVC animated:YES];
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
    
    FSLocationAtShopVC *shopVC = [[FSLocationAtShopVC alloc] init];
    
    FSCoreDataHelper *cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    [cdh saveContext];
    
    LocationAtShop *newLocationAtShop =
    [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtShop"
                                  inManagedObjectContext:cdh.context];
    
    NSError *error = nil;
    if (![cdh.context obtainPermanentIDsForObjects:@[newLocationAtShop]
                                             error:&error]) {
        FSLog(@"Could't obtain a permanent ID for object %@", error);
    }
    
    shopVC.selectedObjectID = newLocationAtShop.objectID;
    
    [self.navigationController pushViewController:shopVC animated:YES];
}

@end

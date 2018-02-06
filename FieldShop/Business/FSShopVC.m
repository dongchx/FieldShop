//
//  FSShopVC.m
//  FieldShop
//
//  Created by dongchx on 18/01/2018.
//  Copyright © 2018 dongchx. All rights reserved.
//

#import "FSShopVC.h"
#import "FSCoreDataHelper.h"
#import "Item+CoreDataClass.h"
#import "Unit+CoreDataClass.h"
#import "AppDelegate.h"
#import "FSItemVC.h"

@interface FSShopVC ()

@end

@implementation FSShopVC

- (void)viewDidLoad
{
    FSDebug;
    [super viewDidLoad];
    
    self.title = @"Shop";
    
    [self configureFetch];
    [self performFetch];
    
    [self setupSubviews:self.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(performFetch)
                                                 name:kFSSomethingChangedNotification
                                               object:nil];
}

#pragma mark - subviews

- (void)setupSubviews:(UIView *)parentView
{
    FSDebug;
    UIBarButtonItem *barButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Clear"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(clear:)];
    self.navigationItem.leftBarButtonItem = barButton;
}

#pragma mark - interaction

- (void)clear:(id)sender
{
    FSDebug;
    if (self.frc.fetchedObjects.count == 0) {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"Nothing to Clear"
                                   message:@"Add items using the Prepare tab"
                                  delegate:nil
                         cancelButtonTitle:@"Ok"
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    BOOL nothingCleared = YES;
    for (Item *item in self.frc.fetchedObjects) {
        if (item.collected.boolValue) {
            item.listed = @NO;
            item.collected = @NO;
            nothingCleared = NO;
        }
    }
    
    if (nothingCleared) {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:nil
                                   message:@"Select items to be removed from the list before pressing Clear"
                                  delegate:nil
                         cancelButtonTitle:@"Ok"
                         otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - data

- (void)configureFetch
{
    FSDebug;
    FSCoreDataHelper *cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    NSFetchRequest *request =
    [[cdh.model fetchRequestTemplateForName:@"ShoppingList"] copy];
    
    request.sortDescriptors =
    [NSArray arrayWithObjects:
     [NSSortDescriptor sortDescriptorWithKey:@"locationAtShop.aisle" ascending:YES],
     [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],
     nil];
    [request setFetchBatchSize:50];
    
    self.frc =
    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                        managedObjectContext:cdh.context
                                          sectionNameKeyPath:@"locationAtShop.aisle"
                                                   cacheName:nil];
    self.frc.delegate = self;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSDebug;
    static NSString *cellReuseId = @"FSShopVCCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellReuseId];
    }
    
    Item *item = [self.frc objectAtIndexPath:indexPath];
    NSMutableString *title =
    [NSMutableString stringWithFormat:@"%@%@ %@", item.quantity,item.unit.name,item.name];
    
    [title replaceOccurrencesOfString:@"(null)"
                           withString:@""
                              options:0
                                range:NSMakeRange(0, title.length)];
    
    cell.textLabel.text = title;
    
    // make collected items green
    if (item.collected.boolValue) {
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.textColor = [UIColor colorWithRed:.36
                                                   green:.74
                                                    blue:.34
                                                   alpha:1.];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.textLabel.textColor = [UIColor orangeColor];
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    }
    
    cell.imageView.image = [UIImage imageWithData:item.thumbnail];
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    FSDebug;
    return nil;
}

- (void)        tableView:(UITableView *)tableView
  didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSDebug;
    Item *item = [self.frc objectAtIndexPath:indexPath];
    if (item.collected.boolValue) {
        item.collected = @NO;
    }
    else {
        item.collected = @YES;
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationNone];
}

- (void)                       tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    FSDebug;
    
    FSItemVC *itemVC = [[FSItemVC alloc] init];
    itemVC.selectedItemID = [[self.frc objectAtIndexPath:indexPath] objectID];
    itemVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:itemVC animated:YES];
}

@end























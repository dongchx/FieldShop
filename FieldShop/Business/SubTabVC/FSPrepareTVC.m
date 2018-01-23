//
//  FSPrepareTVC.m
//  FieldShop
//
//  Created by dongchx on 18/01/2018.
//  Copyright © 2018 dongchx. All rights reserved.
//

#import "FSPrepareTVC.h"
#import "FSCoreDataHelper.h"
#import "Item+CoreDataProperties.h"
#import "Unit+CoreDataProperties.h"
#import "AppDelegate.h"
#import "FSItemVC.h"

@interface FSPrepareTVC ()

@end

@implementation FSPrepareTVC

- (void)viewDidLoad
{
    FSDebug;
    [super viewDidLoad];
    
    self.title = @"Items";
    
    [self congigureFetch];
    [self performFetch];
    self.clearconfirmActionSheet.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(performFetch)
                                                 name:@"FSSomethingChanged"
                                               object:nil];
    
    [self setupSubviews:self.view];
}

#pragma mark - subviews

- (void)setupSubviews:(UIView *)parentView
{
    FSDebug;
    UIBarButtonItem *leftButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Clear"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(clear:)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    UIBarButtonItem *rightButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                  target:self
                                                  action:nil];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}

#pragma mark - data

- (void)congigureFetch
{
    FSDebug;
    
    FSCoreDataHelper *cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    
    NSFetchRequest *request =
    [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    request.sortDescriptors  =
    [NSArray arrayWithObjects:
        [NSSortDescriptor sortDescriptorWithKey:@"locationAtHome.storedIn"
                                      ascending:YES],
        [NSSortDescriptor sortDescriptorWithKey:@"name"
                                      ascending:YES],
        nil];
    [request setFetchBatchSize:50];
    self.frc =
    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                        managedObjectContext:cdh.context
                                          sectionNameKeyPath:@"locationAtHome.storedIn"
                                                   cacheName:nil];
    self.frc.delegate = self;
}

#pragma mark - interaction

- (void)clear:(id)sender
{
    FSDebug;
    
    FSCoreDataHelper *cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    
    NSFetchRequest *request =
    [cdh.model fetchRequestTemplateForName:@"ShoppingList"];
    NSArray *shoppingList =
    [cdh.context executeFetchRequest:request error:nil];
    
    if (shoppingList.count > 0) {
        self.clearconfirmActionSheet =
        [[UIActionSheet alloc] initWithTitle:@"Clear Entire Shopping List?"
                                    delegate:self
                           cancelButtonTitle:@"Cancel"
                      destructiveButtonTitle:@"Clear"
                           otherButtonTitles:nil];
        [self.clearconfirmActionSheet
         showFromTabBar:self.navigationController.tabBarController.tabBar];
    }
    else {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"Nothing to Clear"
                                   message:@"..."
                                  delegate:nil
                         cancelButtonTitle:@"Ok"
                         otherButtonTitles:nil];
        [alert show];
    }
}

- (void)    actionSheet:(UIActionSheet *)actionSheet
   clickedButtonAtIndex:(NSInteger)buttonIndex
{
    FSDebug;
    if (actionSheet == self.clearconfirmActionSheet) {
        if (buttonIndex == [actionSheet destructiveButtonIndex]) {
            
        }
        else if (buttonIndex == [actionSheet cancelButtonIndex]) {
            [actionSheet dismissWithClickedButtonIndex:[actionSheet cancelButtonIndex]
                                              animated:YES];
        }
    }
}

- (void)clearList
{
    FSDebug;
    FSCoreDataHelper *cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    
    NSFetchRequest *request =
    [cdh.model fetchRequestTemplateForName:@"ShoppingList"];
    NSArray *shoppingList =
    [cdh.context executeFetchRequest:request error:nil];
    
    for (Item *item in shoppingList) {
        item.listed = @NO;
    }
}

#pragma mark - tableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSDebug;
    
    static NSString *cellReuseId = @"FSPrepareVCItemCell";
    
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:cellReuseId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellReuseId];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    Item *item = [self.frc objectAtIndexPath:indexPath];
    NSMutableString *title =
    [NSMutableString stringWithFormat:@"%@%@ %@", item.quantity,item.unit.name,item.name];
    
    [title replaceOccurrencesOfString:@"(null)"
                           withString:@""
                              options:0
                                range:NSMakeRange(0, title.length)];
    
    cell.textLabel.text = title;
    
    // make selected items orange
    if (item.listed.boolValue) {
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.textLabel.textColor = [UIColor orangeColor];
    }
    else {
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.textColor = [UIColor grayColor];
    }
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    FSDebug;
    return nil;
}

#pragma mark - UITableView Delegate

- (void)    tableView:(UITableView *)tableView
   commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
    forRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSDebug;
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Item *deleteTarget = [self.frc objectAtIndexPath:indexPath];
        [self.frc.managedObjectContext deleteObject:deleteTarget];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)        tableView:(UITableView *)tableView
  didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSDebug;
    
    NSManagedObjectID *itemId = [[self.frc objectAtIndexPath:indexPath] objectID];
    Item *item =
    (Item *)[self.frc.managedObjectContext existingObjectWithID:itemId
                                                          error:nil];
    
    if (item.listed.boolValue) {
        item.listed = @NO;
    }
    else {
        item.listed = @YES;
        item.collected = @NO;
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
    
    [self.navigationController pushViewController:itemVC animated:YES];
}

@end











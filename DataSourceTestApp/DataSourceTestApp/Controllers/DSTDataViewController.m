//
//  DSTDataViewController.m
//  DataSourceTestApp
//
//  Created by Joachim Kret on 26/06/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "DSTDataViewController.h"

#import "DSTFetchedDataSourceController.h"
#import "DSTTableViewCell.h"

#pragma mark - DSTDataViewController

@interface DSTDataViewController ()

- (IBAction)addAction:(id)sender;

@end

#pragma mark -

@implementation DSTDataViewController

#pragma mark Init

- (void)finishInitialize {
    [super finishInitialize];
    
    NSManagedObjectContext * context = [[DSTCoreDataStore sharedInstance] mainContext];
    NSFetchRequest * fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [NSEntityDescription entityForName:@"EventEntity" inManagedObjectContext:context];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];
    fetchRequest.predicate = nil;
    fetchRequest.fetchBatchSize = 10;
    fetchRequest.returnsObjectsAsFaults = NO;
    
    DSTFetchedDataSourceController * dataSourceController = [[DSTFetchedDataSourceController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    dataSourceController.delegate = self;
    self.dataSourceController = dataSourceController;
}

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.appearsFirstTime) {
        [self.dataSourceController performFetch:nil];
    }
    
    [super viewWillAppear:animated];
}

#pragma mark Actions

- (IBAction)addAction:(id)sender {
    [(DSTFetchedDataSourceController *)self.dataSourceController createObject];
}

#pragma mark UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [DSTTableViewCell cellForTableView:tableView];
    
    DSTEventEntity * event = (DSTEventEntity *)[self.dataSourceController objectAtIndexPath:indexPath];
    cell.textLabel.text = event.timestamp.description;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSourceController numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSourceController numberOfRowsInSection:section];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UITableViewCellEditingStyleDelete == editingStyle) {
        id anObject = [self.dataSourceController objectAtIndexPath:indexPath];

        if (anObject) {
            [(DSTFetchedDataSourceController *)self.dataSourceController deleteObject:anObject];
        }
    }
}

#pragma mark DSTDataSourceControllerDelegate

- (void)dataSourceControllerWillChangeContent:(id <DSTDataSourceControllerProtocol>)dataSourceController {
    [self.tableView beginUpdates];
}

- (void)dataSourceController:(id <DSTDataSourceControllerProtocol>)dataSourceController didChangeSectionAtIndex:(NSInteger)sectionIndex forChangeType:(DSTDataSourceChangeType)type {

    switch (type) {
        case DSTDataSourceChangeInsert: {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:(self.isViewVisible) ? UITableViewRowAnimationFade : UITableViewRowAnimationAutomatic];
            break;
        }
        case DSTDataSourceChangeDelete: {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:(self.isViewVisible) ? UITableViewRowAnimationFade : UITableViewRowAnimationAutomatic];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)dataSourceController:(id <DSTDataSourceControllerProtocol>)dataSourceController didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(DSTDataSourceChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {

    switch (type) {
        case DSTDataSourceChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:(self.isViewVisible) ? UITableViewRowAnimationFade : UITableViewRowAnimationAutomatic];
            break;
        }
        case DSTDataSourceChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation: (self.isViewVisible) ? UITableViewRowAnimationFade : UITableViewRowAnimationAutomatic];
            break;
        }
        case DSTDataSourceChangeUpdate: {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(self.isViewVisible) ? UITableViewRowAnimationNone : UITableViewRowAnimationAutomatic];
            break;
        }
        case DSTDataSourceChangeMove: {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(self.isViewVisible) ? UITableViewRowAnimationFade : UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:(self.isViewVisible) ? UITableViewRowAnimationFade : UITableViewRowAnimationAutomatic];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)dataSourceControllerDidChangeContent:(id <DSTDataSourceControllerProtocol>)dataSourceController {
    [self.tableView endUpdates];
}

@end

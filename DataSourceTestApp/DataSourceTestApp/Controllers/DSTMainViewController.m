//
//  DSTMainViewController.m
//  DataSourceTestApp
//
//  Created by Joachim Kret on 26/06/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "DSTMainViewController.h"

#import "DSTTableViewCell.h"
#import "DSTDataViewController.h"

typedef enum {
    DSTMainSectionBase  = 0,
    DSTMainSectionCount
} DSTMainSection;

typedef enum {
    DSTMainRowSimple    = 0,
    DSTMainRowCount
} DSTMainRow;

#pragma mark - DSTMainViewController

@interface DSTMainViewController ()

@end

#pragma mark -

@implementation DSTMainViewController

- (void)finishInitialize {
    [super finishInitialize];
    
    self.title = @"Data Source";
}

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
}

#pragma mark UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case DSTMainRowSimple: {
            [self.navigationController pushViewController:[DSTDataViewController new] animated:YES];
            break;
        }
        default: {
            break;
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [DSTTableViewCell cellForTableView:tableView];
    
    switch (indexPath.row) {
        case DSTMainRowSimple: {
            cell.textLabel.text = @"Fetched Data Source";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        default: {
            break;
        }
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return DSTMainSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return DSTMainRowCount;
}

@end

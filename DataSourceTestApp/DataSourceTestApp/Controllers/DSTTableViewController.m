//
//  DSTTableViewController.m
//  DataSourceTestApp
//
//  Created by Joachim Kret on 26/06/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "DSTTableViewController.h"

#pragma mark - DSTTableViewController

@interface DSTTableViewController () {
    BOOL _needsReload;
}

@end

#pragma mark -

@implementation DSTTableViewController

@synthesize tableView = _tableView;
@synthesize clearsSelectionOnViewWillAppear = _clearsSelectionOnViewWillAppear;
@synthesize clearsSelectionOnReloadData = _clearsSelectionOnReloadData;
@synthesize reloadOnAppearsFirstTime = _reloadOnAppearsFirstTime;
@dynamic empty;

+ (UITableViewStyle)defaultTableViewStyle {
    return UITableViewStylePlain;
}

+ (Class)defaultTableViewClass {
    return [UITableView class];
}

#pragma mark Init

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [self initWithNibName:nil bundle:nil]) {
        self.tableView = [[[[self class] defaultTableViewClass] alloc] initWithFrame:CGRectZero style:style];
    }
    return self;
}

- (void)finishInitialize {
    [super finishInitialize];
    
    _needsReload = NO;
    _reloadOnAppearsFirstTime = YES;
    _clearsSelectionOnViewWillAppear = YES;
    _clearsSelectionOnReloadData = NO;
}

#pragma mark View

- (void)loadView {
    [super loadView];
    
    if (!self.isViewLoaded) {
        self.view = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    if (!_tableView) {
        self.tableView = [[[[self class] defaultTableViewClass] alloc] initWithFrame:self.view.bounds style:[[self class] defaultTableViewStyle]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.appearsFirstTime && self.reloadOnAppearsFirstTime) {
        [self reloadData];
    }
    else {
        [self reloadIfNeeded];
    }
    
    if (self.clearsSelectionOnViewWillAppear) {
        for (NSIndexPath * indexPath in [[self.tableView indexPathsForSelectedRows] copy]) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
        }
    }
}

#pragma mark Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

#pragma mark Accessors

- (void)setTableView:(UITableView *)tableView {
    if (tableView != _tableView) {
        if (_tableView) {
            [_tableView removeFromSuperview];
            _tableView.delegate = nil;
            _tableView.dataSource = nil;
        }
        
        _tableView = tableView;
        
        if (tableView) {
            if (!tableView.delegate) {
                tableView.delegate = self;
            }
            
            if (!tableView.dataSource) {
                tableView.dataSource = self;
            }
            
            if (!tableView.superview) {
                tableView.frame = self.view.bounds;
                tableView.translatesAutoresizingMaskIntoConstraints = NO;
                [self.view addSubview:tableView];
                
                NSDictionary * views = @{@"tableView"   : tableView};
                [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:nil views:views]];
                [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView]|" options:0 metrics:nil views:views]];
            }
        }
    }
}

#pragma mark Reload Data

- (void)setNeedsReload {
    _needsReload = YES;
}

- (BOOL)needsReload {
    return _needsReload;
}

- (void)reloadIfNeeded {
    if (self.needsReload) {
        [self reloadData];
    }
}

- (void)reloadIfVisible {
    if (self.isViewVisible) {
        [self reloadData];
    }
    else {
        [self setNeedsReload];
    }
}

- (void)reloadData {
    _needsReload = NO;
    
    if (self.clearsSelectionOnReloadData) {
        [self.tableView reloadData];
    }
    else {
        NSArray * selectedItems = [[self.tableView indexPathsForSelectedRows] copy];
        
        [self.tableView reloadData];
        
        for (NSIndexPath * indexPath in selectedItems) {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    METHOD_NOT_IMPLEMENTED;
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end

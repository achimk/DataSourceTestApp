//
//  DSTTableViewController.h
//  DataSourceTestApp
//
//  Created by Joachim Kret on 26/06/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "DSTViewController.h"

@interface DSTTableViewController : DSTViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, readwrite, strong) IBOutlet UITableView * tableView;
@property (nonatomic, readwrite, assign) BOOL clearsSelectionOnViewWillAppear;
@property (nonatomic, readwrite, assign) BOOL clearsSelectionOnReloadData;
@property (nonatomic, readwrite, assign) BOOL reloadOnAppearsFirstTime;
@property (nonatomic, readonly, assign, getter = isEmpty) BOOL empty;

- (id)initWithStyle:(UITableViewStyle)style;

- (void)setNeedsReload;
- (BOOL)needsReload;

- (void)reloadIfNeeded;
- (void)reloadIfVisible;
- (void)reloadData;

@end

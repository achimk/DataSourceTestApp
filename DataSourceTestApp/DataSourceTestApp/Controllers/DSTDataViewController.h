//
//  DSTDataViewController.h
//  DataSourceTestApp
//
//  Created by Joachim Kret on 26/06/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "DSTTableViewController.h"

#import "DSTDataSourceControllerProtocol.h"

@interface DSTDataViewController : DSTTableViewController <DSTDataSourceControllerDelegate>

@property (nonatomic, readwrite, strong) id <DSTDataSourceControllerProtocol> dataSourceController;

@end

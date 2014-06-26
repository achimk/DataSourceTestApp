//
//  DSTDataSourceControllerProtocol.h
//  DataSourceTestApp
//
//  Created by Joachim Kret on 26/06/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    DSTDataSourceChangeInsert   = NSFetchedResultsChangeInsert,
    DSTDataSourceChangeDelete   = NSFetchedResultsChangeDelete,
    DSTDataSourceChangeMove     = NSFetchedResultsChangeMove,
    DSTDataSourceChangeUpdate   = NSFetchedResultsChangeUpdate
} DSTDataSourceChangeType;

@protocol DSTDataSourceControllerProtocol <NSObject>

@required
- (BOOL)performFetch:(NSError **)error;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject:(id)object;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;

@end

@protocol DSTDataSourceControllerDelegate <NSObject>

@optional
- (void)dataSourceControllerWillChangeContent:(id <DSTDataSourceControllerProtocol>)dataSourceController;

- (void)dataSourceController:(id <DSTDataSourceControllerProtocol>)dataSourceController didChangeSectionAtIndex:(NSInteger)sectionIndex forChangeType:(DSTDataSourceChangeType)type;

- (void)dataSourceController:(id <DSTDataSourceControllerProtocol>)dataSourceController didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(DSTDataSourceChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;

- (void)dataSourceControllerDidChangeContent:(id <DSTDataSourceControllerProtocol>)dataSourceController;

@end

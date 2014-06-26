//
//  DSTFetchedDataSourceController.m
//  DataSourceTestApp
//
//  Created by Joachim Kret on 26/06/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "DSTFetchedDataSourceController.h"

#pragma mark - DSTFetchedDataSourceController

@interface DSTFetchedDataSourceController () <NSFetchedResultsControllerDelegate>

@end

#pragma mark -

@implementation DSTFetchedDataSourceController

#pragma mark Init

- (id)init {
    METHOD_USE_DESIGNATED_INIT;
    return nil;
}

- (id)initWithFetchRequest:(NSFetchRequest *)fetchRequest
      managedObjectContext:(NSManagedObjectContext *)context
        sectionNameKeyPath:(NSString *)sectionNameKeyPath
                 cacheName:(NSString *)name {
    if (self = [super init]) {
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:sectionNameKeyPath
                                                                                   cacheName:name];
        _fetchedResultsController.delegate = self;
    }
    
    return self;
}

#pragma mark Public Methods

- (void)createObject {
    NSManagedObjectContext * context = [[DSTCoreDataStore sharedInstance] backgroundContext];
    
    [context performBlock:^{
        DSTEventEntity * event = [NSEntityDescription insertNewObjectForEntityForName:@"EventEntity"
                                                               inManagedObjectContext:context];
        event.timestamp = [NSDate date];
        [context obtainPermanentIDsForObjects:@[event] error:nil];
        [context dst_saveToPersistentStoreWithCompletion:NULL];
    }];
}

- (void)deleteObject:(id)object {
    NSParameterAssert(object);
    
    NSManagedObjectContext * context = [[DSTCoreDataStore sharedInstance] backgroundContext];
    DSTEventEntity * event = (DSTEventEntity *)object;
    
    [context performBlock:^{
        id object = [context existingObjectWithID:event.objectID error:nil];
        [context deleteObject:object];
        [context dst_saveToPersistentStoreWithCompletion:NULL];
    }];
}

#pragma mark DSTDataSourceControllerProtocol

- (BOOL)performFetch:(NSError **)error {
    return [self.fetchedResultsController performFetch:error];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (NSIndexPath *)indexPathForObject:(id)object {
    return [self.fetchedResultsController indexPathForObject:object];
}

- (NSInteger)numberOfSections {
    return [self.fetchedResultsController.sections count];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if ([self.delegate respondsToSelector:@selector(dataSourceControllerWillChangeContent:)]) {
        [self.delegate dataSourceControllerWillChangeContent:self];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    if ([self.delegate respondsToSelector:@selector(dataSourceController:didChangeSectionAtIndex:forChangeType:)]) {
        [self.delegate dataSourceController:self
                    didChangeSectionAtIndex:sectionIndex
                              forChangeType:type];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if ([self.delegate respondsToSelector:@selector(dataSourceController:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
        [self.delegate dataSourceController:self
                            didChangeObject:anObject
                                atIndexPath:indexPath
                              forChangeType:type
                               newIndexPath:newIndexPath];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if ([self.delegate respondsToSelector:@selector(dataSourceControllerDidChangeContent:)]) {
        [self.delegate dataSourceControllerDidChangeContent:self];
    }
}

@end

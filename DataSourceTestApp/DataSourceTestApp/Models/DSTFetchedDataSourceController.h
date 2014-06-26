//
//  DSTFetchedDataSourceController.h
//  DataSourceTestApp
//
//  Created by Joachim Kret on 26/06/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DSTDataSourceControllerProtocol.h"

@interface DSTFetchedDataSourceController : NSObject <DSTDataSourceControllerProtocol>

@property (nonatomic, readonly, strong) NSFetchedResultsController * fetchedResultsController;
@property (nonatomic, readwrite, weak) id <DSTDataSourceControllerDelegate> delegate;

- (id)initWithFetchRequest:(NSFetchRequest *)fetchRequest
      managedObjectContext:(NSManagedObjectContext *)context
        sectionNameKeyPath:(NSString *)sectionNameKeyPath
                 cacheName:(NSString *)name;

- (void)createObject;
- (void)deleteObject:(id)object;

@end

//
//  DSTCoreDataStore.h
//  DataSourceTestApp
//
//  Created by Joachim Kret on 26/06/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSTCoreDataStore : NSObject {
@protected
    NSPersistentStoreCoordinator * _persistentStoreCoordinator;
    NSManagedObjectModel * _managedObjectModel;
    NSManagedObjectContext * _privateContext;
    NSManagedObjectContext * _mainContext;
    NSManagedObjectContext * _backgroundContext;
}

@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (nonatomic, readonly, strong) NSManagedObjectModel * managedObjectModel;
@property (nonatomic, readonly, strong) NSManagedObjectContext * privateContext;
@property (nonatomic, readonly, strong) NSManagedObjectContext * mainContext;
@property (nonatomic, readonly, strong) NSManagedObjectContext * backgroundContext;
@property (nonatomic, readwrite, strong) id defaultMergePolicy;

+ (NSString *)defaultModelName;
+ (NSString *)defaultStoreName;
+ (NSDictionary *)defaultStoreOptions;
+ (Class)defaultManagedObjectContextClass;

+ (instancetype)sharedInstance;

- (id)init;
- (id)initWithModelName:(NSString *)modelName;
- (id)initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel;

- (NSPersistentStore *)addInMemoryPersistentStore:(NSError **)error;
- (NSPersistentStore *)addSQLitePersistentStore:(NSError **)error;
- (NSPersistentStore *)addSQLitePersistentStoreWithName:(NSString *)name error:(NSError **)error;
- (NSPersistentStore *)addSQLitePersistentStoreWithName:(NSString *)name options:(NSDictionary *)options error:(NSError **)error;

- (NSManagedObjectContext *)contextForCurrentThread;
- (NSManagedObjectContext *)childContextForPrivateContext;
- (NSManagedObjectContext *)childContextForMainContext;
- (NSManagedObjectContext *)childContextForParentContext:(NSManagedObjectContext *)parentContext;
- (NSManagedObjectContext *)childContextForParentContext:(NSManagedObjectContext *)parentContext withConcurrencyType:(NSManagedObjectContextConcurrencyType)ct;
- (void)setDefaultMergePolicy:(id)mergePolicy applyToMainThreadContextAndParent:(BOOL)apply;

- (NSURL *)urlForStoreName:(NSString *)storeName;


@end

//
//  DSTCoreDataStore.m
//  DataSourceTestApp
//
//  Created by Joachim Kret on 26/06/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "DSTCoreDataStore.h"

static NSString * const DSTExeptionAddPersistentStore       = @"ExeptionAddPersistentStore";
static NSString * const DSTManagedObjectContextKey          = @"ManagedObjectContextKey";

#pragma mark - DSTCoreDataStore

@interface DSTCoreDataStore ()

- (void)setup;
- (NSString *)directoryWithSearchPathDirectory:(NSSearchPathDirectory)searchPathDirectory;
- (NSString *)applicationDocumentsDirectory;
- (NSString *)applicationStorageDirectory;

@end

#pragma mark -

@implementation DSTCoreDataStore

+ (NSString *)defaultModelName {
    return @"DataSourceModel.momd";
}

+ (NSString *)defaultStoreName {
    return @"DataSource.sqlite";
}

+ (NSDictionary *)defaultStoreOptions {
    return @{NSMigratePersistentStoresAutomaticallyOption     : @(YES),
             NSInferMappingModelAutomaticallyOption           : @(YES),
             NSSQLitePragmasOption                            : @{@"journal_mode"  : @"WAL"}};
}

+ (Class)defaultManagedObjectContextClass {
    return [NSManagedObjectContext class];
}

+ (instancetype)sharedInstance {
    static DSTCoreDataStore * __sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [DSTCoreDataStore new];
    });
    
    return __sharedInstance;
}

#pragma mark Init

- (id)init {
    return [self initWithModelName:[[self class] defaultModelName]];
}

- (id)initWithModelName:(NSString *)modelName {
    NSParameterAssert(modelName);
    NSAssert(modelName.length, @"Model name is empty");
    
    NSString * path = [[NSBundle mainBundle] pathForResource:[modelName stringByDeletingPathExtension]
                                                      ofType:[modelName pathExtension]];
	NSURL * anURL = [NSURL fileURLWithPath:path];
    NSManagedObjectModel * model = [[NSManagedObjectModel alloc] initWithContentsOfURL:anURL];
    
    return [self initWithManagedObjectModel:model];
}

- (id)initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel {
    NSParameterAssert(managedObjectModel);
    
    if (self = [super init]) {
        _defaultMergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        _managedObjectModel = managedObjectModel;
        
        [self persistentStoreCoordinator];
        [self privateContext];
        [self mainContext];
        [self backgroundContext];
        
        [self setup];
    }
    
    return self;
}

- (void)setup {
    NSError * error = nil;
    [self addInMemoryPersistentStore:&error];
    
    if (error) {
        [NSException raise:DSTExeptionAddPersistentStore format:@"Error with adding persistent store: %@", error];
    }
}

#pragma mark Accessors

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_persistentStoreCoordinator) {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)privateContext {
    if (!_privateContext) {
        Class contextClass = [[self class] defaultManagedObjectContextClass];
        _privateContext = [[contextClass alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_privateContext setMergePolicy:self.defaultMergePolicy];
        [_privateContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    
    return _privateContext;
}

- (NSManagedObjectContext *)mainContext {
    if (!_mainContext) {
        Class contextClass = [[self class] defaultManagedObjectContextClass];
        _mainContext = [[contextClass alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_mainContext setMergePolicy:self.defaultMergePolicy];
        [_mainContext setParentContext:self.privateContext];
    }
    
    return _mainContext;
}

- (NSManagedObjectContext *)backgroundContext {
    if (!_backgroundContext) {
        Class contextClass = [[self class] defaultManagedObjectContextClass];
        _backgroundContext = [[contextClass alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_backgroundContext setMergePolicy:self.defaultMergePolicy];
        [_backgroundContext setParentContext:self.mainContext];
    }
    
    return _backgroundContext;
}

#pragma mark Public Methods

- (NSPersistentStore *)addInMemoryPersistentStore:(NSError **)error {
    NSError * storeError = nil;
    NSPersistentStore * store = [self.persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&storeError];
    
    if (error) {
        *error = storeError;
    }
    
    return store;
}

- (NSPersistentStore *)addSQLitePersistentStore:(NSError **)error {
    return [self addSQLitePersistentStoreWithName:[[self class] defaultStoreName] error:error];
}

- (NSPersistentStore *)addSQLitePersistentStoreWithName:(NSString *)name error:(NSError **)error {
    return [self addSQLitePersistentStoreWithName:name options:[[self class] defaultStoreOptions] error:error];
}

- (NSPersistentStore *)addSQLitePersistentStoreWithName:(NSString *)name options:(NSDictionary *)options error:(NSError **)error {
    NSError * storeError = nil;
    BOOL pathExists = YES;
    NSPersistentStore * store = nil;
    NSFileManager * fileManager = [NSFileManager new];
    NSURL * anURL = [self urlForStoreName:name];
    
    if (![fileManager fileExistsAtPath:[[anURL URLByDeletingLastPathComponent] path] isDirectory:nil]) {
        pathExists = [fileManager createDirectoryAtURL:[anURL URLByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&storeError];
    }
    
    if (pathExists) {
        store = [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:anURL options:options error:&storeError];
    }
    
    if (error) {
        *error = storeError;
    }
    
    return store;
}

- (NSManagedObjectContext *)contextForCurrentThread {
    if ([NSThread isMainThread]) {
		return self.mainContext;
	}
	else {
		NSMutableDictionary * threadDict = [[NSThread currentThread] threadDictionary];
		NSManagedObjectContext * threadContext = [threadDict objectForKey:DSTManagedObjectContextKey];
        
        if (!threadContext) {
            threadContext = [self childContextForParentContext:self.mainContext withConcurrencyType:NSPrivateQueueConcurrencyType];
            [threadDict setObject:threadContext forKey:DSTManagedObjectContextKey];
        }
        
		return threadContext;
	}
}

- (NSManagedObjectContext *)childContextForPrivateContext {
    return [self childContextForParentContext:self.privateContext withConcurrencyType:NSPrivateQueueConcurrencyType];
}

- (NSManagedObjectContext *)childContextForMainContext {
    return [self childContextForParentContext:self.mainContext withConcurrencyType:NSPrivateQueueConcurrencyType];
}

- (NSManagedObjectContext *)childContextForParentContext:(NSManagedObjectContext *)parentContext {
    return [self childContextForParentContext:parentContext withConcurrencyType:NSPrivateQueueConcurrencyType];
}

- (NSManagedObjectContext *)childContextForParentContext:(NSManagedObjectContext *)parentContext withConcurrencyType:(NSManagedObjectContextConcurrencyType)ct {
    NSParameterAssert(parentContext);
    
    if (!parentContext) {
        return nil;
    }
    
    NSManagedObjectContext * context = [[[[self class] defaultManagedObjectContextClass] alloc] initWithConcurrencyType:ct];
    [context setMergePolicy:self.defaultMergePolicy];
    [context setParentContext:parentContext];
    
    return context;
}

- (void)setDefaultMergePolicy:(id)mergePolicy applyToMainThreadContextAndParent:(BOOL)apply {
    if (mergePolicy != self.defaultMergePolicy) {
        self.defaultMergePolicy = mergePolicy;
        
        if (apply) {
            [self.mainContext setMergePolicy:mergePolicy];
            [self.privateContext setMergePolicy:mergePolicy];
        }
    }
}

- (NSURL *)urlForStoreName:(NSString *)storeName {
    NSMutableArray * paths = [NSMutableArray array];
    [paths addObject:(([self applicationDocumentsDirectory]) ?: [NSNull null])];
    [paths addObject:(([self applicationStorageDirectory]) ?: [NSNull null])];
    NSFileManager * fileManager = nil;
    
    for (id path in paths) {
        if ([path isKindOfClass:[NSString class]]) {
            NSString * filePath = [(NSString *)path stringByAppendingPathComponent:storeName];
            
            if ([fileManager fileExistsAtPath:filePath]) {
                return [NSURL URLWithString:filePath];
            }
        }
    }
    
    return [NSURL fileURLWithPath:[[self applicationStorageDirectory] stringByAppendingPathComponent:storeName]];
}

#pragma mark Private Methods

- (NSString *)directoryWithSearchPathDirectory:(NSSearchPathDirectory)searchPathDirectory {
    NSArray * objects = NSSearchPathForDirectoriesInDomains(searchPathDirectory, NSUserDomainMask, YES);
    return (objects && objects.count) ? [objects lastObject] : nil;
}

- (NSString *)applicationDocumentsDirectory {
    return [self directoryWithSearchPathDirectory:NSDocumentDirectory];
}

- (NSString *)applicationStorageDirectory {
    NSString * appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    return [[self directoryWithSearchPathDirectory:NSApplicationSupportDirectory] stringByAppendingPathComponent:appName];
}

@end

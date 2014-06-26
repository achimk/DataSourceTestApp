//
//  NSManagedObjectContext+Additions.m
//  DataSourceTestApp
//
//  Created by Joachim Kret on 26/06/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "NSManagedObjectContext+Additions.h"

#import "DSTCoreDataStore.h"

@implementation NSManagedObjectContext (Additions)

- (void)dst_saveOnlySelfWithCompletion:(DSTSaveCompletionHandler)completion {
    [self dst_saveWithOptions:DSTSaveWithoutOptions completion:completion];
}

- (void)dst_saveOnlySelfAndWait {
    [self dst_saveWithOptions:DSTSaveSynchronously completion:nil];
}

- (void)dst_saveToPersistentStoreWithCompletion:(DSTSaveCompletionHandler)completion {
    [self dst_saveWithOptions:DSTSaveParentContexts completion:completion];
}

- (void)dst_saveToPersistentStoreAndWait {
    [self dst_saveWithOptions:DSTSaveParentContexts | DSTSaveSynchronously completion:nil];
}

- (void)dst_saveWithOptions:(DSTSaveContextOptions)mask completion:(DSTSaveCompletionHandler)completion {
    BOOL shouldSaveSync             = ((mask & DSTSaveSynchronously) == DSTSaveSynchronously);
    BOOL shouldSaveSyncExceptRoot   = ((mask & DSTSaveAllSynchronouslyExceptRoot) == DSTSaveAllSynchronouslyExceptRoot);
    
    BOOL syncSave = (shouldSaveSync && !shouldSaveSyncExceptRoot) || (shouldSaveSyncExceptRoot && (self != [[DSTCoreDataStore sharedInstance] privateContext]));
    BOOL saveParentContexts = ((mask & DSTSaveParentContexts) == DSTSaveParentContexts);
    
    if (![self hasChanges]) {
#if LOG_MANAGED_OBJECT_CONTEXT_SAVE
        NSLog(@"NO CHANGES IN ** %@ ** CONTEXT - NOT SAVING", self);
#endif
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, nil);
            });
        }
        
        return;
    }
    
#if LOG_MANAGED_OBJECT_CONTEXT_SAVE
    NSLog(@"→ Saving %@", [self description]);
    NSLog(@"→ Save Parents? %@", @(saveParentContexts));
    NSLog(@"→ Save Synchronously? %@", @(syncSave));
#endif
    
    id saveBlock = ^{
        NSError *error = nil;
        BOOL     saved = NO;
        
        @try {
            saved = [self save:&error];
        }
        @catch(NSException *exception) {
#if LOG_MANAGED_OBJECT_CONTEXT_SAVE
            NSLog(@"Unable to perform save: %@", (id)[exception userInfo] ? : (id)[exception reason]);
#endif
        }
        @finally {
#if LOG_MANAGED_OBJECT_CONTEXT_SAVE
            if (error) {
                NSLog(@"Save error: %@", error);
            }
#endif
            if (!saved) {
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(saved, error);
                    });
                }
            } else {
                // If we're saving parent contexts, do so
                if (saveParentContexts && [self parentContext]) {
                    [[self parentContext] dst_saveWithOptions:mask completion:completion];
                }
                // Do the completion action if one was specified
                else {
#if LOG_MANAGED_OBJECT_CONTEXT_SAVE
                    NSLog(@"→ Finished saving: %@", [self description]);
#endif
                    
                    if (completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(saved, error);
                        });
                    }
                }
            }
        }
    };
    
    if (YES == syncSave) {
        [self performBlockAndWait:saveBlock];
    } else {
        [self performBlock:saveBlock];
    }
}

@end

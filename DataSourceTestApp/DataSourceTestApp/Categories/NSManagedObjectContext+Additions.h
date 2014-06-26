//
//  NSManagedObjectContext+Additions.h
//  DataSourceTestApp
//
//  Created by Joachim Kret on 26/06/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <CoreData/CoreData.h>

/*
 *  Implementation from MagicalRecord:
 *  https://github.com/magicalpanda/MagicalRecord/blob/develop/MagicalRecord/Categories/NSManagedObjectContext/NSManagedObjectContext%2BMagicalSaves.h
 */

typedef enum {
    DSTSaveWithoutOptions               = 0,        ///< No options — used for cleanliness only
    DSTSaveParentContexts               = 1 << 1,   ///< When saving, continue saving parent contexts until the changes are present in the persistent store
    DSTSaveSynchronously                = 1 << 2,   ///< Perform saves synchronously, blocking execution on the current thread until the save is complete
    DSTSaveAllSynchronouslyExceptRoot   = 1 << 3    ///< Perform saves synchronously, blocking execution on the current thread until the save is complete; however, save
} DSTSaveContextOptions;

typedef void(^DSTSaveCompletionHandler)(BOOL success, NSError *error);

@interface NSManagedObjectContext (Additions)

/// \brief      Asynchronously save changes in the current context and it's parent
/// \param       completion  Completion block that is called after the save has completed. The block is passed a success state as a `BOOL` and an `NSError` instance if an error occurs. Always called on the main queue.
/// \discussion Executes a save on the current context's dispatch queue asynchronously. This method only saves the current context, and the parent of the current context if one is set. The completion block will always be called on the main queue.
- (void) dst_saveOnlySelfWithCompletion:(DSTSaveCompletionHandler)completion;

/// \brief      Asynchronously save changes in the current context all the way back to the persistent store
/// \param       completion  Completion block that is called after the save has completed. The block is passed a success state as a `BOOL` and an `NSError` instance if an error occurs. Always called on the main queue.
/// \discussion Executes asynchronous saves on the current context, and any ancestors, until the changes have been persisted to the assigned persistent store. The completion block will always be called on the main queue.
- (void) dst_saveToPersistentStoreWithCompletion:(DSTSaveCompletionHandler)completion;

/// \brief      Synchronously save changes in the current context and it's parent
/// \discussion Executes a save on the current context's dispatch queue. This method only saves the current context, and the parent of the current context if one is set. The method will not return until the save is complete.
- (void) dst_saveOnlySelfAndWait;

/// \brief      Synchronously save changes in the current context all the way back to the persistent store
/// \discussion Executes saves on the current context, and any ancestors, until the changes have been persisted to the assigned persistent store. The method will not return until the save is complete.
- (void) dst_saveToPersistentStoreAndWait;

/// \brief       Save the current context with options
/// \param       mask        bitmasked options for the save process
/// \param       completion  Completion block that is called after the save has completed. The block is passed a success state as a `BOOL` and an `NSError` instance if an error occurs. Always called on the main queue.
/// \discussion  All other save methods are conveniences to this method.
- (void) dst_saveWithOptions:(DSTSaveContextOptions)mask completion:(DSTSaveCompletionHandler)completion;

@end


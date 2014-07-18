//
//  ContentLock.h
//  Les Sexperts
//
//  Created by Paul De Lange on 28/02/14.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^kContentLockRemovedHandler)(NSError* error);

extern NSString * ContentLockWasRemovedNotification;

@interface ContentLock : NSObject

+ (BOOL) restoreWithCompletion: (kContentLockRemovedHandler) completionHandler;

+ (BOOL) unlockWithCompletion: (kContentLockRemovedHandler) completionHandler;
+ (BOOL) unlock;
+ (BOOL) lock;

+ (BOOL) tryLock;   //YES if locked

@end

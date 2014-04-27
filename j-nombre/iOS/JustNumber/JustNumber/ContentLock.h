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

+ (BOOL) unlockWithCompletion: (kContentLockRemovedHandler) completionHandler;
+ (BOOL) lock;

+ (BOOL) tryLock;   //YES if locked

@end

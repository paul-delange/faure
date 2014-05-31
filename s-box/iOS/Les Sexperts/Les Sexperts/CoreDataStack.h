//
//  CoreDataStack.h
//  Les Sexperts
//
//  Created by Paul De Lange on 28/02/14.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataStack : NSObject

+ (instancetype) stackWithStoreFilename: (NSString*) storeFilename;

@property (copy, nonatomic) NSString* dataLanguage;

- (BOOL) save;

- (NSManagedObjectContext*) mainQueueManagedObjectContext;

@end

@interface NSManagedObjectContext (CoreDataStack)

/** Save a managed object context in a thread safe manner */
- (BOOL) threadSafeSave: (NSError *__autoreleasing*) error;

/** Return the locale for the database backing this context */
- (NSLocale*) locale;

@end

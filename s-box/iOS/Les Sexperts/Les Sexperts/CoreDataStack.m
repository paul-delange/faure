//
//  CoreDataStack.m
//  Les Sexperts
//
//  Created by Paul De Lange on 28/02/14.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "CoreDataStack.h"

#import "NSBundle+Seeding.h"
#import "NSLocale+ContentLanguage.h"

#include <objc/runtime.h>
#import <CoreData/CoreData.h>

#define     ASSOCIATIVE_KEY_DATA_STACK      "core.data.stack"

#if TARGET_OS_IPHONE
#define SEARCH_PATH_FROM_APPLE_GUIDELINES   NSDocumentDirectory
#else
#define SEARCH_PATH_FROM_APPLE_GUIDELINES   NSDocumentDirectory
#endif

NSString * const NSUserDefaultsContentLanguageKey = @"ContentLanguage";

@interface NSManagedObjectContext (CoreDataStackInternal)
@property (strong, nonatomic) CoreDataStack* stack;
@end

@interface CoreDataStack ()

- (id) initWithStoreFileName: (NSString*) storeFileName;

@property (strong, nonatomic) NSPersistentStore* dataStore;
@property (strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext* mainQueueManagedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext* persistentStoreManagedObjectContext;
@property (strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;

@end

@implementation CoreDataStack

+ (instancetype) stackWithStoreFilename: (NSString*) storeFilename {
    return [[self alloc] initWithStoreFileName: storeFilename];
}

- (id) initWithStoreFileName: (NSString*) storeFileName {
    NSParameterAssert([NSThread isMainThread]);
    
    self = [super init];
    if( self ) {
        
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles: nil];
        
        NSDictionary* readwriteOptions = @{NSSQLitePragmasOption : @{ @"journal_mode" : @"DELETE" },
                                           NSMigratePersistentStoresAutomaticallyOption : @YES,
                                           NSInferMappingModelAutomaticallyOption : @YES
                                           };
        
        NSPersistentStoreCoordinator* psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: _managedObjectModel];
        
        NSSearchPathDirectory domain = SEARCH_PATH_FROM_APPLE_GUIDELINES;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(domain, NSUserDomainMask, YES);
        NSString* writeableDirectoryPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        
#if TARGET_OS_IPHONE
        ///////////////     LEGACY SUPPORT  /////////////////
        
        /* At the beginning there was only french and all the data was stored in one database,
         * ContentStore.sqlite. Later we decided to go international and store the data for
         * each locale in a database called ContentStore_fr.sqlite for example.
         *
         * This next code takes the old database and sets it as the current french one.
         */
        NSSearchPathDirectory legacyDomain = NSLibraryDirectory;
        NSArray *legacyPaths = NSSearchPathForDirectoriesInDomains(legacyDomain, NSUserDomainMask, YES);
        NSString* legacyStoreDirectory = ([legacyPaths count] > 0) ? [legacyPaths objectAtIndex:0] : nil;
        NSString* legacyStorePath = [legacyStoreDirectory stringByAppendingPathComponent: @"ContentLibrary.sqlite"];
        if( [[NSFileManager defaultManager] fileExistsAtPath: legacyStorePath] ) {
            NSString* frenchStoreName = [storeFileName stringByAppendingString: @"_fr"];
            NSString* frenchStorePath = [writeableDirectoryPath stringByAppendingPathComponent: frenchStoreName];
            
            frenchStorePath = [frenchStorePath stringByAppendingPathExtension: @"db"];
            
            NSError* error;
            [[NSFileManager defaultManager] moveItemAtPath: legacyStorePath
                                                    toPath: frenchStorePath
                                                     error: &error];
            DLogError(error);
            
            NSURL* frenchStoreURL = [NSURL fileURLWithPath: frenchStorePath];
            [frenchStoreURL setResourceValue: @YES forKey: NSURLIsExcludedFromBackupKey error: &error];
            DLogError(error);
        }
        NSParameterAssert(![[NSFileManager defaultManager] fileExistsAtPath: legacyStorePath]);
        
        ///////////////   END  LEGACY SUPPORT  /////////////////
#endif
        
        NSString * language = [[NSUserDefaults standardUserDefaults] objectForKey: NSUserDefaultsContentLanguageKey];
        NSString* writeableStoreFileName = [NSString stringWithFormat: @"%@_%@.db", storeFileName, language];
        NSString* writeableStorePath = [writeableDirectoryPath stringByAppendingPathComponent: writeableStoreFileName];
        NSURL* writeableStoreURL = [NSURL fileURLWithPath: writeableStorePath];
        
#if TARGET_OS_IPHONE
        if(![[NSFileManager defaultManager] fileExistsAtPath: writeableStorePath] ) {
            NSBundle* seedBundle = [NSBundle seedBundle];
            
            NSString* seedStorePath = [seedBundle pathForResource: writeableStoreFileName ofType: nil];
            NSParameterAssert([[NSFileManager defaultManager] fileExistsAtPath: seedStorePath]);
            
            NSError* error;
            [[NSFileManager defaultManager] copyItemAtPath: seedStorePath
                                                    toPath: writeableStorePath
                                                     error: &error];
            DLogError(error);
        }
        NSParameterAssert([[NSFileManager defaultManager] fileExistsAtPath: writeableStorePath]);
#else
        if( [[NSFileManager defaultManager] fileExistsAtPath: writeableStorePath] ) {
            [[NSFileManager defaultManager] removeItemAtPath: writeableStorePath
                                                       error: nil];
        }
#endif
        
        NSError* error;
        _dataStore = [psc addPersistentStoreWithType: NSSQLiteStoreType
                                       configuration: nil
                                                 URL: writeableStoreURL
                                             options: readwriteOptions
                                               error: &error];
        DLogError(error);
        
        _persistentStoreCoordinator = psc;
        
        self.persistentStoreManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
        self.persistentStoreManagedObjectContext.persistentStoreCoordinator = _persistentStoreCoordinator;
        self.persistentStoreManagedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
        self.persistentStoreManagedObjectContext.undoManager = nil;
        
        self.mainQueueManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
        self.mainQueueManagedObjectContext.parentContext = self.persistentStoreManagedObjectContext;
        self.mainQueueManagedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
        self.mainQueueManagedObjectContext.undoManager = nil;
        
        self.mainQueueManagedObjectContext.stack = self;
        self.persistentStoreManagedObjectContext.stack = self;
        
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleManagedObjectContextDidSaveNotification:)
                                                     name: NSManagedObjectContextDidSaveNotification
                                                   object: self.persistentStoreManagedObjectContext];
    }
    
    return self;
}

- (NSURL*) storeURL {
    for(NSPersistentStore* store in self.persistentStoreCoordinator.persistentStores) {
        if( [store.type isEqualToString: NSSQLiteStoreType] ) {
            return [self.persistentStoreCoordinator URLForPersistentStore: store];
        }
    }
    
    return nil;
}

- (NSString*) dataLanguage {
    NSURL* storeURL = self.dataStore.URL;
    NSString* lastPathComponent = [storeURL lastPathComponent];
    NSString* fileName = [lastPathComponent stringByDeletingPathExtension];
    NSArray* components = [fileName componentsSeparatedByString: @"_"];
    NSParameterAssert(components.count == 2);
    NSRange baseNameRange = [fileName rangeOfString: components[0]];
    
    NSUInteger baseNameEndIndex = baseNameRange.location + baseNameRange.length + 1;
    NSUInteger baseNameLength = [fileName length] - baseNameEndIndex;
    
    return [fileName substringWithRange: NSMakeRange(baseNameEndIndex, baseNameLength)];
}

- (void) setDataLanguage:(NSString *)dataLanguage {
    
    [self save];
    
    [self.mainQueueManagedObjectContext reset];
    [self.persistentStoreManagedObjectContext reset];
    
    NSError* error;
    if(![self.persistentStoreCoordinator removePersistentStore: self.dataStore error: &error]) {
        DLogError(error);
    }
    
    NSURL* storeURL = self.dataStore.URL;
    NSString* lastPathComponent = [storeURL lastPathComponent];
    NSString* fileName = [lastPathComponent stringByDeletingPathExtension];
    NSArray* components = [fileName componentsSeparatedByString: @"_"];
    NSParameterAssert(components.count == 2);
    NSString* userDomain = components[0];
    
    NSString* writeableStoreFileName = [NSString stringWithFormat: @"%@_%@.db", userDomain, dataLanguage];
#if TARGET_OS_IPHONE
    NSBundle* seedBundle = [NSBundle seedBundle];
    NSURL* seedStoreURL = [seedBundle URLForResource: writeableStoreFileName withExtension: nil];
#else
    NSSearchPathDirectory domain = SEARCH_PATH_FROM_APPLE_GUIDELINES;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(domain, NSUserDomainMask, YES);
    NSString* writeableDirectoryPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString* writeableStorePath = [writeableDirectoryPath stringByAppendingPathComponent: writeableStoreFileName];
    if( [[NSFileManager defaultManager] fileExistsAtPath: writeableStorePath] ) {
        [[NSFileManager defaultManager] removeItemAtPath: writeableStorePath
                                                   error: &error];
        DLogError(error);
    }
    
    NSURL* seedStoreURL = [NSURL fileURLWithPath: writeableStorePath];
#endif
    
    NSDictionary* readwriteOptions = @{ NSSQLitePragmasOption : @{ @"journal_mode" : @"DELETE" },
                                        NSMigratePersistentStoresAutomaticallyOption : @YES,
                                        NSInferMappingModelAutomaticallyOption : @YES
                                       };
    
    self.dataStore = [self.persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                                   configuration: nil
                                                                             URL: seedStoreURL
                                                                         options: readwriteOptions
                                                                           error: &error];
    DLogError(error);
    
    [[NSUserDefaults standardUserDefaults] setObject: dataLanguage forKey: NSUserDefaultsContentLanguageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSManagedObjectContext*) mainQueueManagedObjectContext {
#if !TARGET_OS_MAC
    NSParameterAssert([NSThread isMainThread]);
#endif
    return _mainQueueManagedObjectContext;
}

- (BOOL) save {
#if !TARGET_OS_MAC
    NSParameterAssert([NSThread isMainThread]);
#endif
    
    NSManagedObjectContext* moc = self.mainQueueManagedObjectContext;
    
    while (moc) {
        [moc performBlockAndWait: ^{
            NSError* error;
            [moc save: &error];
            DLogError(error);
        }];
        
        moc = moc.parentContext;
    }
    
    return YES;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)handleManagedObjectContextDidSaveNotification:(NSNotification *)notification {
    NSAssert(notification.object == self.persistentStoreManagedObjectContext, @"Received NSManagedObjectContextDidSaveNotification on an unexpected context: %@", notification.object);
#if TARGET_OS_IPHONE
    [self.mainQueueManagedObjectContext performBlock: ^{
        [self.mainQueueManagedObjectContext mergeChangesFromContextDidSaveNotification: notification];
    }];
#endif
}

#pragma mark - NSObject
+ (void) initialize {
    
    NSDictionary* defaultOptions = @{
                                     NSUserDefaultsContentLanguageKey : [NSLocale contentLanguageNearestDeviceLanguage]
                                     };
    [[NSUserDefaults standardUserDefaults] registerDefaults: defaultOptions];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

@end

@implementation NSManagedObjectContext (CoreDataStack)

- (BOOL) threadSafeSave: (NSError *__autoreleasing*) error {
    CoreDataStack* stack = self.stack;
    NSParameterAssert(stack);
    return [stack save];
}

- (void) setStack:(CoreDataStack *)stack {
    objc_setAssociatedObject(self, ASSOCIATIVE_KEY_DATA_STACK, stack, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CoreDataStack*) stack {
    return objc_getAssociatedObject(self, ASSOCIATIVE_KEY_DATA_STACK);
}

- (NSLocale*) locale {
    CoreDataStack* stack = self.stack;
    NSString* identifier = stack.dataLanguage;
    return [NSLocale localeWithLocaleIdentifier: identifier];
}

- (NSFetchRequest *)fetchRequestFromTemplateWithName:(NSString *)name substitutionVariables:(NSDictionary *)variables {
    CoreDataStack* stack = self.stack;
    NSParameterAssert(stack);
    
    NSManagedObjectModel* mom = stack.managedObjectModel;
    return [mom fetchRequestFromTemplateWithName: name substitutionVariables: variables];
}

@end

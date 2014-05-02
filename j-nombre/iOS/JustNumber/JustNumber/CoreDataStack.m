//
//  CoreDataStack.m
//  Les Sexperts
//
//  Created by Paul De Lange on 28/02/14.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "CoreDataStack.h"
#import "NSLocale+ContentLanguages.h"
#import "NSBundle+Seeding.h"

#import <CoreData/CoreData.h>

#include <objc/runtime.h>

#if TARGET_OS_IPHONE
#define SEARCH_PATH_FROM_APPLE_GUIDELINES   NSDocumentDirectory
#else
#define SEARCH_PATH_FROM_APPLE_GUIDELINES   NSDocumentDirectory
#endif

#define     ASSOCIATIVE_KEY_DATA_STACK      "core.data.stack"

NSString * const NSUserDefaultsContentLanguageKey = @"ContentLanguage";
NSString * const NSManagedObjectContextLocaleDidChangeNotification = @"LocaleDidChange";

/* On iOS7, Core Data cloud synchronization seems to be 'fixed'. It means we can use Core Data as we traditionally did but the SQLite persistent store is sent to iCloud and is therefore available on all devices. This is particularly useful here where I split the user progress data from the readonly application data. It means we could only sync the progress database. Below are some links to get more information about this but we are blocked by one problem:
 
 1) The app is designed to have one user. And when you sync to iCloud it is possible that you can have a user arrive from another device or this user can get sent to another device. This creates a progression conflict and I don't know a way to merge the two without asking for the user to interact. On games like 'Clash of Clans', this is easier because there is a real "user" concept including a name for the user to identifier with. Then there is a prompt, something like "Would you like to import your progress as USERNAME? Progress on this device will be cleared!"...
 
 So for now, I turn it off. If we had more time, this could be a great feature!
 
 @see https://github.com/lhunath/UbiquityStoreManager
 @see https://developer.apple.com/videos/wwdc/2013/?id=207
 @see http://www.objc.io/issue-10/icloud-core-data.html
 @see https://developer.apple.com/library/ios/documentation/General/Conceptual/iCloudDesignGuide/Chapters/DesignForCoreDataIniCloud.html
 */

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
#warning Consider enabling iCloud sync here
#define         USE_CORE_DATA_CLOUD     0
#else
#define         USE_CORE_DATA_CLOUD     0
#endif

@interface NSManagedObjectContext (CoreDataStackInternal)
@property (strong, nonatomic) CoreDataStack* stack;
@end

@interface CoreDataStack ()

@property (strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext* mainQueueManagedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext* persistentStoreManagedObjectContext;

@property (strong) NSPersistentStore* dataStore;
@property (strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;

@end

@implementation CoreDataStack

+ (instancetype) initAppDomain:(NSString *)appDomain userDomain:(NSString *)userDomain {
    return [[self alloc] initAppDomain: appDomain userDomain: userDomain];
}

- (instancetype) initAppDomain: (NSString*) appDomain userDomain: (NSString*) userDomain {
    NSParameterAssert([NSThread isMainThread]);
    
    self = [super init];
    if( self ) {
        
        //1. Create the managed object model
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles: nil];
        
        //2. Create the persistent store coordinator
        NSDictionary* readwriteOptions = @{
                                           NSMigratePersistentStoresAutomaticallyOption : @YES,
                                           NSInferMappingModelAutomaticallyOption : @YES
                                           };
        
#if DEBUG
        readwriteOptions = @{
                             NSMigratePersistentStoresAutomaticallyOption : @YES,
                             NSInferMappingModelAutomaticallyOption : @YES,
                             NSSQLitePragmasOption : @{ @"journal_mode" : @"DELETE" }
#if USE_CORE_DATA_CLOUD
                             , NSPersistentStoreUbiquitousContentNameKey : kAppName()
#endif
                             };
#endif
        
        NSPersistentStoreCoordinator* psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: _managedObjectModel];
        
        //3. Add the metadata store
        NSSearchPathDirectory domain = SEARCH_PATH_FROM_APPLE_GUIDELINES;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(domain, NSUserDomainMask, YES);
        NSString* writeableDirectoryPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        
        NSError* error;
        
        if( appDomain ) {
            NSString* writeableStoreFileName = [NSString stringWithFormat: @"%@.sqlite", appDomain];
            NSString* writeableStorePath = [writeableDirectoryPath stringByAppendingPathComponent: writeableStoreFileName];
            NSURL* writeableStoreURL = [NSURL fileURLWithPath: writeableStorePath];
            
            [psc addPersistentStoreWithType: NSSQLiteStoreType
                              configuration: appDomain
                                        URL: writeableStoreURL
                                    options: readwriteOptions
                                      error: &error];
            DLogError(error);
            
            [writeableStoreURL setResourceValue: @YES forKey: NSURLIsExcludedFromBackupKey error: &error];
            DLogError(error);
        }
        
        //4. Add the data store
        if( userDomain ) {
            NSMutableDictionary* mutableOptions = [readwriteOptions mutableCopy];
            mutableOptions[NSSQLitePragmasOption] = @{ @"journal_mode" : @"DELETE" };
            
            [mutableOptions removeObjectForKey: NSPersistentStoreUbiquitousContentNameKey];
            
            
            NSString * language = [[NSUserDefaults standardUserDefaults] objectForKey: NSUserDefaultsContentLanguageKey];
            NSString* readableStoreFileName = [NSString stringWithFormat: @"%@_%@.sqlite", userDomain, language];
            
#if TARGET_OS_IPHONE
            NSURL* readableStoreURL = [[NSBundle seedBundle] URLForResource: readableStoreFileName withExtension: nil];
            mutableOptions[NSReadOnlyPersistentStoreOption] = @YES;
#else
            NSString* readableStorePath = [writeableDirectoryPath stringByAppendingPathComponent: readableStoreFileName];
            if( [[NSFileManager defaultManager] fileExistsAtPath: readableStorePath] ) {
                [[NSFileManager defaultManager] removeItemAtPath: readableStorePath
                                                           error: &error];
                DLogError(error);
            }
            
            NSString* supportPath = [NSString stringWithFormat: @".%@_%@_SUPPORT", userDomain, language];
            NSString* readableSupportPath = [writeableDirectoryPath stringByAppendingPathComponent: supportPath];
            if( [[NSFileManager defaultManager] fileExistsAtPath: readableSupportPath] ) {
                [[NSFileManager defaultManager] removeItemAtPath: readableSupportPath
                                                           error: &error];
                DLogError(error);
            }
            
            
            NSURL* readableStoreURL = [NSURL fileURLWithPath: readableStorePath];
#endif
            NSDictionary* readOptions = mutableOptions;
            _dataStore = [psc addPersistentStoreWithType: NSSQLiteStoreType
                                           configuration: userDomain
                                                     URL: readableStoreURL
                                                 options: readOptions
                                                   error: &error];
            DLogError(error);
        }
        
        _persistentStoreCoordinator = psc;
        
        self.persistentStoreManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
        self.persistentStoreManagedObjectContext.persistentStoreCoordinator = _persistentStoreCoordinator;
        self.persistentStoreManagedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
        self.persistentStoreManagedObjectContext.undoManager = nil;
        
        self.mainQueueManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
        self.mainQueueManagedObjectContext.parentContext = self.persistentStoreManagedObjectContext;
        self.mainQueueManagedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
        self.mainQueueManagedObjectContext.undoManager = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleManagedObjectContextDidSaveNotification:)
                                                     name: NSManagedObjectContextDidSaveNotification
                                                   object: self.persistentStoreManagedObjectContext];
        
        self.mainQueueManagedObjectContext.stack = self;
        self.persistentStoreManagedObjectContext.stack = self;
        
#if USE_CORE_DATA_CLOUD
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(storesWillChange:)
                                                     name:NSPersistentStoreCoordinatorStoresWillChangeNotification
                                                   object:self.persistentStoreCoordinator];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(storesDidChange:)
                                                     name:NSPersistentStoreCoordinatorStoresDidChangeNotification
                                                   object:self.persistentStoreCoordinator];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(persistentStoreDidImportUbiquitousContentChanges:)
                                                     name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                                   object:self.persistentStoreCoordinator];
#endif
    }
    
    return self;
}

- (NSString*) dataLanguage {
    NSURL* storeURL = self.dataStore.URL;
    NSString* lastPathComponent = [storeURL lastPathComponent];
    NSString* fileName = [lastPathComponent stringByDeletingPathExtension];
    NSArray* components = [fileName componentsSeparatedByString: @"_"];
    NSParameterAssert(components.count >= 2);
    NSRange baseNameRange = [fileName rangeOfString: components[0]];
    
    NSUInteger baseNameEndIndex = baseNameRange.location + baseNameRange.length + 1;
    NSUInteger baseNameLength = [fileName length] - baseNameEndIndex;
    
    return [fileName substringWithRange: NSMakeRange(baseNameEndIndex, baseNameLength)];
}

- (void) setDataLanguage:(NSString *)dataLanguage {
    NSError* error;
    if(![self.persistentStoreCoordinator removePersistentStore: self.dataStore error: &error]) {
        DLogError(error);
    }
    
    NSURL* storeURL = self.dataStore.URL;
    NSString* lastPathComponent = [storeURL lastPathComponent];
    NSString* fileName = [lastPathComponent stringByDeletingPathExtension];
    NSArray* components = [fileName componentsSeparatedByString: @"_"];
    NSParameterAssert(components.count >= 2);
    NSString* userDomain = components[0];
    
    NSString* readableStoreFileName = [NSString stringWithFormat: @"%@_%@.sqlite", userDomain, dataLanguage];
    
#if TARGET_OS_IPHONE
    NSURL* readableStoreURL = [[NSBundle seedBundle] URLForResource: readableStoreFileName withExtension: nil];
    //NSParameterAssert([[NSFileManager defaultManager] fileExistsAtPath: [readableStoreURL absoluteString]]);
#else
    NSSearchPathDirectory domain = SEARCH_PATH_FROM_APPLE_GUIDELINES;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(domain, NSUserDomainMask, YES);
    NSString* writeableDirectoryPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString* readableStorePath = [writeableDirectoryPath stringByAppendingPathComponent: readableStoreFileName];
    if( [[NSFileManager defaultManager] fileExistsAtPath: readableStorePath] ) {
        [[NSFileManager defaultManager] removeItemAtPath: readableStorePath
                                                   error: &error];
        DLogError(error);
    }
    
    NSURL* readableStoreURL = [NSURL fileURLWithPath: readableStorePath];
#endif
    NSDictionary* readOptions = @{
                                  NSSQLitePragmasOption : @{ @"journal_mode" : @"DELETE" },
                                  NSMigratePersistentStoresAutomaticallyOption : @YES,
                                  NSInferMappingModelAutomaticallyOption : @YES
#if TARGET_OS_IPHONE
                                  ,NSReadOnlyPersistentStoreOption : @YES
#endif
                                  };
    
    self.dataStore = [self.persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                                   configuration: userDomain
                                                                             URL: readableStoreURL
                                                                         options: readOptions
                                                                           error: &error];
    DLogError(error);
    
    [[NSUserDefaults standardUserDefaults] setObject: dataLanguage forKey: NSUserDefaultsContentLanguageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: NSManagedObjectContextLocaleDidChangeNotification
                                                        object: dataLanguage];
}

- (NSURL*) storeURL {
    for(NSPersistentStore* store in self.persistentStoreCoordinator.persistentStores) {
        if( [store.type isEqualToString: NSSQLiteStoreType] ) {
            return [self.persistentStoreCoordinator URLForPersistentStore: store];
        }
    }
    
    return nil;
}

- (NSManagedObjectContext*) mainQueueManagedObjectContext {
    NSParameterAssert([NSThread isMainThread]);
    return _mainQueueManagedObjectContext;
}

- (BOOL) save {
    NSParameterAssert([NSThread isMainThread]);
    
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

#pragma mark - Notifications
- (void)handleManagedObjectContextDidSaveNotification:(NSNotification *)notification {
    NSAssert(notification.object == self.persistentStoreManagedObjectContext, @"Received NSManagedObjectContextDidSaveNotification on an unexpected context: %@", notification.object);
    
    if( self.mergeNotificationBlock ) {
        self.mergeNotificationBlock(notification);
    }
    
    [self.mainQueueManagedObjectContext performBlock: ^{
        [self.mainQueueManagedObjectContext mergeChangesFromContextDidSaveNotification: notification];
    }];
}

#if USE_CORE_DATA_CLOUD
- (void) persistentStoreDidImportUbiquitousContentChanges:(NSNotification *)notification {
    NSAssert(notification.object == self.persistentStoreManagedObjectContext, @"Received NSPersistentStoreDidImportUbiquitousContentChangesNotification on an unexpected context: %@", notification.object);
    
    if( self.mergeNotificationBlock )
        self.mergeNotificationBlock(notification);
    
    NSManagedObjectContext *context = _mainQueueManagedObjectContext;
    
    [context performBlock:^{
        [context mergeChangesFromContextDidSaveNotification:notification];
    }];
}

- (void)storesWillChange:(NSNotification *)notification {
    //NSPersistentStore* oldStore = notification.userInfo[NSRemovedPersistentStoresKey];
    //NSPersistentStore* newStore = notification.userInfo[NSAddedPersistentStoresKey];
    //DLog(@"Deleting persistent store: %@ and replace it with: %@", oldStore, newStore);
    
    NSManagedObjectContext* moc = _mainQueueManagedObjectContext;
    
    while (moc) {
        if( [moc hasChanges] ) {
            [moc performBlockAndWait: ^{
                NSError* error;
                [moc save: &error];
                DLogError(error);
            }];
        }
        
        [moc reset];
        
        moc = moc.parentContext;
    }
    
    // Refresh your User Interface.
}

- (void)storesDidChange:(NSNotification *)notification {
    // Refresh your User Interface.
}
#endif

#pragma mark - NSObject
+ (void) initialize {
    
    NSDictionary* defaultOptions = @{
                                     NSUserDefaultsContentLanguageKey : [NSLocale contentLanguageNearestDeviceLanguage]
                                     };
    [[NSUserDefaults standardUserDefaults] registerDefaults: defaultOptions];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end

@implementation NSManagedObjectContext (CoreDataStack)

- (BOOL) threadSafeSave: (__autoreleasing NSError**) error {
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

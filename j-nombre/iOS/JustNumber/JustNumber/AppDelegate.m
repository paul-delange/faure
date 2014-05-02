//
//  AppDelegate.m
//  JustNumber
//
//  Created by Paul de Lange on 22/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "AppDelegate.h"

#import "CoreDataStack.h"

NSManagedObjectContext * const NSManagedObjectContextGetMain(void) {
    AppDelegate* del = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    CoreDataStack* stack = del.dataStore;
    return stack.mainQueueManagedObjectContext;
}

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (void) application:(UIApplication *)application didUpdateToVersion: (NSString*) newVersion fromVersion: (NSString*) previousVersion {
    if( !previousVersion ) {
        //First install
    }
}

- (CoreDataStack*) dataStore {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dataStore = [CoreDataStack initAppDomain: @"User" userDomain: @"Data"];
    });
    
    return _dataStore;
}

@end

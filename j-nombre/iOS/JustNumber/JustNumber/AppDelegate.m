//
//  AppDelegate.m
//  JustNumber
//
//  Created by Paul de Lange on 22/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "AppDelegate.h"

#import "CoreDataStack.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (CoreDataStack*) dataStore {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dataStore = [CoreDataStack stackWithStoreFilename: @"Data.sqlite"];
    });
    
    return _dataStore;
}

@end

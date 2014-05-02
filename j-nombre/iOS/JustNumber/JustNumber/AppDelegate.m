//
//  AppDelegate.m
//  JustNumber
//
//  Created by Paul de Lange on 22/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "AppDelegate.h"

#import "CoreDataStack.h"

#import "LifeBank.h"
#import "ContentLock.h"

#import <AdColony/AdColony.h>

NSManagedObjectContext * const NSManagedObjectContextGetMain(void) {
    AppDelegate* del = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    CoreDataStack* stack = del.dataStore;
    return stack.mainQueueManagedObjectContext;
}

@interface AppDelegate () <AdColonyDelegate>

@end

@implementation AppDelegate

- (CoreDataStack*) dataStore {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dataStore = [CoreDataStack initAppDomain: @"User" userDomain: @"Data"];
    });
    
    return _dataStore;
}

#pragma mark - UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if( [ContentLock tryLock] ) {   //Don't bother if we are unlocked
        [AdColony configureWithAppID: @"app58f910a3d6a944b095"
                             zoneIDs: @[@"vz153675589c3349788c"]
                            delegate: self
#if DEBUG
                             logging: YES];
#else
                             logging: NO];
#endif
    }
    
    return YES;
}

- (void) application:(UIApplication *)application didUpdateToVersion: (NSString*) newVersion fromVersion: (NSString*) previousVersion {
    if( !previousVersion ) {
        //First install
    }
}

#pragma mark - AdColonyDelegate
- ( void ) onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString*) zoneID {
    
}

- ( void ) onAdColonyV4VCReward:(BOOL)success currencyName:(NSString*)currencyName currencyAmount:(int)amount inZone:(NSString*)zoneID {
    [LifeBank addLives: amount];
}

@end

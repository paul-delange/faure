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
#import "ReceiptValidator.h"

#import <AdColony/AdColony.h>
#import <FacebookSDK/FacebookSDK.h>

@import StoreKit;

#define kAlertViewTagMustGetReceipt 444

NSManagedObjectContext * const NSManagedObjectContextGetMain(void) {
    AppDelegate* del = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    CoreDataStack* stack = del.dataStore;
    return stack.mainQueueManagedObjectContext;
}

@interface AppDelegate () <AdColonyDelegate, UIAlertViewDelegate>

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
    
    NSURL* receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    if( !isValidReceipt(receiptURL) ) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"Not Verified"
                                                        message: @"This version of the app was not downloaded from the app store. Please push OK to verify the app with your Apple account. Make sure it is a Sandbox account!"
                                                       delegate: self
                                              cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:  nil];
        alert.tag = kAlertViewTagMustGetReceipt;
        [alert show];
    }
    
    return YES;
}

- (void) application:(UIApplication *)application didUpdateToVersion: (NSString*) newVersion fromVersion: (NSString*) previousVersion {
    if( !previousVersion ) {
        //First install
    }
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL: url sourceApplication: sourceApplication fallbackHandler:^(FBAppCall *call) {
        DLog(@"Unhandled deep link: %@", url);
    }];
}

#pragma mark - AdColonyDelegate
- ( void ) onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString*) zoneID {
    
}

- ( void ) onAdColonyV4VCReward:(BOOL)success currencyName:(NSString*)currencyName currencyAmount:(int)amount inZone:(NSString*)zoneID {
    [LifeBank addLives: amount];
}

#pragma mark - SKRequestDelegate
- (void)requestDidFinish:(SKRequest *)request {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"All Done"
                                                    message: @"Great! Now you can continue."
                                                   delegate: nil
                                          cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                          otherButtonTitles: nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if( alertView.tag == kAlertViewTagMustGetReceipt ) {
        SKReceiptRefreshRequest* refresh = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties: nil];
        refresh.delegate = (id<SKRequestDelegate>)self;
        [refresh start];
    }
}

@end

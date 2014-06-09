//
//  AppDelegate.m
//  JustNumber
//
//  Created by Paul de Lange on 22/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "AppDelegate.h"

#import "GameViewController+Animations.h"

#import "CoreDataStack.h"

#import "LifeBank.h"
#import "ContentLock.h"
#import "ReceiptValidator.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#import <AdColony/AdColony.h>
#import <FacebookSDK/FacebookSDK.h>

#import "Chartboost.h"

#define MINUTES_TO_WAIT_FOR_FREE_LIVES  30

@import StoreKit;

#define kAlertViewTagMustGetReceipt 444

NSManagedObjectContext * const NSManagedObjectContextGetMain(void) {
    AppDelegate* del = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    CoreDataStack* stack = del.dataStore;
    return stack.mainQueueManagedObjectContext;
}

@interface AppDelegate () <AdColonyDelegate, UIAlertViewDelegate, ChartboostDelegate>

@end

@implementation AppDelegate

- (UILocalNotification*) rechargeNotification {
    NSArray* notifs = [UIApplication sharedApplication].scheduledLocalNotifications;
    return notifs.lastObject;
}

- (CoreDataStack*) dataStore {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dataStore = [CoreDataStack initAppDomain: @"User" userDomain: @"Data"];
    });
    
    return _dataStore;
}

- (FBSession*) facebookSession {
    if( !_facebookSession ) {
        _facebookSession = [FBSession new];
        if( _facebookSession.state == FBSessionStateCreatedTokenLoaded ) {
            [_facebookSession openWithCompletionHandler: nil];
        }
    }
    return _facebookSession;
}

#pragma mark - NSObject
- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark - UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[GAI sharedInstance] setTrackUncaughtExceptions: YES];
    [[GAI sharedInstance] trackerWithTrackingId: @"UA-51633568-1"];
    
    [Chartboost startWithAppId:@"538599bec26ee44403321df0" appSignature:@"929ab7ea551776277d88bf26fdb2cb656dae7ea8" delegate: self];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(coinValueChanged:)
                                                 name: kCoinPurseValueDidChangeNotification
                                               object: nil];
    
    if( launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] ) {
        [self application: application didReceiveLocalNotification: launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]];
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

- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [LifeBank addLives: LIVES_WHEN_WAITING];
    
    NSString* msg = [NSString localizedStringWithFormat: NSLocalizedString(@"+%d new lives!", @""), LIVES_WHEN_WAITING];
    [self.window.rootViewController animateMessage: msg
                                        completion: nil];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *) url {
    
    NSString *urlString = [url absoluteString];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // setCampaignParametersFromUrl: parses Google Analytics campaign ("UTM")
    // parameters from a string url into a Map that can be set on a Tracker.
    GAIDictionaryBuilder *hitParams = [[GAIDictionaryBuilder alloc] init];
    
    // Set campaign data on the map, not the tracker directly because it only
    // needs to be sent once.
    [hitParams setCampaignParametersFromUrl:urlString];
    
    // Campaign source is the only required campaign field. If previous call
    // did not set a campaign source, use the hostname as a referrer instead.
    if(![hitParams valueForKey:kGAICampaignSource] && [url host].length !=0) {
        // Set campaign data on the map, not the tracker.
        [hitParams setValue: @"referrer" forKey: kGAICampaignMedium];
        [hitParams setValue: [url host] forKey: kGAICampaignSource];
    }
    
    [tracker send: [[[GAIDictionaryBuilder createAppView] setAll: [hitParams build]] build]];
    
    return YES;
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
    application.applicationIconBadgeNumber = 0;
    
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActiveWithSession: self.facebookSession];
}

- (void) applicationWillTerminate:(UIApplication *)application {
    [self.facebookSession close];
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

#pragma mark - ChartboostDelegate
-(void) didDismissMoreApps {
    [[Chartboost sharedChartboost] cacheMoreApps: CBLocationHomeScreen];
}

- (void) didFailToLoadMoreApps:(CBLoadError)error {
    NSString* (^toString)(CBLoadError) = ^(CBLoadError error) {
        switch (error) {
            case CBLoadErrorInternal:
                return @"CBLoadErrorInternal";
            case CBLoadErrorInternetUnavailable:
                return @"CBLoadErrorInternetUnavailable";
            case CBLoadErrorTooManyConnections:
                return @"CBLoadErrorTooManyConnections";
            case CBLoadErrorWrongOrientation:
                return @"CBLoadErrorWrongOrientation";
            case CBLoadErrorFirstSessionInterstitialsDisabled:
                return @"CBLoadErrorFirstSessionInterstitialsDisabled";
            case CBLoadErrorNetworkFailure:
                return @"CBLoadErrorNetworkFailure";
            case CBLoadErrorNoAdFound:
                return @"CBLoadErrorNoAdFound";
            case CBLoadErrorSessionNotStarted:
                return @"CBLoadErrorSessionNotStarted";
            case CBLoadErrorAgeGateFailure:
                return @"CBLoadErrorAgeGateFailure";
            case CBLoadErrorUserCancellation:
                return @"CBLoadErrorUserCancellation";
        }
    };
    
    DLog(@"Charboost failure: %@", toString(error));
}

#pragma mark - Notifications
- (void) coinValueChanged: (NSNotification*) notification {
    if( [LifeBank count] <= 0 ) {
        
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        if( !delegate.rechargeNotification ) {
            UILocalNotification* localNotification = [UILocalNotification new];
            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow: MINUTES_TO_WAIT_FOR_FREE_LIVES * 60];
            localNotification.alertBody = [NSString localizedStringWithFormat: NSLocalizedString(@"+%d lives available!", @""), LIVES_WHEN_WAITING];
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            localNotification.applicationIconBadgeNumber = LIVES_WHEN_WAITING;
            [[UIApplication sharedApplication] scheduleLocalNotification: localNotification];
        }
    }
}

@end

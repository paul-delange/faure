//
//  AppDelegate.m
//  Les Sexperts
//
//  Created by Paul De Lange on 28/02/14.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "AppDelegate.h"

#import "CoreDataStack.h"
#import "Question.h"
#import "Joke.h"
#import "Advice.h"

#import "ReceiptValidator.h"

#import "JokeViewController.h"
#import "AdviceViewController.h"
#import "MZFormSheetController.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#import <Parse/Parse.h>
#import <StoreKit/StoreKit.h>
#import <AdColony/AdColony.h>

#define kUserPreferenceHasShuffledQuestionsKey  @"questions_shuffled"

#define kAlertViewTagMustGetReceipt 444
#define kAlertViewTagOptInPushNotifications 445

NSString * const NSUserDefaultsWantsPushNotificationsKey = @"WantsPushNotifications";

@interface AppDelegate () <AdColonyDelegate, UIAlertViewDelegate>

@end

@implementation AppDelegate

- (BOOL) displayNewJokeViewController: (Joke*) joke {
    if( !joke ) {
        NSManagedObjectContext* context = kMainManagedObjectContext();
        NSParameterAssert(context);
        
        NSPredicate* isRemotePredicate = [NSPredicate predicateWithFormat: @"remoteID != nil"];
        NSPredicate* hasNoBeenDisplayedPredicate = [NSPredicate predicateWithFormat: @"isNew = YES"];
        NSPredicate* predicate = [NSCompoundPredicate andPredicateWithSubpredicates: @[isRemotePredicate, hasNoBeenDisplayedPredicate]];
        
        NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName: @"Joke"];
        [request setPredicate: predicate];
        
        NSError* error;
        NSArray* results = [context executeFetchRequest: request error: &error];
        DLogError(error);
        
        if( [results count] ) {
            joke = results[0];
        }
    }
    
    if( joke ) {
        
        UIStoryboard* storyboard = self.window.rootViewController.storyboard;
        JokeViewController* jokeVC = (JokeViewController*)[storyboard instantiateViewControllerWithIdentifier: @"JokeViewController"];
        jokeVC.joke = joke;
        jokeVC.title = NSLocalizedString(@"New Joke", @"");
        
        UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController: jokeVC];
        
        MZFormSheetController* formSheet = [[MZFormSheetController alloc] initWithViewController: navVC];
        formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
        formSheet.presentedFormSheetSize = CGSizeMake(300., 360.);
        formSheet.didTapOnBackgroundViewCompletionHandler = ^(CGPoint location) {
            [self.window.rootViewController mz_dismissFormSheetControllerAnimated: YES completionHandler: NULL];
        };
        [self.window.rootViewController mz_presentFormSheetController: formSheet
                                                             animated: YES
                                                    completionHandler:^(MZFormSheetController *formSheetController) {
                                                        [UIApplication sharedApplication].applicationIconBadgeNumber--;
                                                    }];
        
        return YES;
    }
    
    return NO;
}

- (BOOL) displayNewAdviceViewController: (Advice*) advice {
    if( !advice ) {
        NSManagedObjectContext* context = kMainManagedObjectContext();
        NSParameterAssert(context);
        
        NSPredicate* isRemotePredicate = [NSPredicate predicateWithFormat: @"remoteID != nil"];
        NSPredicate* hasNoBeenDisplayedPredicate = [NSPredicate predicateWithFormat: @"isNew = YES"];
        NSPredicate* predicate = [NSCompoundPredicate andPredicateWithSubpredicates: @[isRemotePredicate, hasNoBeenDisplayedPredicate]];
        
        NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName: @"Advice"];
        [request setPredicate: predicate];
        
        NSError* error;
        NSArray* results = [context executeFetchRequest: request error: &error];
        DLogError(error);
        
        if( [results count] ) {
            advice = results[0];
        }
    }
    
    if( advice ) {
        
        UIStoryboard* storyboard = self.window.rootViewController.storyboard;
        AdviceViewController* adviceVC = (AdviceViewController*)[storyboard instantiateViewControllerWithIdentifier: @"AdviceViewController"];
        adviceVC.advice = advice;
        adviceVC.title = NSLocalizedString(@"New Advice", @"");
        
        UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController: adviceVC];
        
        MZFormSheetController* formSheet = [[MZFormSheetController alloc] initWithViewController: navVC];
        formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
        formSheet.presentedFormSheetSize = CGSizeMake(300., 360.);
        formSheet.didTapOnBackgroundViewCompletionHandler = ^(CGPoint location) {
            [self.window.rootViewController mz_dismissFormSheetControllerAnimated: YES completionHandler: NULL];
        };
        [self.window.rootViewController mz_presentFormSheetController: formSheet
                                                             animated: YES
                                                    completionHandler: ^(MZFormSheetController *formSheetController) {
                                                        [UIApplication sharedApplication].applicationIconBadgeNumber--;
                                                    }];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.dataStack = [CoreDataStack stackWithStoreFilename: @"Data"];
    
    
#if !PAID_VERSION
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-50743104-3"];
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
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
    
    [AdColony configureWithAppID: @"app62e13e977a034655a5"
                         zoneIDs: @[@"vzd5640bc5e87746d083"]
                        delegate: self
#if DEBUG
                         logging: YES];
#else
logging: NO];
#endif
    
    [Parse setApplicationId:@"POWmewr6nC2slltKs70kxbdsscYQo4A56xcGikbt"
                  clientKey:@"vW4Ib2RfvCqIxMH2MEem3Yr1FoqmDnGCEhrgm7KM"];
    
    PFInstallation* installation = [PFInstallation currentInstallation];
    [installation setValue: self.dataStack.dataLanguage forKey: @"language"];
    [installation saveInBackground];
    
    //If the user has responded somewhere, ask for this
    if( [[NSUserDefaults standardUserDefaults] boolForKey: NSUserDefaultsWantsPushNotificationsKey] ) {
        [application registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];
    }
    
#endif
    
    if( ![[NSUserDefaults standardUserDefaults] boolForKey: kUserPreferenceHasShuffledQuestionsKey] ) {
        
        [Question resetHistoryAndShuffle];
        
        [[NSUserDefaults standardUserDefaults] setBool: YES forKey: kUserPreferenceHasShuffledQuestionsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return YES;
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
    if( ![self displayNewJokeViewController: nil] ) {
        [self displayNewAdviceViewController: nil];
    }
}

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSString *urlString = [url absoluteString];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // setCampaignParametersFromUrl: parses Google Analytics campaign ("UTM")
    // parameters from a string url into a Map that can be set on a Tracker.
    GAIDictionaryBuilder *hitParams = [[GAIDictionaryBuilder alloc] init];
    
    // Set campaign data on the map, not the tracker directly because it only
    // needs to be sent once.
    [[hitParams setCampaignParametersFromUrl:urlString] build];
    
    // Campaign source is the only required campaign field. If previous call
    // did not set a campaign source, use the hostname as a referrer instead.
    if(![hitParams valueForKey:kGAICampaignSource] && [url host].length !=0) {
        // Set campaign data on the map, not the tracker.
        [hitParams setValue: @"referrer" forKey: kGAICampaignMedium];
        [hitParams setValue: [url host] forKey: kGAICampaignSource];
    }
    
    GAIDictionaryBuilder* viewBuilder = [GAIDictionaryBuilder createAppView];
    [viewBuilder setAll: [hitParams build]];
    
    [tracker send: [viewBuilder build]];
    
    return YES;
}

- (void) application:(UIApplication *)application willUpdateToVersion:(NSString *)newVersion fromVersion:(NSString *)previousVersion {
    
    if(!previousVersion) {
        
        /* HACK
         *
         * I didn't implement this category from the first version so I don't know if this is a fresh install or an update from a version
         * that didn't have version tracking before.
         *
         * To fix that I'm going to look for a plist property instead
         */
        
        BOOL isUpgradeFromUntrackedVersion = [[NSUserDefaults standardUserDefaults] objectForKey: kUserPreferenceHasShuffledQuestionsKey] ? YES : NO;
        
        if( isUpgradeFromUntrackedVersion ) {
            NSString* title = NSLocalizedString(@"New!", @"");
            NSString* msg = NSLocalizedString(@"Would you like to receive exlusive jokes and advice via regular notifications?", @"");
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                            message: msg
                                                           delegate: self
                                                  cancelButtonTitle: NSLocalizedString(@"No thanks", @"")
                                                  otherButtonTitles: NSLocalizedString(@"Yes", @""), nil];
            alert.tag = kAlertViewTagOptInPushNotifications;
            [alert show];
        }
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    NSString* jokeID = userInfo[@"jid"];
    NSString* adviceID = userInfo[@"aid"];
    
    if( jokeID ) {
        
        Joke* joke = [Joke copyWithAPSDictionary: userInfo];
        
        if( joke ) {
            DLog(@"Already had joke %@", joke);
            completionHandler(UIBackgroundFetchResultNoData);
        }
        else {
            PFQuery *query = [PFQuery queryWithClassName:@"Joke"];
            [query getObjectInBackgroundWithId: jokeID block:^(PFObject *joke, NSError *error) {
                if( error ) {
                    DLogError(error);
                    application.applicationIconBadgeNumber++;
                    completionHandler(UIBackgroundFetchResultFailed);
                }
                else {
                    Joke* newJoke = [Joke newWithPFObject: joke];
                    DLog(@"New Joke: %@", newJoke);
                    completionHandler(UIBackgroundFetchResultNewData);
                    
                    if( [application applicationState] == UIApplicationStateActive )
                        [self displayNewJokeViewController: newJoke];
                }
            }];
        }
    }
    else if ( adviceID ) {
        Advice* advice = [Advice copyWithAPSDictionary: userInfo];
        
        if( advice ) {
            DLog(@"Already had advice %@", advice);
            completionHandler(UIBackgroundFetchResultNoData);
        }
        else {
            PFQuery *query = [PFQuery queryWithClassName:@"Advice"];
            [query getObjectInBackgroundWithId: adviceID block:^(PFObject *advice, NSError *error) {
                if( error ) {
                    DLogError(error);
                    application.applicationIconBadgeNumber++;
                    completionHandler(UIBackgroundFetchResultFailed);
                }
                else {
                    Advice* newAdvice = [Advice newWithPFObject: advice];
                    DLog(@"New ADvice: %@", newAdvice);
                    completionHandler(UIBackgroundFetchResultNewData);
                    
                    if( [application applicationState] == UIApplicationStateActive )
                        [self displayNewAdviceViewController: newAdvice];
                }
            }];
        }
    }
    else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

#pragma mark - AdColonyDelegate
- ( void ) onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString*) zoneID {
    
}

- ( void ) onAdColonyV4VCReward:(BOOL)success currencyName:(NSString*)currencyName currencyAmount:(int)amount inZone:(NSString*)zoneID {
    
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
    switch (alertView.tag) {
        case kAlertViewTagMustGetReceipt:
        {
            SKReceiptRefreshRequest* refresh = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties: nil];
            refresh.delegate = (id<SKRequestDelegate>)self;
            [refresh start];
            break;
        }
        case kAlertViewTagOptInPushNotifications:
        {
            if( alertView.cancelButtonIndex == buttonIndex ) {
                [[NSUserDefaults standardUserDefaults] setBool: NO forKey: NSUserDefaultsWantsPushNotificationsKey];
            }
            else {
                UIApplication* application = [UIApplication sharedApplication];
                [application registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];
                
                [[NSUserDefaults standardUserDefaults] setBool: YES forKey: NSUserDefaultsWantsPushNotificationsKey];
            }
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            break;
        }
        default:
            break;
    }
}

@end

NSString * const kAppName() {
    NSDictionary* infoDict = [[NSBundle mainBundle] localizedInfoDictionary];
    return [infoDict objectForKey: (id)kCFBundleNameKey];
}

NSManagedObjectContext * kMainManagedObjectContext(void) {
    NSCParameterAssert([NSThread isMainThread]);
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    CoreDataStack* stack = delegate.dataStack;
    return stack.mainQueueManagedObjectContext;
}

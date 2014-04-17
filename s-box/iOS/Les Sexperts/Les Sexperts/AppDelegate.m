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

#import <StoreKit/StoreKit.h>

#import <AdColony/AdColony.h>

#define kUserPreferenceHasShuffledQuestionsKey  @"questions_shuffled"

#define kAlertViewTagMustGetReceipt 444

@interface AppDelegate () <AdColonyDelegate, UIAlertViewDelegate>

@end

@implementation AppDelegate

#pragma mark - UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.dataStack = [CoreDataStack stackWithStoreFilename: @"ContentLibrary.sqlite"];
    
    if( ![[NSUserDefaults standardUserDefaults] boolForKey: kUserPreferenceHasShuffledQuestionsKey] ) {
        
        [Question resetHistoryAndShuffle];
        
        [[NSUserDefaults standardUserDefaults] setBool: YES forKey: kUserPreferenceHasShuffledQuestionsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
#if PAID_VERSION
/*#if !DEBUG
    NSURL* receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    if( ![[NSFileManager defaultManager] fileExistsAtPath: [receiptURL absoluteString]] ) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"Not Verified"
                                                        message: @"This version of the app was not downloaded from the app store. Please push OK to verify the app with your Apple account."
                                                       delegate: self
                                              cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:  nil];
        alert.tag = kAlertViewTagMustGetReceipt;
        [alert show];
    }
#endif*/
#else
    [AdColony configureWithAppID: @"app62e13e977a034655a5"
                         zoneIDs: @[@"vzd5640bc5e87746d083", @"vz51c5cf827bd54c548a"]
                        delegate: self
#if DEBUG
                         logging: YES];
#else
                         logging: NO];
#endif
#endif
    
    return YES;
}

#pragma mark - AdColonyDelegate
- ( void ) onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString*) zoneID {
    
}

- ( void ) onAdColonyV4VCReward:(BOOL)success currencyName:(NSString*)currencyName currencyAmount:(int)amount inZone:(NSString*)zoneID {
    
}
#pragma mark - SKRequestDelegate
- (void)requestDidFinish:(SKRequest *)request {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"All Done"
                                                    message: @"Great! Now you can continue. Restart the app to enable all features."
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

NSManagedObjectContext * kMainManagedObjectContext(void) {
    NSCParameterAssert([NSThread isMainThread]);
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    CoreDataStack* stack = delegate.dataStack;
    return stack.mainQueueManagedObjectContext;
}
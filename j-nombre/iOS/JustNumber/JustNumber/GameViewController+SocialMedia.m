//
//  GameViewController+SocialMedia.m
//  JustNumber
//
//  Created by Paul de Lange on 10/05/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "GameViewController+SocialMedia.h"
#import "GameViewController+Animations.h"

#import "Question.h"

#import "CoreDataStack.h"
#import "AppDelegate.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"

#import <FacebookSDK/FacebookSDK.h>

@import Accounts;

@implementation UIViewController (SocialMedia)

- (FBSession*) facebookSession {
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return delegate.facebookSession;
}

- (void) shareQuestion: (Question*) question on:(NSString *)serviceType completion:(void (^)(NSError *))completion {
    NSParameterAssert([serviceType isEqualToString: SLServiceTypeFacebook] || [serviceType isEqualToString: SLServiceTypeTwitter]);
    NSParameterAssert(completion);
    
    NSString* lang = [NSManagedObjectContextGetMain().locale objectForKey: NSLocaleLanguageCode];
    [[[GAI sharedInstance] defaultTracker] send: [[GAIDictionaryBuilder createEventWithCategory: lang
                                                                                         action: [NSString stringWithFormat: @"Help - %@", serviceType]
                                                                                          label: [question.identifier stringValue]
                                                                                          value: nil] build]];
    
    if( [serviceType isEqualToString: SLServiceTypeTwitter] ) {
        if( [SLComposeViewController isAvailableForServiceType: serviceType] ) {
            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType: serviceType];
            
            NSString* format = NSLocalizedString(@"%@. Anyone know the answer?", @"Twitter");
            NSString* msg = [NSString localizedStringWithFormat: format, question.text];
            
            //  Set the initial body of the Tweet
            [tweetSheet setInitialText: msg];
            [tweetSheet addURL:[NSURL URLWithString: kAppStoreURL()]];
            tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil);
                });
            };
            
            [self presentViewController:tweetSheet animated:NO completion: NULL];
        }
        else {
            NSString* title = NSLocalizedString(@"Twitter Not Configured", @"");
            NSString* msg = NSLocalizedString(@"Please navigate to your device's Settings app & add a Twitter account", @"");
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                            message: msg
                                                           delegate: nil
                                                  cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles: nil];
            [alert show];
            completion(nil);
        }
    }
    else if( [serviceType isEqualToString: SLServiceTypeFacebook] ) {
        FBSession* session = [self facebookSession];
        if( !session.isOpen ) {
            [session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                if( session.isOpen ) {
                    [self shareQuestion: question on: serviceType completion: completion];
                }
                else {
                    NSString* title = NSLocalizedString(@"Facebook Error", @"");
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                                    message: [error localizedDescription]
                                                                   delegate: nil
                                                          cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                                          otherButtonTitles: nil];
                    [alert show];
                    DLogError(error);
                }
            }];
            return;
        }
        
        //https://developers.facebook.com/docs/ios/share
        
        FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
        params.link = [NSURL URLWithString: kAppStoreURL()];
        params.name = kAppName();
        params.caption = question.text;
        params.description = NSLocalizedString(@"I need your help with this one because it isn't what I thought... Any ideas?", @"");
        
        // If the Facebook app is installed and we can present the share dialog
        if ([FBDialogs canPresentShareDialogWithParams:params]) {
            [FBDialogs presentShareDialogWithLink:params.link
                                          handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                              if(error) {
                                                  // An error occurred, we need to handle the error
                                                  // See: https://developers.facebook.com/docs/ios/errors
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      completion(error);
                                                  });
                                                  DLogError(error);
                                              } else {
                                                  // Success
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      completion(nil);
                                                  });
                                              }
                                          }];
        } else {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         params.name, @"name",
                                         params.caption, @"caption",
                                         params.description, @"description",
                                         [params.link absoluteString], @"link",
                                         nil];
            
            // Show the feed dialog
            [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                                   parameters: dict
                                                      handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                          
                                                          // If an error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              completion(error);
                                                          });
                                                          DLogError(error);
                                                          
                                                      }];
        }
    }
}

- (void) followUsOn:(NSString *)serviceType completion:(void (^)(NSError *))completion {
    NSParameterAssert([serviceType isEqualToString: SLServiceTypeFacebook] || [serviceType isEqualToString: SLServiceTypeTwitter]);
    NSParameterAssert(completion);
    
    //Only available in French
    NSManagedObjectContext* context = NSManagedObjectContextGetMain();
    NSLocale* locale = context.locale;
    
    if( [locale.localeIdentifier rangeOfString: @"fr"].location == NSNotFound ) {
        NSString* title = NSLocalizedString(@"Coming Soon!", @"");
        NSString* msg = NSLocalizedString(@"This isn't available in your language yet. We have noted your interest and will add this feature when enough people ask for it!", @"");
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                        message: msg
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                              otherButtonTitles: nil];
        [alert show];
        
        [[[GAI sharedInstance] defaultTracker] send: [[GAIDictionaryBuilder createEventWithCategory: @"Feature Requests"
                                                                                             action: [NSString stringWithFormat: @"Follow - %@", serviceType]
                                                                                              label: locale.localeIdentifier
                                                                                              value: nil] build]];
        return;
    }
    
    [[[GAI sharedInstance] defaultTracker] send: [[GAIDictionaryBuilder createEventWithCategory: [locale objectForKey: NSLocaleLanguageCode]
                                                                                        action: @"Follow"
                                                                                         label: serviceType
                                                                                          value: nil] build]];
    
    if( [serviceType isEqualToString: SLServiceTypeTwitter] ) {
        if( [SLComposeViewController isAvailableForServiceType: serviceType] ) {
            ACAccountStore* _store = [ACAccountStore new];
            ACAccountType* account = [_store accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierTwitter];
            [_store requestAccessToAccountsWithType: account
                                            options: NULL
                                         completion: ^(BOOL granted, NSError *error) {
                                             if( granted ) {
                                                 NSArray* accounts = [_store accountsWithAccountType: account];
                                                 NSURL* URL = [NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/create.json"];
                                                 NSDictionary* params = @{
                                                                          @"follow" : @"true",
                                                                          @"screen_name" : @"LeJusteNombre"
                                                                          };
                                                 
                                                 SLRequest *request = [SLRequest requestForServiceType: serviceType
                                                                                         requestMethod: SLRequestMethodPOST
                                                                                                   URL: URL
                                                                                            parameters: params];
                                                 
                                                 [request setAccount: [accounts lastObject]];
                                                 [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                                     if(responseData) {
                                                         NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData
                                                                                                                            options: 0
                                                                                                                              error:&error];
                                                         if(responseDictionary) {
                                                             DLog(@"Follow response: %@", responseDictionary);
                                                             
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 completion(nil);
                                                                 
                                                                 [self animateMessage: NSLocalizedString(@"Now following on Twitter!", @"")
                                                                           completion: nil];
                                                             });
                                                         }
                                                         else {
                                                             //follow response error
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 completion(error);
                                                             });
                                                             DLogError(error);
                                                         }
                                                     } else {
                                                         //follow request error
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             completion(error);
                                                         });
                                                         DLogError(error);
                                                     }
                                                 }];
                                             }
                                             else {
                                                 //not granted
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     completion(error);
                                                 });
                                                 DLogError(error);
                                             }
                                         }];
        }
        else {
            NSString* title = NSLocalizedString(@"Twitter Not Configured", @"");
            NSString* msg = NSLocalizedString(@"Please navigate to your device's Settings app & add a Twitter account", @"");
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                            message: msg
                                                           delegate: nil
                                                  cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles: nil];
            [alert show];
            
            completion(nil);
        }
    }
    else if( [serviceType isEqualToString: SLServiceTypeFacebook] ) {
        
        FBSession* session = [self facebookSession];
        if( !session.isOpen ) {
            [session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                if( session.isOpen ) {
                    [self followUsOn: serviceType completion: completion];
                }
                else {
                    NSString* title = NSLocalizedString(@"Facebook Error", @"");
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                                    message: [error localizedDescription]
                                                                   delegate: nil
                                                          cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                                          otherButtonTitles: nil];
                    [alert show];
                    DLogError(error);
                }
            }];
            return;
        }
        
        
        
        //https://developers.facebook.com/docs/reference/opengraph/action-type/og.follows
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"https://www.facebook.com/therightnumber", @"profile",
                                nil
                                ];
        /* make the API call */
        [FBRequestConnection startWithGraphPath:@"/me/og.follows"
                                     parameters:params
                                     HTTPMethod:@"POST"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self animateMessage: NSLocalizedString(@"Now following on Facebook!", @"")
                                                completion: nil];
                                      completion(error);
                                  });
                                  DLogError(error);
                              }];
    }
}

@end

//
//  UIViewController+SocialMedia.m
//  JustNumber
//
//  Created by Paul de Lange on 26/06/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "UIViewController+SocialMedia.h"
#import "GameViewController+Animations.h"

#import <Accounts/Accounts.h>

@implementation UIViewController (SocialMedia)

- (void) followUsOn:(NSString *)serviceType completion:(void (^)(NSError *))completion {
    NSParameterAssert([serviceType isEqualToString: SLServiceTypeTwitter]);
    NSParameterAssert(completion);
    
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
}

@end

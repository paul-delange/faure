//
//  HomeViewController.m
//  Les Sexperts
//
//  Created by Paul De Lange on 28/02/14.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "HomeViewController.h"
#import "MZFormSheetController.h"

#import "Joke.h"
#import "ContentLock.h"

#import "IBActionSheet.h"

#import "GADInterstitial.h"

@import Accounts;
@import Social;
@import MessageUI;

#define HAS_CONFIGURED_FACEBOOK     0

@interface HomeViewController () <IBActionSheetDelegate, MFMailComposeViewControllerDelegate, GADInterstitialDelegate, UINavigationControllerDelegate> {
    GADInterstitial *_interstitial;
}

@property (strong) ACAccountStore* accountStore;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *adviceButton;
@property (weak, nonatomic) IBOutlet UIButton *jokeButton;
@property (weak, nonatomic) IBOutlet UIButton *upgradeButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareBarButtonItem;

@end

@implementation HomeViewController

- (void) showLoadingUI {
    
}

- (void) hideLoadingUI {
    
}

#pragma mark - Actions
- (IBAction)menuPushed:(id)sender {
    IBActionSheet* actionSheet = [[IBActionSheet alloc] initWithTitle: nil
                                                             delegate: self
                                                    cancelButtonTitle: NSLocalizedString(@"Cancel", @"")
                                               destructiveButtonTitle: nil
                                                    otherButtonTitles: nil];
#if HAS_CONFIGURED_FACEBOOK
    if( [SLComposeViewController isAvailableForServiceType: SLServiceTypeFacebook] ) {
        [actionSheet addButtonWithTitle: NSLocalizedString(@"Like", @"")];
    }
#endif
    
    if( [SLComposeViewController isAvailableForServiceType: SLServiceTypeTwitter] ) {
        [actionSheet addButtonWithTitle: NSLocalizedString(@"Follow via Twitter", @"")];
    }
    
    [actionSheet addButtonWithTitle: NSLocalizedString(@"Contact Us", @"")];
    
    [actionSheet showInView: self.view.window];
}

- (IBAction)upgradePushed:(id)sender {
    UIViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier: @"UnlockViewController"];
    
    MZFormSheetController* formSheet = [[MZFormSheetController alloc] initWithViewController: vc];
    formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
    formSheet.presentedFormSheetSize = CGSizeMake(300., 360.);
    formSheet.didTapOnBackgroundViewCompletionHandler = ^(CGPoint location) {
        [self mz_dismissFormSheetControllerAnimated: YES completionHandler: NULL];
    };
    [self mz_presentFormSheetController: formSheet
                               animated: YES
                      completionHandler: NULL];
}

- (IBAction)unwindGame:(UIStoryboardSegue*)sender {
#if !PAID_VERSION
    if( [ContentLock tryLock] ) {
        GADRequest* request = [GADRequest request];
        request.testDevices = @[ GAD_SIMULATOR_ID,
                                 @"5847239deac1f26ea408b154815af621"            //Paul iPhone4
                                 ];
        
        _interstitial = [[GADInterstitial alloc] init];
        _interstitial.adUnitID = @"ca-app-pub-1332160865070772/5237453245";
        _interstitial.delegate = self;
        [_interstitial loadRequest:[GADRequest request]];
    }
#endif
}

#pragma mark - Notifications
- (void) appWasUnlocked: (NSNotification*) notification {
    self.upgradeButton.hidden = YES;
}

#pragma mark - NSObject
+ (void) initialize {
    [super initialize];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark - UIViewController
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if (self) {
        // Custom initialization
        _accountStore = [ACAccountStore new];
        self.navigationController.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(appWasUnlocked:)
                                                     name: ContentLockWasRemovedNotification
                                                   object: nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.playButton setTitle: NSLocalizedString(@"Play", @"") forState: UIControlStateNormal];
    [self.adviceButton setTitle: NSLocalizedString(@"Advice", @"") forState: UIControlStateNormal];
    [self.jokeButton setTitle: NSLocalizedString(@"Jokes", @"") forState: UIControlStateNormal];
    [self.upgradeButton setTitle: NSLocalizedString(@"Become a Sexpert", @"Devenir un(e) Sexpert(e)") forState: UIControlStateNormal];
    
    self.playButton.layer.cornerRadius = 10.;
    self.adviceButton.layer.cornerRadius = 10.;
    self.jokeButton.layer.cornerRadius = 10.;
    self.upgradeButton.layer.cornerRadius = 10.;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.titleLabel.text = kAppName();
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    self.upgradeButton.hidden = ![ContentLock tryLock];
    [self.navigationController setNavigationBarHidden: YES animated: NO];
}

#pragma mark - IBActionSheetDelegate
- (void) actionSheet:(IBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    BOOL hasTwitterButton = [SLComposeViewController isAvailableForServiceType: SLServiceTypeTwitter];
    BOOL hasFacebookButton = [SLComposeViewController isAvailableForServiceType: SLServiceTypeFacebook];
    
#if !HAS_CONFIGURED_FACEBOOK
    hasFacebookButton = NO;
#endif
    
    if( !hasFacebookButton )
        buttonIndex++;
    
    switch (buttonIndex) {
        case 0:{
            //Like
            //  Step 1:  Obtain access to the user's Twitter accounts
            ACAccountType *facebookAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierFacebook];
            
            NSDictionary *FacebookOptions = @{
                                              ACFacebookAppIdKey: @"753907327975175",
                                              ACFacebookPermissionsKey: @[@"publish_action"],
#if DEBUG
                                              ACFacebookAudienceKey : ACFacebookAudienceOnlyMe
#else
                                              ACFacebookAudienceKey : ACFacebookAudienceEveryone
#endif
                                              };
            
            
            [self.accountStore requestAccessToAccountsWithType:facebookAccountType
                                                       options: FacebookOptions
                                                    completion:^(BOOL granted, NSError *error) {
                                                        if (granted) {
                                                            //  Step 2:  Create a request
                                                            NSArray *facebookAccounts = [self.accountStore accountsWithAccountType:facebookAccountType];
                                                            
                                                            //https://developers.facebook.com/docs/reference/opengraph/action-type/og.likes
                                                            NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/og.likes"];
                                                            
                                                            NSDictionary *params = @{
                                                                                     @"object" : @"https://www.facebook.com/pages/Les-Sexperts/234450066742155"
                                                                                     };
                                                            SLRequest *request =
                                                            [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                                               requestMethod:SLRequestMethodPOST
                                                                                         URL:url
                                                                                  parameters:params];
                                                            
                                                            //  Attach an account to the request
                                                            [request setAccount:[facebookAccounts lastObject]];
                                                            
                                                            //  Step 3:  Execute the request
                                                            [request performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                                                
                                                                if (responseData) {
                                                                    if (urlResponse.statusCode >= 200 &&
                                                                        urlResponse.statusCode < 300) {
                                                                        
                                                                        NSError *jsonError;
                                                                        NSDictionary *timelineData =
                                                                        [NSJSONSerialization
                                                                         JSONObjectWithData:responseData
                                                                         options:NSJSONReadingAllowFragments error:&jsonError];
                                                                        if (timelineData) {
                                                                            NSLog(@"Like Response: %@\n", timelineData);
                                                                        }
                                                                        else {
                                                                            // Our JSON deserialization went awry
                                                                            NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                                                                        }
                                                                    }
                                                                    else {
                                                                        // The server did not respond ... were we rate-limited?
                                                                        NSLog(@"The response status code is %ld",
                                                                              (long)urlResponse.statusCode);
                                                                    }
                                                                }
                                                            }];
                                                        }
                                                        else {
                                                            // Access was not granted, or an error occurred
                                                            NSLog(@"%@", [error localizedDescription]);
                                                        }
                                                    }];
            break;
        }
        case 1: //Follow via Twitter
        {
            //https://dev.twitter.com/docs/ios/making-api-requests-slrequest
            
            //  Step 1:  Obtain access to the user's Twitter accounts
            ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierTwitter];
            
            [self.accountStore requestAccessToAccountsWithType:twitterAccountType
                                                       options:NULL
                                                    completion:^(BOOL granted, NSError *error) {
                                                        if (granted) {
                                                            //  Step 2:  Create a request
                                                            NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
                                                            
                                                            //https://dev.twitter.com/docs/api/1.1/post/friendships/create
                                                            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                                                                          @"/1.1/friendships/create.json"];
                                                            
                                                            NSDictionary *params = @{
                                                                                     @"screen_name" : @"LesSexperts",
                                                                                     @"follow" : @"true"
                                                                                     };
                                                            SLRequest *request =
                                                            [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                               requestMethod:SLRequestMethodPOST
                                                                                         URL:url
                                                                                  parameters:params];
                                                            
                                                            //  Attach an account to the request
                                                            [request setAccount:[twitterAccounts lastObject]];
                                                            
                                                            //  Step 3:  Execute the request
                                                            [request performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                                                
                                                                if (responseData) {
                                                                    if (urlResponse.statusCode >= 200 &&
                                                                        urlResponse.statusCode < 300) {
                                                                        
                                                                        NSError *jsonError;
                                                                        NSDictionary *timelineData =
                                                                        [NSJSONSerialization
                                                                         JSONObjectWithData:responseData
                                                                         options:NSJSONReadingAllowFragments error:&jsonError];
                                                                        if (timelineData) {
                                                                            NSLog(@"Follow Response: %@\n", timelineData);
                                                                        }
                                                                        else {
                                                                            // Our JSON deserialization went awry
                                                                            NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                                                                        }
                                                                    }
                                                                    else {
                                                                        // The server did not respond ... were we rate-limited?
                                                                        NSLog(@"The response status code is %ld",
                                                                              (long)urlResponse.statusCode);
                                                                    }
                                                                }
                                                            }];
                                                        }
                                                        else {
                                                            // Access was not granted, or an error occurred
                                                            NSString* format = NSLocalizedString(@"You must give permission to %@. Access this via Twitter in the Settings app", @"");
                                                            NSString* msg = [NSString stringWithFormat: format, kAppName()];
                                                            UIAlertView* alert = [[UIAlertView alloc] initWithTitle: nil
                                                                                                            message: msg
                                                                                                           delegate: nil
                                                                                                  cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                                                                                  otherButtonTitles: nil];
                                                            [alert show];
                                                        }
                                                    }];
            break;
        }
        case 2: //Contact Us
        {
            MFMailComposeViewController* mailVC = [MFMailComposeViewController new];
            mailVC.mailComposeDelegate = self;
            
            NSString* format = NSLocalizedString(@"%@ - Contact iOS", @"");
            [mailVC setSubject: [NSString stringWithFormat: format, kAppName()]];
            [mailVC setToRecipients: @[@"gilmert.bentley@gmail.com"]];
            
            [self presentViewController: mailVC animated: YES completion: NULL];
            break;
        }
        default:
            break;
    }
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated: YES completion: NULL];
}

#pragma mark - GADInterstitialDelegate
- (void) interstitialDidReceiveAd:(GADInterstitial *)ad {
    [_interstitial presentFromRootViewController: self];
    _interstitial.delegate = nil;
    _interstitial = nil;
}

- (void) interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    DLogError(error);
}

#if !PAID_VERSION
#pragma mark - UINavigationControllerDelegate
- (void) navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if( viewController == self && animated ) {
        if( [ContentLock tryLock] ) {
            GADRequest* request = [GADRequest request];
            request.testDevices = @[ GAD_SIMULATOR_ID,
                                     @"5847239deac1f26ea408b154815af621"            //Paul iPhone4
                                     ];
            
            _interstitial = [[GADInterstitial alloc] init];
            _interstitial.adUnitID = @"ca-app-pub-1332160865070772/5237453245";
            _interstitial.delegate = self;
            [_interstitial loadRequest:[GADRequest request]];
        }
    }
}
#endif

@end

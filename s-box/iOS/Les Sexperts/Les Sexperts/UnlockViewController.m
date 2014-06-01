//
//  UnlockViewController.m
//  Les Sexperts
//
//  Created by Paul de Lange on 14/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "UnlockViewController.h"
#import "MZFormSheetController.h"

#import "ContentLock.h"
#import "ReceiptValidator.h"

#import <AdColony/AdColony.h>

@import StoreKit;

typedef NS_ENUM(NSUInteger, kUnlockFeatureType) {
    kUnlockFeatureTypeConseils = 0,
    kUnlockFeatureTypeBlagues,
    kUnlockFeatureTypeNoAdvertisement,
    kUnlockFeatureTypeCount
};

@interface UnlockViewController () <UITableViewDataSource, UITableViewDelegate, SKPaymentTransactionObserver, AdColonyAdDelegate, SKProductsRequestDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *titleImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *restoreButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;

@end

@implementation UnlockViewController

- (void) setCanWatchVideo:(BOOL)canWatchVideo {
    _canWatchVideo = canWatchVideo;

    if( [self isViewLoaded] )
        self.videoButton.enabled = _canWatchVideo;
}

#pragma mark - Action
- (IBAction)restorePushed:(id)sender {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (IBAction)videoPushed:(id)sender {
    [AdColony playVideoAdForZone: @"vzd5640bc5e87746d083"
                    withDelegate: self
                withV4VCPrePopup: YES
                andV4VCPostPopup: NO];
    
    [self.videoButton setHidden: YES];
    [self.activityIndicator startAnimating];
}

- (IBAction)buyPushed:(id)sender {
    BOOL tryingToUnlock = [ContentLock unlockWithCompletion: ^(NSError *error) {
        self.buyButton.hidden = NO;
        [self.activityIndicator stopAnimating];
        if( error ) {
            DLogError(error);
        }
        else {
            [self mz_dismissFormSheetControllerAnimated: YES
                                      completionHandler: NULL];
        }
    }];
    
    if( tryingToUnlock ) {
        self.buyButton.hidden = YES;
        [self.activityIndicator startAnimating];
    }
    else {
        NSString* title = NSLocalizedString(@"Purchases disabled", @"");
        NSString* msg = NSLocalizedString(@"You must enable In-App Purchases in your device Settings app (General>Restrictions>In-App Purchases)", @"");
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                        message: msg
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                              otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - NSObject
- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if( self ) {
        self.screenName = @"Unlock";
        [[SKPaymentQueue defaultQueue] addTransactionObserver: self];
        
        NSSet* productIdentifiers = [NSSet setWithObject: kContentUnlockProductIdentifier];
        SKProductsRequest* productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers: productIdentifiers];
        productsRequest.delegate =  self;
        [productsRequest start];
        
    }
    return self;
}

- (void) dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver: self];
}

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = NSLocalizedString(@"Version Complete", @"Version complète");
    [self.buyButton setTitle: NSLocalizedString(@"Become a Sexpert", @"Devenir un(e) Sexpert(e)") forState: UIControlStateNormal];
    
    self.buyButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.buyButton.layer.borderWidth = 1.;
    self.buyButton.layer.cornerRadius = 10.;
    
    self.restoreButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.restoreButton.layer.borderWidth = 1.;
    self.restoreButton.layer.cornerRadius = 10.;
    
    [self.restoreButton setTitle: NSLocalizedString(@"Restore", @"") forState: UIControlStateNormal];
    
    self.videoButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.videoButton.layer.borderWidth = 1.;
    self.videoButton.layer.cornerRadius = 10.;
    
    [self.videoButton setTitle: NSLocalizedString(@"or watch a free video...", @"") forState: UIControlStateNormal];
    [self.videoButton setTitle: NSLocalizedString(@"...try again later", @"") forState: UIControlStateDisabled];
    
    if( !self.canWatchVideo )
        self.videoButton.enabled = NO;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    self.canWatchVideo = [AdColony isVirtualCurrencyRewardAvailableForZone: @"vzd5640bc5e87746d083"];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kUnlockFeatureTypeCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"UnlockFeatureCellIdentifier"
                                                            forIndexPath: indexPath];
    
    switch (indexPath.item) {
        case kUnlockFeatureTypeConseils:
            cell.imageView.image = [UIImage imageNamed: @"ic_advices"];
            cell.textLabel.text = NSLocalizedString(@"Unlimited Advice", @"");
            cell.detailTextLabel.text = NSLocalizedString(@"Get all the advice you need to get on top. Or bottom...", @"");
            break;
        case kUnlockFeatureTypeBlagues:
            cell.imageView.image = [UIImage imageNamed: @"ic_smyle"];
            cell.textLabel.text = NSLocalizedString(@"Unlimited Jokes", @"");
            cell.detailTextLabel.text = NSLocalizedString(@"In a recent survey, 77% of women found humor attractive", @"");
            break;
        case kUnlockFeatureTypeNoAdvertisement:
            cell.imageView.image = [UIImage imageNamed: @"ic_ads"];
            cell.textLabel.text = NSLocalizedString(@"No Advertising", @"");
            cell.detailTextLabel.text = NSLocalizedString(@"Let nothing get in the way of you becoming a Sexpert!", @"");
            break;
        default:
            break;
    }
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize: cell.textLabel.font.pointSize];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CGRectGetHeight(tableView.bounds) / kUnlockFeatureTypeCount;
}

#pragma mark - SKTransactionObserverDelegate
- (void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for(SKPaymentTransaction* transactioin in transactions) {
        switch (transactioin.transactionState) {
            case SKPaymentTransactionStateRestored:
                [queue finishTransaction: transactioin];
                break;
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error  {
    NSString* title = NSLocalizedString(@"Purchases disabled", @"");
    NSString* msg = NSLocalizedString(@"You must enable In-App Purchases in your device Settings app (General > Restrictions > In-App Purchases)", @"");
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                    message: msg
                                                   delegate: nil
                                          cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                          otherButtonTitles: nil];
    [alert show];
    
    DLogError(error);
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSURL* appReceiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    if( isValidReceipt(appReceiptURL) ) {
        if( isUnlockSubscriptionPurchased() ) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName: ContentLockWasRemovedNotification object: nil];
            
            [self mz_dismissFormSheetControllerAnimated: YES completionHandler: NULL];
        }
        else {
            NSString* msg = NSLocalizedString(@"No purchases found. Please use the Buy button below.", @"");
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle: nil
                                                            message: msg
                                                           delegate: nil
                                                  cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles: nil];
            [alert show];
        }
    }
    else {
        NSError* error = [NSError errorWithDomain: @"In-App"
                                             code: -666     //You are the devil
                                         userInfo: nil];
        DLogError(error);
        
        NSString* title = NSLocalizedString(@"Purchases disabled", @"");
        NSString* msg = NSLocalizedString(@"You must enable In-App Purchases in your device Settings app (General > Restrictions > In-App Purchases)", @"");
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                        message: msg
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                              otherButtonTitles: nil];
        [alert show];
        
    }
}

#pragma mark - SKProductsRequestDelegate
- (void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    SKProduct* product = response.products.lastObject;
    
    if( product ) {
        NSString* price = [NSNumberFormatter localizedStringFromNumber: product.price numberStyle: NSNumberFormatterCurrencyStyle];
        NSString* title = [NSString localizedStringWithFormat: NSLocalizedString(@"Become a Sexpert - %@", @""), price];
        [self.buyButton setTitle: title forState: UIControlStateNormal];
    }
}

#pragma mark - AdColonyAdDelegate
- ( void ) onAdColonyAdStartedInZone:( NSString * )zoneID {
    
}

- ( void ) onAdColonyAdAttemptFinished:(BOOL)shown inZone:( NSString * )zoneID {
    if( shown ) {
        NSUInteger count = [[NSUserDefaults standardUserDefaults] integerForKey: NSUserDefaultsAdviceAvailableCount];
        count++;
        [[NSUserDefaults standardUserDefaults] setInteger: count forKey: NSUserDefaultsAdviceAvailableCount];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self mz_dismissFormSheetControllerAnimated: YES
                                  completionHandler: NULL];
    }
    
    [self.videoButton setHidden: NO];
    [self.activityIndicator stopAnimating];
}


@end

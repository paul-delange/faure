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

@import StoreKit;

typedef NS_ENUM(NSUInteger, kUnlockFeatureType) {
    kUnlockFeatureTypeConseils = 0,
    kUnlockFeatureTypeBlagues,
    kUnlockFeatureTypeNoAdvertisement,
    kUnlockFeatureTypeCount
};

@interface UnlockViewController () <UITableViewDataSource, UITableViewDelegate, SKPaymentTransactionObserver>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *titleImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *restoreButton;

@end

@implementation UnlockViewController

#pragma mark - Action
- (IBAction)restorePushed:(id)sender {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
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
        [[SKPaymentQueue defaultQueue] addTransactionObserver: self];
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
    [self.buyButton setTitle: NSLocalizedString(@"Become a Sexpert - 1,79€", @"Devenir un(e) Sexpert(e)") forState: UIControlStateNormal];
    
    self.buyButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.buyButton.layer.borderWidth = 1.;
    self.buyButton.layer.cornerRadius = 10.;
    
    self.restoreButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.restoreButton.layer.borderWidth = 1.;
    self.restoreButton.layer.cornerRadius = 10.;
    
    [self.restoreButton setTitle: NSLocalizedString(@"Restore", @"") forState: UIControlStateNormal];
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
            //cell.imageView.image = [UIImage imageNamed: @"conseil"];
            cell.textLabel.text = NSLocalizedString(@"Unlimited Advice", @"");
            cell.detailTextLabel.text = NSLocalizedString(@"Get all the advice you need to get on top. Or bottom...", @"");
            break;
        case kUnlockFeatureTypeBlagues:
            cell.imageView.image = nil;
            cell.textLabel.text = NSLocalizedString(@"Unlimited Jokes", @"");
            cell.detailTextLabel.text = NSLocalizedString(@"In a recent survey, 77% of women found humor attractive", @"");
            break;
        case kUnlockFeatureTypeNoAdvertisement:
            cell.imageView.image = nil;
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
        NSParameterAssert(isUnlockSubscriptionPurchased());
        
        [[NSNotificationCenter defaultCenter] postNotificationName: ContentLockWasRemovedNotification object: nil];
        
        [self dismissViewControllerAnimated: YES completion: NULL];
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

@end

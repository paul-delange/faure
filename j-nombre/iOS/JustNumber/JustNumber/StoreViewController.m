//
//  StoreViewController.m
//  JustNumber
//
//  Created by Paul de Lange on 2/05/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "StoreViewController.h"

#import "LifeBank.h"
#import "ContentLock.h"

#import "Level.h"

#import "LifeCountView.h"

#import <AdColony/AdColony.h>

#import "UIImage+ImageEffects.h"

@import StoreKit;

//zone id:  vz153675589c3349788c
//v4vc: v4vccb2bd400a3924698bf

@interface StoreViewController () <SKPaymentTransactionObserver, SKProductsRequestDelegate, AdColonyAdDelegate> {
    SKProduct* _product;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIButton *unlockButton;
@property (weak, nonatomic) IBOutlet UIButton *restorePushed;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *buyTransactionWaiting;
@property (weak, nonatomic) IBOutlet LifeCountView *lifeCountView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *premiumBenefitLabel;
@property (weak, nonatomic) IBOutlet UILabel *becomePremiumLabel;
@property (weak, nonatomic) IBOutlet UIView *premiumBoxView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *unlockActivityIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *restoreActivityIndicator;

@end

@implementation StoreViewController

#pragma mark - Notifications
- (void) lifeCountChanged: (NSNotification*) notification {
    self.lifeCountView.count = [LifeBank count];
}

#pragma mark - Actions
- (IBAction)restorePushed:(UIButton *)sender {
    self.restorePushed.hidden = YES;
    [self.restoreActivityIndicator startAnimating];
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (IBAction)unlockPushed:(id)sender {
    self.unlockButton.hidden = YES;
    [self.unlockActivityIndicator startAnimating];
    
    if( ![ContentLock unlockWithCompletion: ^(NSError *error) {
        
        if( !error ) {
            [self performSegueWithIdentifier: @"UnwindToGame" sender: sender];
        }
        
        DLogError(error);
        
        self.unlockButton.hidden = NO;
        [self.unlockActivityIndicator stopAnimating];
        
    }]) {
        NSString* title = NSLocalizedString(@"Store not available", @"");
        NSString* msg = NSLocalizedString(@"Your device settings are blocking the store. Please enable In-App Purchases and try again.", @"");
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                        message: msg
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                              otherButtonTitles: nil];
        [alert show];
        
        self.unlockButton.hidden = NO;
        [self.unlockActivityIndicator stopAnimating];
    }
}


- (IBAction)videoPushed:(id)sender {
    [AdColony playVideoAdForZone: @"vz153675589c3349788c"
                    withDelegate: self
                withV4VCPrePopup: YES
                andV4VCPostPopup: NO];
}


- (IBAction)buyPushed:(id)sender {
#if !TARGET_IPHONE_SIMULATOR
    NSParameterAssert(_product);
    SKPayment* payment = [SKPayment paymentWithProduct: _product];
    [[SKPaymentQueue defaultQueue] addPayment: payment];
    
    self.buyButton.hidden = YES;
    [self.buyTransactionWaiting startAnimating];
#else
    [LifeBank addLives: 200];
#endif
}

#pragma mark - NSObject
- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if( self) {
        
#if !TARGET_IPHONE_SIMULATOR
        [[SKPaymentQueue defaultQueue] addTransactionObserver: self];
        
        NSSet* productIdentifiers = [NSSet setWithObjects: @"extra_lives", kContentUnlockProductIdentifier, nil];
        SKProductsRequest* productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers: productIdentifiers];
        productsRequest.delegate = self;
        [productsRequest start];
#endif
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(lifeCountChanged:)
                                                     name: kCoinPurseValueDidChangeNotification
                                                   object: nil];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver: self];
}

#pragma mark - UIViewController
- (void) viewDidLoad {
    UIImage* template = [self.backgroundImageView.image imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
    self.backgroundImageView.image = template;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: nil style: UIBarButtonItemStylePlain target: nil action: nil];
    
    self.title = [NSString localizedStringWithFormat: NSLocalizedString(@"Level %@", @""), [Level currentLevel].identifier];
    
    self.titleLabel.text = NSLocalizedString(@"No more lives!", @"");
    
#if !TARGET_IPHONE_SIMULATOR
    self.buyButton.enabled = _product == nil ? NO : YES;
#endif
    
    LifeCountView* countView = [[LifeCountView alloc] initWithFrame: CGRectMake(0, 0, 40, 40)];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView: countView];
    self.navigationItem.rightBarButtonItem = item;
    self.lifeCountView = countView;
    
    self.becomePremiumLabel.text = NSLocalizedString(@"or become a Premium member", @"");
    self.premiumBenefitLabel.text = NSLocalizedString(@"✓ UNLIMITED lives\n✓ NO advertisements", @"");
    [self.unlockButton setTitle: NSLocalizedString(@"Go Premium!", @"") forState: UIControlStateNormal];
    self.premiumBoxView.layer.cornerRadius = 5.;
    
    NSArray* buttons = @[self.buyButton, self.videoButton, self.unlockButton, self.restorePushed];
    for(UIButton* button in buttons) {
        button.backgroundColor = [UIColor whiteColor];
        button.layer.cornerRadius = 5.f;
        button.layer.borderColor = [[UIColor blackColor] CGColor];
        button.layer.borderWidth = 1.;
    }
    
    [self.videoButton setTitle: NSLocalizedString(@"...try again later", @"") forState: UIControlStateDisabled];
    [self.videoButton setTitle: NSLocalizedString(@"Get 10 free lives", @"") forState: UIControlStateNormal];
    [self.restorePushed setTitle: NSLocalizedString(@"Resore previous Purchase", @"") forState: UIControlStateNormal];
    
    self.videoButton.enabled = [AdColony isVirtualCurrencyRewardAvailableForZone: @"vz153675589c3349788c"];
}

#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for(SKPaymentTransaction* transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            {
                //TODO: Check receipt
                
                [LifeBank addLives: 200];
                
                self.buyButton.hidden = NO;
                [self.buyTransactionWaiting stopAnimating];
                [queue finishTransaction: transaction];
                break;
            }
            case SKPaymentTransactionStateRestored:
            {
                [[NSNotificationCenter defaultCenter] postNotificationName: ContentLockWasRemovedNotification object: nil];
                
                [self.navigationController popViewControllerAnimated: YES];
                [queue finishTransaction: transaction];
                break;
            }
            case SKPaymentTransactionStateFailed:
            {
                NSString* title = NSLocalizedString(@"No purchase made", @"");
                NSString* msg = [transaction.error localizedDescription];
                
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                                message: msg
                                                               delegate: nil
                                                      cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                                      otherButtonTitles: nil];
                [alert show];
                
                self.buyButton.hidden = NO;
                [self.buyTransactionWaiting stopAnimating];
                [queue finishTransaction: transaction];
                break;
            }
            default:
                break;
        }
    }
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    if( [ContentLock tryLock] ) {
        self.restorePushed.hidden = NO;
        [self.restoreActivityIndicator stopAnimating];
        
        NSString* msg = NSLocalizedString(@"No purchases found. Please use the Premium button above.", @"");
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: nil
                                                        message: msg
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                              otherButtonTitles: nil];
        [alert show];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName: ContentLockWasRemovedNotification object: nil];
        [self performSegueWithIdentifier: @"UnwindToGame" sender: nil];
        [self.restoreActivityIndicator stopAnimating];
    }
}

- (void) paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    NSString* title = NSLocalizedString(@"Restore failed", @"");
    NSString* message = [error localizedDescription];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                    message: message
                                                   delegate: nil
                                          cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                          otherButtonTitles: nil];
    [alert show];
    
    self.restorePushed.hidden = NO;
    [self.restoreActivityIndicator stopAnimating];
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    for(SKProduct* product in response.products) {
        if( [product.productIdentifier isEqualToString: kContentUnlockProductIdentifier] ) {
            NSString* price = [NSNumberFormatter localizedStringFromNumber: product.price numberStyle: NSNumberFormatterCurrencyStyle];
            NSString* title = [NSString localizedStringWithFormat: NSLocalizedString(@"Go Premium! (%@)", @""), price];
            [self.unlockButton setTitle: title forState: UIControlStateNormal];
        }
        else if([product.productIdentifier isEqualToString: @"extra_lives"] ) {
            _product = product;
        }
    }
    
    if( _product ) {
        self.buyButton.enabled = YES;
        
        NSString* price = [NSNumberFormatter localizedStringFromNumber: _product.price numberStyle: NSNumberFormatterCurrencyStyle];
        NSString* title = [NSString localizedStringWithFormat: NSLocalizedString(@"+200 lives (%@)", @""), price];
        [self.buyButton setTitle: title forState: UIControlStateNormal];
    }
}

#pragma mark - AdColonyAdDelegate
- ( void ) onAdColonyAdStartedInZone:( NSString * )zoneID {
    
}

- ( void ) onAdColonyAdAttemptFinished:(BOOL)shown inZone:( NSString * )zoneID {
    
}


@end

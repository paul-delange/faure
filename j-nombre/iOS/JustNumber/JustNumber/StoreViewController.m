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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *buyTransactionWaiting;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *unlockWaiting;
@property (weak, nonatomic) IBOutlet LifeCountView *lifeCountView;

@end

@implementation StoreViewController

#pragma mark - Notifications
- (void) lifeCountChanged: (NSNotification*) notification {
    self.lifeCountView.count = [LifeBank count];
}

#pragma mark - Actions
- (IBAction)unlockPushed:(id)sender {
    self.unlockButton.hidden = YES;
    [self.unlockWaiting startAnimating];
    
    if( ![ContentLock unlockWithCompletion: ^(NSError *error) {
        
        if( !error ) {
            [self performSegueWithIdentifier: @"UnwindToGame" sender: sender];
        }
        
        DLogError(error);
        
        self.unlockButton.hidden = NO;
        [self.unlockWaiting stopAnimating];
        
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
        [self.unlockWaiting stopAnimating];
    }
}


- (IBAction)videoPushed:(id)sender {
    if( [AdColony isVirtualCurrencyRewardAvailableForZone: @"vz153675589c3349788c"] ) {
    [AdColony playVideoAdForZone: @"vz153675589c3349788c"
                    withDelegate: self
                withV4VCPrePopup: YES
                andV4VCPostPopup: NO];
    }
    else {
        NSString* title = NSLocalizedString(@"Not yet!", @"");
        NSString* msg = NSLocalizedString(@"There is no video available. Check your internet connection and remember only ten videos per day!", @"");
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                        message: msg
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                              otherButtonTitles: nil];
        [alert show];
    }
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
        
        NSSet* productIdentifiers = [NSSet setWithObject: @"extra_lives"];
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

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    _product = response.products.lastObject;
    
    if( _product )
        self.buyButton.enabled = YES;
}

#pragma mark - AdColonyAdDelegate
- ( void ) onAdColonyAdStartedInZone:( NSString * )zoneID {
    
}

- ( void ) onAdColonyAdAttemptFinished:(BOOL)shown inZone:( NSString * )zoneID {
    
}


@end

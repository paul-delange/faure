//
//  StoreViewController.m
//  JustNumber
//
//  Created by Paul de Lange on 2/05/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "StoreViewController.h"

#import "LifeBank.h"

#import "Level.h"

#import "LifeCountView.h"

@import StoreKit;

@interface StoreViewController () <SKPaymentTransactionObserver, SKProductsRequestDelegate> {
    SKProduct* _product;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *buyTransactionWaiting;
@property (weak, nonatomic) IBOutlet LifeCountView *lifeCountView;

@end

@implementation StoreViewController

#pragma mark - Actions
- (IBAction)buyPushed:(id)sender {
#if !TARGET_IPHONE_SIMULATOR
    NSParameterAssert(_product);
    SKPayment* payment = [SKPayment paymentWithProduct: _product];
    [[SKPaymentQueue defaultQueue] addPayment: payment];
    
    self.buyButton.hidden = YES;
    [self.buyTransactionWaiting startAnimating];
#else
    [LifeBank addLives: 200];
    self.lifeCountView.count += 200;
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
    }
    return self;
}

- (void) dealloc {
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
                self.lifeCountView.count += 200;
                
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

@end

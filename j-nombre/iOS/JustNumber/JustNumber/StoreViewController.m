//
//  StoreViewController.m
//  JustNumber
//
//  Created by Paul de Lange on 2/05/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "StoreViewController.h"
#import "GameViewController+Animations.h"

#import "LifeBank.h"
#import "ContentLock.h"

#import "Level.h"
#import "AppDelegate.h"

#import "LifeCountView.h"

#import <AdColony/AdColony.h>

#import "UIImage+ImageEffects.h"
#import "ProductButton.h"

#import "CoreDataStack.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@import StoreKit;

//zone id:  vz153675589c3349788c
//v4vc: v4vccb2bd400a3924698bf

@interface StoreViewController () <SKPaymentTransactionObserver, SKProductsRequestDelegate, AdColonyAdDelegate> {
    NSArray* _productsOrderedByPrice;
    
    dispatch_source_t _timer;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet LifeCountView *lifeCountView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet ProductButton *videoButton;
@property (strong, nonatomic) IBOutletCollection(ProductButton) NSArray *productButtons;
@property (weak, nonatomic) IBOutlet UILabel *timeUntilFreeLabel;
@property (weak, nonatomic) IBOutlet UILabel *freeExplanationLabel;
@property (weak, nonatomic) IBOutlet UILabel *publicityExplanationLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation StoreViewController

- (void) setActive: (BOOL) active {
    if( active ) {
        for(ProductButton* button in self.productButtons) {
            button.hidden = YES;
        }
        [self.activityIndicator startAnimating];
    }
    else {
        for(ProductButton* button in self.productButtons) {
            button.hidden = NO;
        }
        [self.activityIndicator stopAnimating];
    }
}

#pragma mark - Notifications
- (void) lifeCountChanged: (NSNotification*) notification {
    self.lifeCountView.count = [LifeBank count];
}

#pragma mark - Actions
- (IBAction)videoPushed:(id)sender {
    [AdColony playVideoAdForZone: @"vz153675589c3349788c"
                    withDelegate: self
                withV4VCPrePopup: NO
                andV4VCPostPopup: NO];
}


- (IBAction)buyPushed:(id)sender {
    
    if( ![SKPaymentQueue canMakePayments] ) {
        NSString* title = NSLocalizedString(@"Store not available", @"");
        NSString* msg = NSLocalizedString(@"Your device settings are blocking the store. Please enable In-App Purchases and try again.", @"");
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                        message: msg
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                              otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    
    NSInteger index = [self.productButtons indexOfObject: sender];
    index--;
    
#if !TARGET_IPHONE_SIMULATOR
    SKProduct* _product = _productsOrderedByPrice[index];
    
    NSParameterAssert(_product);
    SKPayment* payment = [SKPayment paymentWithProduct: _product];
    [[SKPaymentQueue defaultQueue] addPayment: payment];
    [self setActive: YES];
#else
    int quantities[] = {200, 1500, 5000};
    [LifeBank addLives: quantities[index]];
#endif
}

#pragma mark - NSObject
- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if( self) {
        
        self.screenName = @"Store";
        
#if !TARGET_IPHONE_SIMULATOR
        [[SKPaymentQueue defaultQueue] addTransactionObserver: self];
        
        NSSet* productIdentifiers = [NSSet setWithObjects: @"extra_lives", @"extra_lives_1500", @"extra_lives_5000", nil];
        SKProductsRequest* productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers: productIdentifiers];
        productsRequest.delegate = self;
        [productsRequest start];
#endif
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(lifeCountChanged:)
                                                     name: kCoinPurseValueDidChangeNotification
                                                   object: nil];
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), 0.0 * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(timer, ^{
            AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            UILocalNotification* notification = [delegate rechargeNotification];
            if( notification ) {
                NSInteger remaining = [notification.fireDate timeIntervalSinceNow];
                
                NSInteger seconds = remaining % 60;
                NSInteger minute = (remaining - seconds) / 60;
                
                self.timeUntilFreeLabel.text = [NSString stringWithFormat: NSLocalizedString(@"%02d:%02d", @""), minute, seconds];
            }
            else
                self.timeUntilFreeLabel.text = NSLocalizedString(@"Cooling down...", @"");
            
        });
        dispatch_resume(timer);
        
        _timer = timer;
    }
    return self;
}

- (void) dealloc {
    if( _timer )
        dispatch_source_cancel(_timer);
    
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
    self.timeUntilFreeLabel.text = @"";
    
    LifeCountView* countView = [[LifeCountView alloc] initWithFrame: CGRectMake(0, 0, 40, 40)];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView: countView];
    self.navigationItem.rightBarButtonItem = item;
    self.lifeCountView = countView;
    
    const int quantities[] = {10, 200, 1500, 5000};
    NSString* prices[] = { NSLocalizedString(@"Free!", @""), @"...", @"...", @"..." };
    
    for(ProductButton* button in self.productButtons) {
        NSInteger index = [self.productButtons indexOfObject: button];
        int quantity = quantities[index];
        button.quantity = [NSString localizedStringWithFormat: NSLocalizedString(@"+%d", @"+XXX lives (store)"), quantity];
        button.price = prices[index];
        button.enabled = NO;
        button.tintColor = [UIColor whiteColor];
    }
    
    self.videoButton.enabled = [AdColony isVirtualCurrencyRewardAvailableForZone: @"vz153675589c3349788c"];
    self.publicityExplanationLabel.text = NSLocalizedString(@"1500 and 5000 life packs remove advertisements!", @"");
    
    NSString* lives = [NSString localizedStringWithFormat: NSLocalizedString(@"%d lives", @""), LIVES_WHEN_WAITING];
    NSString* message = [NSString stringWithFormat: NSLocalizedString(@"You will get %@ for free in:", @""), lives];
    
    NSRange livesRange = [message rangeOfString: lives];
    
    NSMutableAttributedString* attr = [[NSMutableAttributedString alloc] initWithString: message
                                                                             attributes: @{ NSFontAttributeName : self.freeExplanationLabel.font }];
    [attr setAttributes: @{ NSFontAttributeName : [UIFont boldSystemFontOfSize: self.freeExplanationLabel.font.pointSize + 3] } range: livesRange];
    self.freeExplanationLabel.attributedText = attr;
    
}

#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for(SKPaymentTransaction* transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            {
                //TODO: Check receipt
                
                NSString* identifier = transaction.payment.productIdentifier;
                SKProduct* product = [[_productsOrderedByPrice filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"productIdentifier = %@", identifier]] lastObject];
                NSInteger index = [_productsOrderedByPrice indexOfObject: product];
                
                int quantities[] = {200, 1500, 5000};
                
                [LifeBank addLives: quantities[index]];
                
                [self animateMessage: NSLocalizedString(@"Ready to go continue!", @"") completion: nil];
                
                if( index > 0 ) {
                    [ContentLock unlock];
                }
                
                [queue finishTransaction: transaction];
                [self setActive: NO];
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
                
                [queue finishTransaction: transaction];
                [self setActive: NO];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    if( [response.invalidProductIdentifiers count] ) {
        NSString* str = [response.invalidProductIdentifiers componentsJoinedByString: @";"];
        
        NSManagedObjectContext* ctx = NSManagedObjectContextGetMain();
        NSLocale* locale = ctx.locale;
        [[[GAI sharedInstance] defaultTracker] send: [[GAIDictionaryBuilder createEventWithCategory: [locale objectForKey: NSLocaleLanguageCode]
                                                                                             action: @"Invalid Products"
                                                                                              label: str
                                                                                              value: nil] build]];
    }
    
    NSMutableArray* validProducts = [NSMutableArray array];
    
    for(SKProduct* product in response.products) {
        if([product.productIdentifier rangeOfString: @"extra_lives"].location != NSNotFound ) {
            [validProducts addObject: product];
        }
    }
    
    [validProducts sortedArrayUsingSelector: @selector(price)];
    _productsOrderedByPrice = [validProducts copy];
    
    for(SKProduct* prod in _productsOrderedByPrice) {
        NSInteger index = [_productsOrderedByPrice indexOfObject: prod] + 1;
        ProductButton* button = [self.productButtons objectAtIndex: index];
        button.price = [NSNumberFormatter localizedStringFromNumber: prod.price numberStyle: NSNumberFormatterCurrencyStyle];
        button.enabled = YES;
    }
}

- (void) request:(SKRequest *)request didFailWithError:(NSError *)error {
    DLogError(error);
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"No purchase made", @"")
                                                    message: [error localizedDescription]
                                                   delegate: nil
                                          cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                          otherButtonTitles: nil];
    [alert show];
    
    [self setActive: NO];
}

#pragma mark - AdColonyAdDelegate
- ( void ) onAdColonyAdStartedInZone:( NSString * )zoneID {
    
}

- ( void ) onAdColonyAdAttemptFinished:(BOOL)shown inZone:( NSString * )zoneID {
    
}


@end

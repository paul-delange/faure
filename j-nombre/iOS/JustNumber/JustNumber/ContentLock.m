//
//  ContentLock.m
//  Les Sexperts
//
//  Created by Paul De Lange on 28/02/14.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "ContentLock.h"

#import <objc/runtime.h>

static const void* kCompletionHandlerAssocationKey = "PurchaseCompletionHandler";

NSString * const kPurchaseWasMadeNotification = @"PurchaseNotification";
NSString * const kContentUnlockProductIdentifier = @"premium_unlock";
NSString * ContentLockWasRemovedNotification = @"ContentLockRemoved";

@import StoreKit;

@implementation ContentLock

+ (BOOL) restoreWithCompletion:(kContentLockRemovedHandler)completionHandler {
#if TARGET_IPHONE_SIMULATOR
    [[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"SimulatorContentLocked"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: ContentLockWasRemovedNotification object: nil];
    completionHandler(NULL);
    return YES;
#else
    if( ![SKPaymentQueue canMakePayments] )
        return NO;
    
    objc_setAssociatedObject(self, kCompletionHandlerAssocationKey, completionHandler, OBJC_ASSOCIATION_COPY);
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
    return YES;
#endif

}

+ (BOOL) unlockWithCompletion: (kContentLockRemovedHandler) completionHandler {
#if TARGET_IPHONE_SIMULATOR
    [[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"SimulatorContentLocked"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: ContentLockWasRemovedNotification object: nil];
    completionHandler(NULL);
    return YES;
#else
    if( ![SKPaymentQueue canMakePayments] )
        return NO;
    
    NSSet* productIdentifiers = [NSSet setWithObject: kContentUnlockProductIdentifier];
    SKProductsRequest* productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers: productIdentifiers];
    productsRequest.delegate =  (id<SKProductsRequestDelegate>)self;
    [productsRequest start];
    
    objc_setAssociatedObject(self, kCompletionHandlerAssocationKey, completionHandler, OBJC_ASSOCIATION_COPY);
    
    return YES;
#endif
}

+ (BOOL) unlock {
#if TARGET_IPHONE_SIMULATOR
    [[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"SimulatorContentLocked"];
#else
    [[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"ContentLock"];
#endif
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName: ContentLockWasRemovedNotification object: nil];
    return YES;
}

+ (BOOL) lock {
    return NO;
}

+ (BOOL) tryLock {
#if TARGET_IPHONE_SIMULATOR
    return ![[NSUserDefaults standardUserDefaults] boolForKey: @"SimulatorContentLocked"];
#else
    return ![[NSUserDefaults standardUserDefaults] boolForKey: @"ContentLock"];
#endif
}

#pragma mark - NSObject
+ (void) load {
    @autoreleasepool {
        [[SKPaymentQueue defaultQueue] addTransactionObserver: (id<SKPaymentTransactionObserver>)self];
    }
}

#pragma mark - SKProductsRequestDelegate
+ (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray* invalid = response.invalidProductIdentifiers;
    
    if( [invalid count] ) {
        NSDictionary* userInfo = @{ @"Invalid Identifiers" : invalid };
        NSError* error = [NSError errorWithDomain: @"In-App"
                                             code: -823
                                         userInfo: userInfo];
        kContentLockRemovedHandler handler = objc_getAssociatedObject(self, kCompletionHandlerAssocationKey);
        objc_setAssociatedObject(self, kCompletionHandlerAssocationKey, nil,  OBJC_ASSOCIATION_COPY);
        
        if( handler )
            handler(error);
        
        DLogError(error);
    }
    else {
        NSParameterAssert([response.products count] == 1);
        SKProduct* product = response.products.lastObject;
        SKPayment* payment = [SKPayment paymentWithProduct: product];
        
        [[SKPaymentQueue defaultQueue] addPayment: payment];
    }
}

+ (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    kContentLockRemovedHandler handler = objc_getAssociatedObject(self, kCompletionHandlerAssocationKey);
    objc_setAssociatedObject(self, kCompletionHandlerAssocationKey, nil,  OBJC_ASSOCIATION_COPY);
    
    if( handler )
        handler(error);
    
    DLogError(error);
}

#pragma mark - SKPaymentTransactionObserver
+ (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for(SKPaymentTransaction* transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStateFailed:
            {
                kContentLockRemovedHandler handler = objc_getAssociatedObject(self, kCompletionHandlerAssocationKey);
                objc_setAssociatedObject(self, kCompletionHandlerAssocationKey, nil,  OBJC_ASSOCIATION_COPY);
                
                if( handler )
                    handler(transaction.error);
                
                [queue finishTransaction: transaction];
                break;
            }
            case SKPaymentTransactionStateRestored:
            case SKPaymentTransactionStatePurchased:
            {
                kContentLockRemovedHandler handler = objc_getAssociatedObject(self, kCompletionHandlerAssocationKey);
                objc_setAssociatedObject(self, kCompletionHandlerAssocationKey, nil,  OBJC_ASSOCIATION_COPY);
                
                [self unlock];
                
                    if( handler )
                        handler(nil);
                
                [queue finishTransaction: transaction];
                break;
            }
            case SKPaymentTransactionStatePurchasing:
                break;
            default:
                break;
        }
    }
}

@end

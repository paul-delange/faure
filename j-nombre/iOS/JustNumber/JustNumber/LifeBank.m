//
//  LifeBank.m
//  94-percentJustNumber
//
//  Created by Paul de Lange on 17/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "LifeBank.h"

@import Security;

/* There are two options here:
 
 1. Keychain
    This is more secure for production code. For this method each addition/subtraction is recorded as a transaction with a monetary figure. The total remaining is then generated from the transaction log. This allows the system to be synchronized via iCloud on iOS 7.0.3+.
 
    Using the keychain also means lives are persisted across uninstalls.

 2. NSUserDefaults
    This is quick and easy for testing but not safe for production code. For this method the accumulated total is saved and access is fast.
 
 */
#define USE_KEYCHAIN    1       //1 - use keychain, 0 - use NSUserDefaults
#define KEYCHAIN_SUPPORTED_BY_iCLOUD    0 //( (&kSecAttrSynchronizable != NULL) && (&kSecAttrSynchronizableAny != NULL) )

// DON'T KNOW HOW TO MERGE ICLOUD CONFLICTS FOR THE KEYCHAIN...

#if !DEBUG && !USE_KEYCHAIN
#error Do not release this code in production
#endif

#if USE_KEYCHAIN

static inline NSString* NSStringFromOSStatus(OSStatus status) {
    switch (status) {
        case errSecSuccess:
            return @"errSecSuccess : No error";
        case errSecUnimplemented:
            return @"errSecUnimplemented : Function or operation not implemented";
        case errSecParam:
            return @"errSecParam : One or more parameters passed to the function were not valid";
        case errSecAllocate:
            return @"errSecAllocate : Failed to allocate memory";
        case errSecNotAvailable:
            return @"errSecNotAvailable : No trust results are available";
        case errSecAuthFailed:
            return @"errSecAuthFailed : Authorization/Authentication failed";
        case errSecDuplicateItem:
            return @"errSecDuplicateItem : The item already exists";
        case errSecItemNotFound:
            return @"errSecItemNotFound : The item cannot be found";
        case errSecInteractionNotAllowed:
            return @"errSecInteractionNotAllowed : Interaction with the Security Server is not allowed";
        case errSecDecode:
            return @"errSecDecode : Unable to decode the provided data";
        default:
            return [NSString stringWithFormat: @"%d : Unknown OSStatus code", (int)status];
    }
}
#else
NSString * NSUserDefaultsCoinsKey = @"Coins";
#endif

NSString * kCoinPurseValueDidChangeNotification = @"CoinPurseValueChanged";

@implementation LifeBank

#if DEBUG
+ (void) set: (NSInteger) lives {
#if USE_KEYCHAIN
    CFMutableDictionaryRef query = CFDictionaryCreateMutable(NULL, 5, NULL, NULL);
    
    CFDictionaryAddValue(query, kSecClass, kSecClassGenericPassword);
    CFDictionaryAddValue(query, kSecAttrAccount, CFSTR("94%"));
    CFDictionaryAddValue(query, kSecAttrService, CFSTR("Coins"));
    CFDictionaryAddValue(query, kSecReturnData, kCFBooleanTrue);
    
    if( KEYCHAIN_SUPPORTED_BY_iCLOUD ) {
        /* This attribute is only available on iOS 7.0.3+. If the user has updated their phone from an earlier version,
         this attribute is false. For this reason we can search for "any" value here */
        CFDictionaryAddValue(query, kSecAttrSynchronizable, kSecAttrSynchronizableAny);
    }
    
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching(query, &result);
    
    if( status == errSecSuccess ) {
        NSArray* transactions = @[@(lives)];
        
        CFMutableDictionaryRef update = CFDictionaryCreateMutable(NULL, 2, NULL, NULL);
        
        CFDataRef data = (__bridge_retained CFDataRef)[NSKeyedArchiver archivedDataWithRootObject: transactions];
        CFDictionaryAddValue(update, kSecValueData, data);
        
        if( KEYCHAIN_SUPPORTED_BY_iCLOUD ) {
            /* Update this while we have the chance */
            CFDictionaryAddValue(update, kSecAttrSynchronizable, kCFBooleanTrue);
        }
        
        CFDictionaryRemoveValue(query, kSecReturnData);
        
        status = SecItemUpdate(query, update);
        if( status != errSecSuccess ) {
            DLog(@"Error adding coins: %@", NSStringFromOSStatus(status));
        }
        
        CFRelease(data);
        CFRelease(update);
    }
    else {
        DLog(@"Failed to add coins: %@", NSStringFromOSStatus(status));
    }
    
    CFRelease(query);
#else
    [[NSUserDefaults standardUserDefaults] setInteger: lives forKey: NSUserDefaultsCoinsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kCoinPurseValueDidChangeNotification
                                                        object: nil];
}
#endif

+ (void) addLives:(NSInteger)coins {
    NSParameterAssert(coins > 0);
    
#if USE_KEYCHAIN
    CFMutableDictionaryRef query = CFDictionaryCreateMutable(NULL, 5, NULL, NULL);
    
    CFDictionaryAddValue(query, kSecClass, kSecClassGenericPassword);
    CFDictionaryAddValue(query, kSecAttrAccount, CFSTR("94%"));
    CFDictionaryAddValue(query, kSecAttrService, CFSTR("Coins"));
    CFDictionaryAddValue(query, kSecReturnData, kCFBooleanTrue);
    
    if( KEYCHAIN_SUPPORTED_BY_iCLOUD ) {
        /* This attribute is only available on iOS 7.0.3+. If the user has updated their phone from an earlier version,
         this attribute is false. For this reason we can search for "any" value here */
        CFDictionaryAddValue(query, kSecAttrSynchronizable, kSecAttrSynchronizableAny);
    }
    
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching(query, &result);
    
    if( status == errSecSuccess ) {
        NSArray* transactions = [NSKeyedUnarchiver unarchiveObjectWithData: (__bridge NSData*)result];
        NSMutableArray* mutableTransactions = [NSMutableArray arrayWithArray: transactions];
        
        [mutableTransactions addObject: @(coins)];
        
        CFMutableDictionaryRef update = CFDictionaryCreateMutable(NULL, 2, NULL, NULL);
        
        CFDataRef data = (__bridge_retained CFDataRef)[NSKeyedArchiver archivedDataWithRootObject: mutableTransactions];
        CFDictionaryAddValue(update, kSecValueData, data);
        
        if( KEYCHAIN_SUPPORTED_BY_iCLOUD ) {
            /* Update this while we have the chance */
            CFDictionaryAddValue(update, kSecAttrSynchronizable, kCFBooleanTrue);
        }
        
        CFDictionaryRemoveValue(query, kSecReturnData);
        
        status = SecItemUpdate(query, update);
        if( status != errSecSuccess ) {
            DLog(@"Error adding coins: %@", NSStringFromOSStatus(status));
        }
        
        CFRelease(data);
        CFRelease(update);
    }
    else {
        DLog(@"Failed to add coins: %@", NSStringFromOSStatus(status));
    }
    
    CFRelease(query);
#else
    NSUInteger count = [self count];
    count += coins;
    
    [[NSUserDefaults standardUserDefaults] setInteger: count forKey: NSUserDefaultsCoinsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kCoinPurseValueDidChangeNotification
                                                        object: nil];
}

+ (void) subtractLives: (NSInteger) coins {
    NSAssert(coins <= [self count], @"Can not subtract %d coins from %d", (int)coins, (int)[self count]);

    
#if USE_KEYCHAIN
    CFMutableDictionaryRef query = CFDictionaryCreateMutable(NULL, 5, NULL, NULL);
    
    CFDictionaryAddValue(query, kSecClass, kSecClassGenericPassword);
    CFDictionaryAddValue(query, kSecAttrAccount, CFSTR("94%"));
    CFDictionaryAddValue(query, kSecAttrService, CFSTR("Coins"));
    CFDictionaryAddValue(query, kSecReturnData, kCFBooleanTrue);
    
    if( KEYCHAIN_SUPPORTED_BY_iCLOUD ) {
        /* This attribute is only available on iOS 7.0.3+. If the user has updated their phone from an earlier version,
         this attribute is false. For this reason we can search for "any" value here */
        CFDictionaryAddValue(query, kSecAttrSynchronizable, kSecAttrSynchronizableAny);
    }
    
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching(query, &result);
    
    if( status == errSecSuccess ) {
        NSArray* transactions = [NSKeyedUnarchiver unarchiveObjectWithData: (__bridge NSData*)result];
        NSMutableArray* mutableTransactions = [NSMutableArray arrayWithArray: transactions];
        
        [mutableTransactions addObject: @(-coins)];
        
        CFMutableDictionaryRef update = CFDictionaryCreateMutable(NULL, 2, NULL, NULL);
        
        CFDataRef data = (__bridge_retained CFDataRef)[NSKeyedArchiver archivedDataWithRootObject: mutableTransactions];
        CFDictionaryAddValue(update, kSecValueData, data);
        
        if( KEYCHAIN_SUPPORTED_BY_iCLOUD ) {
            /* Update this while we have the chance */
            CFDictionaryAddValue(update, kSecAttrSynchronizable, kCFBooleanTrue);
        }
        
        CFDictionaryRemoveValue(query, kSecReturnData);
        
        status = SecItemUpdate(query, update);
        if( status != errSecSuccess ) {
            DLog(@"Error adding coins: %@", NSStringFromOSStatus(status));
        }
        
        CFRelease(data);
        CFRelease(update);
    }
    else {
        DLog(@"Failed to add coins: %@", NSStringFromOSStatus(status));
    }
    
    CFRelease(query);
#else
    NSUInteger count = [self count];
    count -= coins;
    
    [[NSUserDefaults standardUserDefaults] setInteger: count forKey: NSUserDefaultsCoinsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
    [[NSNotificationCenter defaultCenter] postNotificationName: kCoinPurseValueDidChangeNotification
                                                        object: nil];
}

+ (NSUInteger) count  {
#if USE_KEYCHAIN
    CFMutableDictionaryRef query = CFDictionaryCreateMutable(NULL, 5, NULL, NULL);
    
    CFDictionaryAddValue(query, kSecClass, kSecClassGenericPassword);
    CFDictionaryAddValue(query, kSecAttrAccount, CFSTR("94%"));
    CFDictionaryAddValue(query, kSecAttrService, CFSTR("Coins"));
    CFDictionaryAddValue(query, kSecReturnData, kCFBooleanTrue);
    
    if( KEYCHAIN_SUPPORTED_BY_iCLOUD ) {
        /* This attribute is only available on iOS 7.0.3+. If the user has updated their phone from an earlier version,
         this attribute is false. For this reason we can search for "any" value here */
        CFDictionaryAddValue(query, kSecAttrSynchronizable, kSecAttrSynchronizableAny);
    }
    
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching(query, &result);
    CFRelease(query);
    
    if( status == errSecSuccess ) {
        NSArray* transactions = [NSKeyedUnarchiver unarchiveObjectWithData: (__bridge NSData*)result];
        NSInteger count = [[transactions valueForKeyPath: @"@sum.self"] integerValue];
        
        CFRelease(result);
        
        if( count < 0 ) {
            //I have a suspicion this can actually happen if the iCloud synchronization lags
            // ie: a user uses all his coins on two devices and then they sync together and there is a negative total...
            NSError* error = [NSError errorWithDomain: @"LifeBank"
                                                 code: -666
                                             userInfo: @{
                                                         @"coins" : @(count),
                                                         NSLocalizedDescriptionKey : @"Negative Coin Value Detected"
                                                         }];
            DLogError(error);
        }
        
        return MAX(count, 0);
    }
    else {
        DLog(@"Error fetching coins count: %@", NSStringFromOSStatus(status));
        return 0;
    }
#else
    return [[NSUserDefaults standardUserDefaults] integerForKey: NSUserDefaultsCoinsKey];
#endif
}

#pragma mark - NSObject
+ (void) initialize {
#if USE_KEYCHAIN
    CFMutableDictionaryRef query = CFDictionaryCreateMutable(NULL, 5, NULL, NULL);
    
    CFDictionaryAddValue(query, kSecClass, kSecClassGenericPassword);
    CFDictionaryAddValue(query, kSecAttrAccount, CFSTR("94%"));
    CFDictionaryAddValue(query, kSecAttrService, CFSTR("Coins"));
    
    if( KEYCHAIN_SUPPORTED_BY_iCLOUD ) {
        /* This attribute is only available on iOS 7.0.3+. If the user has updated their phone from an earlier version,
         this attribute is false. For this reason we can search for "any" value here */
        CFDictionaryAddValue(query, kSecAttrSynchronizable, kSecAttrSynchronizableAny);
    }
    
    OSStatus status = SecItemCopyMatching(query, NULL);
    
    if( status == errSecItemNotFound ) {
        NSArray* defaultCoins = @[@(DEFAULT_LIVES_VALUE)];
        
        CFDataRef data = (__bridge_retained CFDataRef)[NSKeyedArchiver archivedDataWithRootObject: defaultCoins];
        
        if( KEYCHAIN_SUPPORTED_BY_iCLOUD ) {
            CFDictionaryRemoveValue(query, kSecAttrSynchronizable);
            CFDictionaryAddValue(query, kSecAttrSynchronizable, kCFBooleanTrue);
        }
        
        CFDictionaryAddValue(query, kSecValueData, data);
        
        status = SecItemAdd(query, NULL);
        if( status != errSecSuccess ) {
            DLog(@"Error adding initial coins to keychain: %@", NSStringFromOSStatus(status));
        }
        
        CFRelease(data);
    }
    else if( status != errSecSuccess ) {
        DLog(@"Error searching for coins in keychain: %@", NSStringFromOSStatus(status));
    }
    
    CFRelease(query);
    
#else
    NSDictionary* params = @{ NSUserDefaultsCoinsKey : @(DEFAULT_COINS_VALUE) };
    [[NSUserDefaults standardUserDefaults] registerDefaults: params];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
}

@end

//
//  LifeBank
//  JustNumber
//
//  Created by Paul de Lange on 17/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <Foundation/Foundation.h>


#define COST_OF_BAD_RESPONSE        1
#define COST_OF_JOKER               10


#define LIVES_FOR_AD_STOP           50
#define LIVES_WHEN_WAITING          50

#if DEBUG
#define DEFAULT_LIVES_VALUE         7
#else
#define DEFAULT_LIVES_VALUE         200
#endif

extern NSString * kCoinPurseValueDidChangeNotification;

@interface LifeBank : NSObject

/** Add a number of lives to the purse */
+ (void) addLives: (NSInteger) lives;

/** Withdraw a number of lives from the purse */
+ (void) subtractLives: (NSInteger) lives;

/** @return The total number of lives available */
+ (NSUInteger) count;

#if DEBUG
+ (void) set: (NSInteger) lives;
#endif

@end

//
//  LifeBank
//  JustNumber
//
//  Created by Paul de Lange on 17/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <Foundation/Foundation.h>


#define COST_OF_BAD_RESPONSE        1
#define DEFAULT_LIVES_VALUE         7

extern NSString * kCoinPurseValueDidChangeNotification;

@interface LifeBank : NSObject

/** Add a number of lives to the purse */
+ (void) addLives: (NSInteger) lives;

/** Withdraw a number of lives from the purse */
+ (void) subtractLives: (NSInteger) lives;

/** @return The total number of lives available */
+ (NSUInteger) count;

@end

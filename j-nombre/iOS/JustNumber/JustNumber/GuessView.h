//
//  GuessView.h
//  JustNumber
//
//  Created by Paul de Lange on 6/05/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuessView : UIView

@property (assign, nonatomic) BOOL automaticallyFormatsInput;
@property (strong, nonatomic) NSNumber* actualValue;

- (void) addGuess: (NSNumber*) guessValue animated: (BOOL) animated;

@end

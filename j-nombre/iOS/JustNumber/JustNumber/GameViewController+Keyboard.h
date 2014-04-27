//
//  GameViewController+Keyboard.h
//  JustNumber
//
//  Created by Paul de Lange on 27/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController (Keyboard)

/** Add an observer object to monitor keyboard changes.
 
 @params observer The observer object (typically self)
 @params options NSKeyValueObserveringOptionsNew to receive will/did appear notifications and NSKeyValueObservingOptionsOld to receive will/did disappear notifications
 @params context An optional context that isn't used for now
 */
- (void) addKeyboardObserver:(NSObject *)observer options:(NSKeyValueObservingOptions)options context:(void *)context;

/** Remove an observer from keyboard change monitoring */
- (void) removeKeyboardObserver:(NSObject *)observer context:(void *)context;

@end

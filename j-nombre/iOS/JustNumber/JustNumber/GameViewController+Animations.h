//
//  GameViewController+Animations.h
//  JustNumber
//
//  Created by Paul de Lange on 4/06/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "GameViewController.h"

@interface UIViewController (Animations)

- (void) animateMessage: (NSString*) message completion: (void (^)(BOOL finished)) completion;

@end

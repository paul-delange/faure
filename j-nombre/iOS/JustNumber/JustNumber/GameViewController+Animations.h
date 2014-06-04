//
//  GameViewController+Animations.h
//  JustNumber
//
//  Created by Paul de Lange on 4/06/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController (Animations)

- (void) animateCorrectAnswer: (void (^)(BOOL finished)) completion;

@end

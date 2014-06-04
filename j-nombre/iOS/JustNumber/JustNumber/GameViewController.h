//
//  GameViewController.h
//  JustNumber
//
//  Created by Paul de Lange on 27/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Level;

#import "GAITrackedViewController.h"

@interface GameViewController : GAITrackedViewController

@property (strong, nonatomic) Level* level;

@end

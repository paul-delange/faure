//
//  QuizViewController.h
//  Les Sexperts
//
//  Created by Paul de Lange on 4/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GAITrackedViewController.h"

@interface QuizViewController : GAITrackedViewController

@property (weak, nonatomic) IBOutlet UILabel *questionLabel;

@end

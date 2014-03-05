//
//  QuestionViewController.h
//  Les Sexperts
//
//  Created by Paul de Lange on 5/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Question;

@interface QuestionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UITextView *explanationView;

@property (strong) Question* question;

@end

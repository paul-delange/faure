//
//  QuestionViewController.m
//  Les Sexperts
//
//  Created by Paul de Lange on 5/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "QuestionViewController.h"

#import "Question.h"

@interface QuestionViewController ()

@end

@implementation QuestionViewController

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Did you know?", @"");
    
    self.questionLabel.text = self.question.text;
    self.explanationView.text = self.question.explanation;
    
}

@end

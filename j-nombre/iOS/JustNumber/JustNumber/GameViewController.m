//
//  GameViewController.m
//  JustNumber
//
//  Created by Paul de Lange on 27/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "GameViewController.h"

#import "UINumberField.h"

#import "Level.h"
#import "Question.h"
#import "ScoreSheet.h"

@interface GameViewController () <UINumberFieldDelegate>

@property (weak, nonatomic) IBOutlet UINumberField *inputView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewBottomLayoutConstraint;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *numberButtons;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;

@end

@implementation GameViewController

- (void) updateWithQuestion: (Question*) question {
    
    self.questionLabel.text = question.text;
    self.inputView.unitString = question.unit;
    self.inputView.automaticallyFormatsInput = question.formatsValue;
    
    DLog(@"Ans: %@", question.answer);
}

#pragma mark - Actions
- (IBAction)numberPushed:(UIButton *)sender {
    NSInteger index = [self.numberButtons indexOfObject: sender];
    [self.inputView appendInteger: index];
}

- (IBAction)okPushed:(UIButton *)sender {
    Question* question = [self.level nextQuestion];
    
    NSUInteger answer = self.inputView.integerValue;
    
    NSComparisonResult result = [question.answer compare: @(answer)];
    
    switch (result) {
        case NSOrderedAscending:
        {
            NSLog(@"Less");
            break;
        }
        case NSOrderedDescending:
        {
            NSLog(@"More");
            break;
        }
        case NSOrderedSame:
        {
            ScoreSheet* sheet = [ScoreSheet currentScoreSheet];
            BOOL success = [sheet crossOfQuestion: question];
            NSParameterAssert(success);
            
            question = [self.level nextQuestion];
            
            if( question ) {
                [self updateWithQuestion: question];
            }
            else {
                NSLog(@"Level up!");
                self.level = [self.level nextLevel];
                
                if( self.level ) {
                    question = [self.level nextQuestion];
                    NSAssert(question, @"No questions for level %@", self.level);
                    [self updateWithQuestion: question];
                }
                else {
                    NSLog(@"Game over!");
                }
            }
            
            self.inputView.text = @"";
            break;
        }
    }
}

#pragma mark - UIViewController
- (void) viewDidLoad {
    [super viewDidLoad];
    
    NSParameterAssert(self.level);
    
    Question* question = [self.level nextQuestion];
    [self updateWithQuestion: question];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden: NO animated: YES];
    
    [self.inputView becomeFirstResponder];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    //For some reason becomeFirstResponder fails sometimes on viewWillAppear:
    // It looks better there, but catch here if things failed
    if( ![self.inputView isFirstResponder] )
        [self.inputView becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate

#pragma mark - UINumberFieldDelegate
- (void) numberField:(UINumberField *)numberField didChangeToValue:(NSInteger)integerValue {
    
}

@end

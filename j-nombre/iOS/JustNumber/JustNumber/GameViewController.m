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

#import "LifeBank.h"
#import "ContentLock.h"

#import "LifeCountView.h"

@interface GameViewController () <UINumberFieldDelegate>

@property (weak, nonatomic) IBOutlet UINumberField *inputView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewBottomLayoutConstraint;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *numberButtons;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak) IBOutlet LifeCountView* lifeCountView;

@end

@implementation GameViewController

- (void) updateWithQuestion: (Question*) question animated: (BOOL) animated {
    
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.duration = 0.3;
    [self.questionLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
    

    self.questionLabel.text = question.text;

    self.inputView.unitString = question.unit;
    self.inputView.automaticallyFormatsInput = question.formatsValue;
    
    
    self.okButton.enabled = NO;
    self.title = [NSString localizedStringWithFormat: NSLocalizedString(@"Level %@", @""), self.level.identifier];
    
    DLog(@"Ans: %@", question.answer);
}

#pragma mark - Actions
- (IBAction)numberPushed:(UIButton *)sender {
    NSInteger index = [self.numberButtons indexOfObject: sender];
    [self.inputView appendInteger: index];
}

- (IBAction)okPushed:(UIButton *)sender {
    
    ScoreSheet* sheet = [ScoreSheet currentScoreSheet];
    Question* question = [self.level nextQuestion];
    
    NSUInteger tries = [sheet triesForQuestion: question];
    BOOL isFreeTry = !(tries > 0 && tries < 6);
    
    if( ![ContentLock tryLock] ) {
        isFreeTry = YES;
    }
    
    NSLog(@"%d tries for %@", tries, question.identifier);
    
    if( !isFreeTry ) {
        //This needs lives if you make a mistake!!
        if( [LifeBank count] < COST_OF_BAD_RESPONSE ) {
            //Can not attempt -> show popup that we need to buy before continuing...
            [self performSegueWithIdentifier: @"StorePushSegue" sender: sender];
            return;
        }
    }
    
    NSUInteger answer = self.inputView.integerValue;
    
    NSComparisonResult result = [question.answer compare: @(answer)];
    
    switch (result) {
        case NSOrderedAscending:
        {
            NSLog(@"Less");
            
            [sheet failedAtQuestion: question];
            
            if( !isFreeTry ) {
                [LifeBank subtractLives: COST_OF_BAD_RESPONSE];
                self.lifeCountView.count -= COST_OF_BAD_RESPONSE;
            }
            break;
        }
        case NSOrderedDescending:
        {
            NSLog(@"More");
            [sheet failedAtQuestion: question];
            
            if( !isFreeTry ) {
                [LifeBank subtractLives: COST_OF_BAD_RESPONSE];
                self.lifeCountView.count -= COST_OF_BAD_RESPONSE;
            }
            break;
        }
        case NSOrderedSame:
        {
            
            BOOL success = [sheet crossOfQuestion: question];
            NSParameterAssert(success);
            
            question = [self.level nextQuestion];
            
            if( question ) {
                [self updateWithQuestion: question animated: YES];
            }
            else {
                NSLog(@"Level up!");
                self.level = [self.level nextLevel];
                
                if( self.level ) {
                    question = [self.level nextQuestion];
                    NSAssert(question, @"No questions for level %@", self.level);
                    [self updateWithQuestion: question animated: YES];
                }
                else {
                    NSLog(@"Game over!");
                }
            }
            
            CATransition *animation = [CATransition animation];
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.type = kCATransitionFade;
            animation.duration = 0.3;
            [self.inputView.layer addAnimation:animation forKey:@"kCATransitionFade"];
            break;
        }
    }
    
    self.inputView.text = @"";
}

#pragma mark - UIViewController
- (void) viewDidLoad {
    [super viewDidLoad];
    
    NSParameterAssert(self.level);
    
    Question* question = [self.level nextQuestion];
    [self updateWithQuestion: question animated: NO];
    
    LifeCountView* countView = [[LifeCountView alloc] initWithFrame: CGRectMake(0, 0, 40, 40)];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView: countView];
    self.navigationItem.rightBarButtonItems = @[self.navigationItem.rightBarButtonItem, item];
    self.lifeCountView = countView;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden: NO animated: YES];
    
    self.lifeCountView.count = [LifeBank count];
    
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
    self.okButton.enabled = integerValue > 0;
}

@end

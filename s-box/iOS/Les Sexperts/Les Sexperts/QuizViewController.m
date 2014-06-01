//
//  QuizViewController.m
//  Les Sexperts
//
//  Created by Paul de Lange on 4/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "QuizViewController.h"
#import "FinishedViewController.h"

#import "Question.h"
#import "Answer.h"

#import "AppDelegate.h"
#import "CoreDataStack.h"

#import "TimerView.h"

@interface QuizViewController () {
    NSTimeInterval          _timeRemaining;
    dispatch_source_t       _timerSource;
}

@property (strong) IBOutletCollection(UIButton) NSArray* answerButtons;

@property (strong) NSMutableArray* questions;
@property (strong) NSMutableArray* answers;

@property (weak) IBOutlet UILabel* timerLabel;
@property (weak, nonatomic) IBOutlet TimerView *timerView;

@end

@implementation QuizViewController

- (void) updateDisplayForQuestion: (Question*) aQuestion {
    aQuestion.lastDisplayedTime = [NSDate date];
    
    //Save!
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    CoreDataStack* stack = delegate.dataStack;
    
    [stack save];
    
    self.questionLabel.text = aQuestion.text;
    
    [self.answerButtons makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    NSMutableArray* answerButtons = [NSMutableArray new];
    
    UIButton* previousButton;
    for(Answer* answer in aQuestion.answers) {
        UIButton* button = [UIButton buttonWithType: UIButtonTypeCustom];
        [button setTitle: answer.text forState: UIControlStateNormal];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button addTarget: self action: @selector(answerPushed:) forControlEvents: UIControlEventTouchUpInside];
        button.titleLabel.numberOfLines = 0;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.font = [UIFont fontWithName: @"American Typewriter" size: 20];
        button.contentEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.titleLabel.minimumFontSize = 5;
        [self.view addSubview: button];
        
        [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-[button]-|"
                                                                           options: 0
                                                                           metrics: nil
                                                                             views: NSDictionaryOfVariableBindings(button)]];
         
         if( previousButton) {
             [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:[previousButton]-[button(==previousButton)]"
                                                                                options: 0
                                                                                metrics: nil
                                                                                  views: NSDictionaryOfVariableBindings(previousButton, button)]];
         }
         else {
             [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:[_questionLabel]-(==20)-[button]"
                                                                                options: 0
                                                                                metrics: nil
                                                                                  views: NSDictionaryOfVariableBindings(button, _questionLabel)]];
         }
        
        previousButton = button;
        
        button.backgroundColor = [UIColor whiteColor];
        button.layer.cornerRadius = 8.;
        
        [button setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [answerButtons addObject: button];
    }
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:[previousButton]-|"
                                                                       options: 0
                                                                       metrics: nil
                                                                         views: NSDictionaryOfVariableBindings(previousButton)]];
    
    self.answerButtons = [answerButtons copy];
}

- (IBAction) answerPushed: (id)sender {
    NSUInteger index = [self.answerButtons indexOfObject: sender];
    NSParameterAssert(index != NSNotFound);
    
    Question* question = [self.questions lastObject];
    Answer* answer = [question.answers objectAtIndex: index];
   
    [self.answers addObject: answer];
    
    Question* nextQuestion = [Question leastUsedQuestion];
    [self.questions addObject: nextQuestion];
    [self updateDisplayForQuestion: nextQuestion];
}

- (void) timeUp {
    self.timerView.timeRemaining = 0.;
    self.timerLabel.text = @"00.00s";
    [self performSegueWithIdentifier: @"FinishSegue" sender: nil];
}

- (void) startCountDown {
    
    __block NSUInteger lastSecond;
    
    _timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_timerSource, dispatch_time(DISPATCH_TIME_NOW, 0), 10 * NSEC_PER_MSEC, 0);
    dispatch_source_set_event_handler(_timerSource, ^{
        _timeRemaining -= 0.01;
        
        if( _timeRemaining < 10.f ) {
            self.timerLabel.textColor = [UIColor redColor];
            //self.timerView.tintColor = [UIColor redColor];
            
            if( ceil(_timeRemaining) != lastSecond) {
                
                [UIView animateWithDuration: 0.1
                                      delay: 0
                                    options: UIViewAnimationOptionCurveEaseOut
                                 animations: ^{
                                     self.timerLabel.transform = CGAffineTransformMakeScale(1.2, 1.2);
                                 } completion:^(BOOL finished) {
                                     [UIView animateWithDuration: 0.3
                                                           delay: 0
                                                         options: UIViewAnimationOptionCurveEaseIn
                                                      animations: ^{
                                                          self.timerLabel.transform = CGAffineTransformIdentity;
                                                      }
                                                      completion:^(BOOL finished) {
                                                          
                                                      }];
                                 }];
                
                lastSecond = ceil(_timeRemaining);
            }
            
        }
        
        if( _timeRemaining <= 0.f ) {
            dispatch_source_cancel(_timerSource);
            _timerSource = nil;
            
            [self timeUp];
            return;
        }
        
        self.timerLabel.text = [NSString stringWithFormat: @"%0.2fs", _timeRemaining];
        self.timerView.timeRemaining = _timeRemaining;
    });
    
    self.timerLabel.text = [NSString stringWithFormat: @"%0.2fs", _timeRemaining];
    self.timerView.timeRemaining = _timeRemaining;
    dispatch_resume(_timerSource);
}

#pragma mark - UIViewController
- (id) initWithCoder:(NSCoder *)aDecoder {
    self =[super initWithCoder: aDecoder];
    if( self ) {
        self.screenName = @"Quiz";
#if DEBUG
        _timeRemaining = 69.;
#else
        _timeRemaining = 69.;
#endif
    }
    return self;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString: @"FinishSegue"] ) {
        FinishedViewController* finishVC = segue.destinationViewController;
        finishVC.questionsArray = self.questions;
        finishVC.answersArray = self.answers;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = kAppName();
    
    Question* firstQuestion =[Question leastUsedQuestion];
    self.questions = [NSMutableArray arrayWithObject: firstQuestion];
    self.answers = [NSMutableArray new];
    
    [self updateDisplayForQuestion: firstQuestion];
    
    UILabel* timerLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 60, 44)];
    timerLabel.textAlignment = NSTextAlignmentRight;
    
    UIBarButtonItem* timerBarButton = [[UIBarButtonItem alloc] initWithCustomView: timerLabel];
    self.navigationItem.rightBarButtonItem = timerBarButton;
    self.timerLabel = timerLabel;
    
    self.timerView.totalTime = _timeRemaining;
    self.timerView.timeRemaining = _timeRemaining;
    
    UIColor* topColor = [UIColor colorWithRed: 35/255. green: 40/255. blue: 43/255. alpha: 1.];
    UIColor* centerColor = [UIColor colorWithRed: 39/255. green: 56/255. blue: 66/255. alpha: 1.];
    UIColor* bottomColor = [UIColor colorWithRed: 23/255. green: 85/255. blue: 102/255. alpha: 1.];
    
    CAGradientLayer* gradient = [CAGradientLayer layer];
    gradient.colors = @[(id)topColor.CGColor, (id)centerColor.CGColor, (id)bottomColor.CGColor];
    gradient.startPoint = CGPointMake(0.5, 0.);
    gradient.endPoint = CGPointMake(0.5, 1.);
    gradient.locations = @[@(0.25), @(0.75)];
    gradient.bounds = self.view.bounds;
    gradient.anchorPoint = CGPointMake(CGRectGetMinX(gradient.bounds), 0);
    
    [self.view.layer insertSublayer: gradient atIndex: 0];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [self startCountDown];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    
    if( _timerSource ) {
        dispatch_source_cancel(_timerSource);
        _timerSource = nil;
    }
}

@end

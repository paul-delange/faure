//
//  QuizViewController.m
//  Les Sexperts
//
//  Created by Paul de Lange on 4/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "QuizViewController.h"

#import "Question.h"

@interface QuizViewController () {
    NSTimeInterval          _timeRemaining;
    dispatch_source_t       _timerSource;
}

@property (strong, nonatomic) Question* currentQuestion;
@property (weak) IBOutlet UILabel* timerLabel;

@end

@implementation QuizViewController

- (void) updateDisplayForQuestion: (Question*) aQuestion {
    self.questionLabel.text = aQuestion.text;
}

- (void) setCurrentQuestion:(Question *)currentQuestion {
    NSParameterAssert(currentQuestion != _currentQuestion);
    
    _currentQuestion = currentQuestion;
    _currentQuestion.lastDisplayedTime = [NSDate date];
    
    if( [self isViewLoaded] ) {
        [self updateDisplayForQuestion: _currentQuestion];
    }
}

- (void) timeUp {
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
    });
    
    self.timerLabel.text = [NSString stringWithFormat: @"%0.2fs", _timeRemaining];
    dispatch_resume(_timerSource);
}

#pragma mark - UIViewController
- (id) initWithCoder:(NSCoder *)aDecoder {
    self =[super initWithCoder: aDecoder];
    if( self ) {
        _timeRemaining = 15.;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = kAppName();
    
    self.currentQuestion = [Question leastUsedQuestion];
    
    UILabel* timerLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 60, 44)];
    timerLabel.textAlignment = NSTextAlignmentRight;
    
    UIBarButtonItem* timerBarButton = [[UIBarButtonItem alloc] initWithCustomView: timerLabel];
    self.navigationItem.rightBarButtonItem = timerBarButton;
    self.timerLabel = timerLabel;
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

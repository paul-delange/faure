//
//  CountDownViewController.m
//  Les Sexperts
//
//  Created by Paul de Lange on 4/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "CountDownViewController.h"

@interface CountDownViewController ()

@end

@implementation CountDownViewController

- (void) startCountDown {
    self.countDownLabel.transform = CGAffineTransformMakeScale(4.0, 4.0);
    self.countDownLabel.text = @"3";
    [UIView animateWithDuration: 0.9
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations: ^{
                         self.countDownLabel.hidden = NO;
                         self.countDownLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
                     } completion:^(BOOL finished) {
                         [self performSelector: @selector(subtractOneSecond:) withObject: @2 afterDelay: 0.1];
                     }];
}

- (void) subtractOneSecond: (id) sender {
    NSUInteger remaining = [sender unsignedIntegerValue];
    
    self.countDownLabel.transform = CGAffineTransformMakeScale(4.0, 4.0);
    self.countDownLabel.hidden = YES;
    self.countDownLabel.text = [sender stringValue];
    [UIView animateWithDuration: 0.9
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations: ^{
                         self.countDownLabel.hidden = NO;
                         self.countDownLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
                     } completion:^(BOOL finished) {
                         if( remaining > 1 ) {
                             [self subtractOneSecond: @(remaining-1)];
                         }
                         else {
                             [self countDownFinished];
                         }
                     }];
}

- (void) countDownFinished {
    self.countDownLabel.text = NSLocalizedString(@"Go!", @"");
    self.countDownLabel.transform = CGAffineTransformMakeScale(4.0, 4.0);
    self.countDownLabel.hidden = YES;
    
    [UIView animateWithDuration: 0.9
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations: ^{
                         self.countDownLabel.hidden = NO;
                         self.countDownLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
                     } completion:^(BOOL finished) {
                         [self performSegueWithIdentifier: @"QuizPushSegue" sender: nil];
                     }];
}

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.countDownLabel.hidden = YES;
    self.instructionLabel.text = NSLocalizedString(@"69 seconds to see if you are a real Sexpert...", @"");
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [self startCountDown];
}

@end

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
    self.countDownLabel.transform = CGAffineTransformMakeScale(2.0, 2.0);
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

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [self startCountDown];
}

@end

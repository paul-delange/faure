//
//  FinishedViewController.m
//  Les Sexperts
//
//  Created by Paul de Lange on 4/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "FinishedViewController.h"
#import "ResultsViewController.h"

@interface FinishedViewController ()

@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@end

@implementation FinishedViewController

#pragma mark - UIViewController
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"ResultsSegue"] ) {
        UINavigationController* navController = segue.destinationViewController;
        ResultsViewController* resultsVC = navController.viewControllers.lastObject;
        resultsVC.questionsArray = self.questionsArray;
        resultsVC.answersArray = self.answersArray;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
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
    
    self.topLabel.text = NSLocalizedString(@"Finish!", @"");
    self.bottomLabel.text = NSLocalizedString(@"69 seconds...", @"");
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    NSParameterAssert([self.questionsArray count] > [self.answersArray count]);
    
    NSLayoutConstraint* topBottomConstraint = [NSLayoutConstraint constraintWithItem: self.topLabel
                                                                           attribute: NSLayoutAttributeBottom
                                                                           relatedBy: NSLayoutRelationEqual
                                                                              toItem: self.view
                                                                           attribute: NSLayoutAttributeCenterY
                                                                          multiplier: 1.0
                                                                            constant: 0];
    [self.view addConstraint: topBottomConstraint];
    
    NSLayoutConstraint* bottomTopConstraint = [NSLayoutConstraint constraintWithItem: self.bottomLabel
                                                                           attribute: NSLayoutAttributeTop
                                                                           relatedBy: NSLayoutRelationEqual
                                                                              toItem: self.view
                                                                           attribute: NSLayoutAttributeCenterY
                                                                          multiplier: 1.0
                                                                            constant: 0];
    [self.view addConstraint: bottomTopConstraint];
    
    topBottomConstraint.constant = -10;
    bottomTopConstraint.constant = 10;
    
    [UIView animateWithDuration: 1.0
                     animations: ^{
                         self.topLabel.alpha = 1.;
                         self.bottomLabel.alpha = 1.;
                         
                         [self.view layoutIfNeeded];
                     } completion: ^(BOOL finished) {
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             if( [self.answersArray count] > 0 )
                                 [self performSegueWithIdentifier: @"ResultsSegue" sender: nil];
                             else {
                                 [self performSegueWithIdentifier: @"UnwindGameSegue" sender: nil];
                             }
                         });
                     }];
}

@end

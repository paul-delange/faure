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
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    NSParameterAssert([self.questionsArray count] > [self.answersArray count]);
    
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if( [self.answersArray count] > 0 )
            [self performSegueWithIdentifier: @"ResultsSegue" sender: nil];
        else {
            [self performSegueWithIdentifier: @"UnwindGameSegue" sender: nil];
        }
    });
}

@end

//
//  ResumeViewController.m
//  Les Sexperts
//
//  Created by Paul de Lange on 6/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "ResumeViewController.h"

NSString * const kUserPreferenceCleared50Points     =   @"50PointsCleared";
NSString * const kUserPreferenceCleared45Points     =   @"45PointsCleared";
NSString * const kUserPreferenceCleared40Points     =   @"40PointsCleared";
NSString * const kUserPreferenceCleared35Points     =   @"35PointsCleared";
NSString * const kUserPreferenceCleared30Points     =   @"30PointsCleared";
NSString * const kUserPreferenceCleared25Points     =   @"25PointsCleared";
NSString * const kUserPreferenceCleared20Points     =   @"20PointsCleared";
NSString * const kUserPreferenceCleared15Points     =   @"15PointsCleared";
NSString * const kUserPreferenceCleared10Points     =   @"10PointsCleared";
NSString * const kUserPreferenceCleared5Points      =   @"5PointsCleared";

@interface ResumeViewController ()

@end

@implementation ResumeViewController

+ (BOOL) hasDisplayedForScore: (NSUInteger) score {
    
    if( score > 50 )
        return [[NSUserDefaults standardUserDefaults] boolForKey: kUserPreferenceCleared50Points];
    else if( score > 45 )
        return [[NSUserDefaults standardUserDefaults] boolForKey: kUserPreferenceCleared45Points];
    else if( score > 40 )
        return [[NSUserDefaults standardUserDefaults] boolForKey: kUserPreferenceCleared40Points];
    else if( score > 35 )
        return [[NSUserDefaults standardUserDefaults] boolForKey: kUserPreferenceCleared35Points];
    else if( score > 30 )
        return [[NSUserDefaults standardUserDefaults] boolForKey: kUserPreferenceCleared30Points];
    else if( score > 25 )
        return [[NSUserDefaults standardUserDefaults] boolForKey: kUserPreferenceCleared25Points];
    else if( score > 20 )
        return [[NSUserDefaults standardUserDefaults] boolForKey: kUserPreferenceCleared20Points];
    else if( score > 15 )
        return [[NSUserDefaults standardUserDefaults] boolForKey: kUserPreferenceCleared15Points];
    else if( score > 10 )
        return [[NSUserDefaults standardUserDefaults] boolForKey: kUserPreferenceCleared10Points];
    else if( score > 5 )
        return [[NSUserDefaults standardUserDefaults] boolForKey: kUserPreferenceCleared5Points];
    
    return YES;
}

#pragma mark - Actions
- (IBAction)sharePushed:(id)sender {
    NSString* format = NSLocalizedString(@"I am a %@ Sexpert", @"");
    NSString* msg = [NSString stringWithFormat: format, @"great"];
    
    UIActivityViewController* activityVC = [[UIActivityViewController alloc] initWithActivityItems: @[msg]
                                                                             applicationActivities: nil];
    activityVC.completionHandler = ^(NSString* activityType, BOOL completed) {
        
    };
    
    [self presentViewController: activityVC animated: YES completion: NULL];
}

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSArray* preferenceKeys;
    if( self.score > 50 ) {
        preferenceKeys = @[kUserPreferenceCleared50Points,
                           kUserPreferenceCleared45Points,
                           kUserPreferenceCleared40Points,
                           kUserPreferenceCleared35Points,
                           kUserPreferenceCleared30Points,
                           kUserPreferenceCleared25Points,
                           kUserPreferenceCleared20Points,
                           kUserPreferenceCleared15Points,
                           kUserPreferenceCleared10Points,
                           kUserPreferenceCleared5Points];
    }
    else if( self.score > 45 ) {
        preferenceKeys = @[kUserPreferenceCleared45Points,
                           kUserPreferenceCleared40Points,
                           kUserPreferenceCleared35Points,
                           kUserPreferenceCleared30Points,
                           kUserPreferenceCleared25Points,
                           kUserPreferenceCleared20Points,
                           kUserPreferenceCleared15Points,
                           kUserPreferenceCleared10Points,
                           kUserPreferenceCleared5Points];
    }
    else if( self.score > 40 ) {
        preferenceKeys = @[kUserPreferenceCleared40Points,
                           kUserPreferenceCleared35Points,
                           kUserPreferenceCleared30Points,
                           kUserPreferenceCleared25Points,
                           kUserPreferenceCleared20Points,
                           kUserPreferenceCleared15Points,
                           kUserPreferenceCleared10Points,
                           kUserPreferenceCleared5Points];
    }
    else if( self.score > 35 ) {
        preferenceKeys = @[kUserPreferenceCleared35Points,
                           kUserPreferenceCleared30Points,
                           kUserPreferenceCleared25Points,
                           kUserPreferenceCleared20Points,
                           kUserPreferenceCleared15Points,
                           kUserPreferenceCleared10Points,
                           kUserPreferenceCleared5Points];
    }
    else if( self.score > 30 ) {
        preferenceKeys = @[kUserPreferenceCleared30Points,
                           kUserPreferenceCleared25Points,
                           kUserPreferenceCleared20Points,
                           kUserPreferenceCleared15Points,
                           kUserPreferenceCleared10Points,
                           kUserPreferenceCleared5Points];
    }
    else if( self.score > 25 ) {
        preferenceKeys = @[kUserPreferenceCleared25Points,
                           kUserPreferenceCleared20Points,
                           kUserPreferenceCleared15Points,
                           kUserPreferenceCleared10Points,
                           kUserPreferenceCleared5Points];
    }
    else if( self.score > 20 ) {
        preferenceKeys = @[kUserPreferenceCleared20Points,
                           kUserPreferenceCleared15Points,
                           kUserPreferenceCleared10Points,
                           kUserPreferenceCleared5Points];
    }
    else if( self.score > 15 ) {
        preferenceKeys = @[kUserPreferenceCleared15Points,
                           kUserPreferenceCleared10Points,
                           kUserPreferenceCleared5Points];
    }
    else if( self.score > 10 ) {
        preferenceKeys = @[kUserPreferenceCleared10Points,
                           kUserPreferenceCleared5Points];
    }
    else if( self.score > 5 ) {
        preferenceKeys = @[kUserPreferenceCleared5Points];
    }
    
    for(NSString* preferenceKey in preferenceKeys) {
        [[NSUserDefaults standardUserDefaults] setBool: YES forKey: preferenceKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
 
    [self.continueButton setTitle: NSLocalizedString(@"Continue", @"") forState: UIControlStateNormal];
    [self.shareButton setTitle: NSLocalizedString(@"Share", @"") forState: UIControlStateNormal];
    self.title = NSLocalizedString(@"Ranking", @"");
    
    self.textLabel.text = [NSString stringWithFormat: @"You got %@", preferenceKeys[0]];
}

@end

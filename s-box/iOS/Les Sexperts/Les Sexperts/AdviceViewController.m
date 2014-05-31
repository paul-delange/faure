//
//  AdviceViewController.m
//  Les Sexperts
//
//  Created by Paul De Lange on 28/02/14.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "AdviceViewController.h"

#import "Advice.h"
#import "Theme.h"
#import "ContentLock.h"

#import "UIImage+ImageEffects.h"

#import "MZFormSheetController.h"

#import <AdColony/AdColony.h>

#define HTML_FORMAT @"<html><body bgcolor=\"#000000\" text=\"#FFFFFF\" face=\"American Typewriter\" size=\"5\">%@</body></html>"
#define HTML_STRING_FROM_TEXT( text ) [NSString stringWithFormat: HTML_FORMAT, text]

@interface AdviceViewController () <AdColonyAdDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *maskImageView;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation AdviceViewController

- (void) setAdvice:(Advice *)advice {
    if( advice != _advice ) {
        _advice = advice;
        
        if( [self isViewLoaded] )
            [self reloadData];
    }
}

- (void) reloadData {
    if( ![self.title length] ) {
        self.title = self.advice.theme.name;
    }
    
    self.titleLabel.text = [NSString stringWithFormat: @"\n%@\n ", self.advice.title];
    self.textView.text = self.advice.text;
}

#pragma mark - Actions
- (IBAction)sharePushed:(id)sender {
}

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self reloadData];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    //TODO: Add this later
    self.navigationItem.rightBarButtonItem = nil;
    
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



@end

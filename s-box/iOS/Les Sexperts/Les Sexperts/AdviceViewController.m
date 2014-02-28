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

@interface AdviceViewController () <UIWebViewDelegate>

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
    self.title = self.advice.theme.name;
    self.titleLabel.text = self.advice.title;
    
    NSString* htmlString = self.advice.text;
    
    [self.webView loadHTMLString: htmlString baseURL: nil];
    
    [self.activityIndicator startAnimating];
}

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if( self.advice )
        [self reloadData];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [self.activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    DLogError(error);
}

- (IBAction)sharePushed:(id)sender {
}
@end

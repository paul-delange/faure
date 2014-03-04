//
//  JokeViewController.m
//  Les Sexperts
//
//  Created by Paul de Lange on 4/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "JokeViewController.h"

#import "Joke.h"

@interface JokeViewController () <UIWebViewDelegate>

@end

@implementation JokeViewController

- (void) setJoke:(Joke *)joke {
    if( _joke != joke ) {
        _joke = joke;
        
        if( [self isViewLoaded] ) {
            [self.webView loadHTMLString: joke.text baseURL: nil];
        }
    }
}

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if( self.joke ) {
        [self.webView loadHTMLString: self.joke.text baseURL: nil];
    }
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityView stopAnimating];
}

@end

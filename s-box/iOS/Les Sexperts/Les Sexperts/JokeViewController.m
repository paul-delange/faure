//
//  JokeViewController.m
//  Les Sexperts
//
//  Created by Paul de Lange on 4/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "JokeViewController.h"

#import "Joke.h"    
#import "UIImage+ImageEffects.h"

#define HTML_FORMAT @"<html><body bgcolor=\"#000000\" text=\"#FFFFFF\" face=\"American Typewriter\" size=\"5\">%@</body></html>"
#define HTML_STRING_FROM_TEXT( text ) [NSString stringWithFormat: HTML_FORMAT, text]

@interface JokeViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView* maskImageView;

@end

@implementation JokeViewController

- (void) setBlocked:(BOOL)blocked {
    if( _blocked != blocked ) {
        _blocked = blocked;
        
        if( !blocked ) {
            self.maskImageView.hidden = YES;
        }
    }
}

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.webView loadHTMLString: HTML_STRING_FROM_TEXT(self.joke.text) baseURL: nil];
    
    //[self.webView loadHTMLString: self.joke.text baseURL: nil];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityView stopAnimating];
    
    if( !self.blocked )
        return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIGraphicsBeginImageContextWithOptions(webView.bounds.size, NO, [UIScreen mainScreen].scale);
        [webView drawViewHierarchyInRect: webView.bounds afterScreenUpdates:YES];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.maskImageView.image = [image applyBlurWithRadius: 2.5
                                                    tintColor: [UIColor clearColor]
                                        saturationDeltaFactor: 1.8
                                                    maskImage: nil];
        self.maskImageView.hidden = NO;
    });
}

@end

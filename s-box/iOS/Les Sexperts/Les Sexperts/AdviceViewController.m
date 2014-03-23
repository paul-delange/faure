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

#import <AdColony/AdColony.h>

#define HTML_FORMAT @"<html><body bgcolor=\"#000000\" text=\"#FFFFFF\" face=\"American Typewriter\" size=\"5\">%@</body></html>"
#define HTML_STRING_FROM_TEXT( text ) [NSString stringWithFormat: HTML_FORMAT, text]

@interface AdviceViewController () <UIWebViewDelegate, AdColonyAdDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *maskImageView;

@property (weak, nonatomic) IBOutlet UIView* blockedMessageView;

@end

@implementation AdviceViewController

- (void) setBlocked:(BOOL)blocked {
    if( _blocked != blocked ) {
        _blocked = blocked;
        
        if( !blocked ) {
            self.maskImageView.hidden = YES;
        }
    }
}

- (void) setAdvice:(Advice *)advice {
    if( advice != _advice ) {
        _advice = advice;
        
        if( [self isViewLoaded] )
            [self reloadData];
    }
}

- (UIView*) blockedView {
    
    UIView* blockedBackground = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 300, 180)];
    blockedBackground.center = CGPointMake(160, CGRectGetMidY(self.view.bounds));
    blockedBackground.backgroundColor = [UIColor blackColor];
    blockedBackground.layer.borderColor = [[UIColor whiteColor] CGColor];
    blockedBackground.layer.borderWidth = 2.;
    blockedBackground.layer.cornerRadius = 10.;
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"lock_icon"]];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel* textLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    textLabel.text = NSLocalizedString(@"Blocked! To read this advice, you can:", @"");
    textLabel.numberOfLines = 0;
    textLabel.font = [UIFont fontWithName: @"American Typewriter" size: 20.];
    
    UIButton* videoButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [videoButton setTitle: NSLocalizedString(@"i. Watch a free video...", @"") forState: UIControlStateNormal];
    [videoButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [videoButton setTitleColor: [UIColor lightGrayColor] forState: UIControlStateHighlighted];
    [videoButton addTarget: self action: @selector(videoPushed:) forControlEvents: UIControlEventTouchUpInside];
    videoButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    videoButton.translatesAutoresizingMaskIntoConstraints = NO;
    videoButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [videoButton.titleLabel setFont: [UIFont fontWithName: @"American Typewriter" size: 15.]];
    
    UIButton* unlockButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [unlockButton setTitle: NSLocalizedString(@"ii. Unlock the app...", @"") forState: UIControlStateNormal];
    [unlockButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [unlockButton setTitleColor: [UIColor lightGrayColor] forState: UIControlStateHighlighted];
    [unlockButton addTarget: self action: @selector(unlockPushed:) forControlEvents: UIControlEventTouchUpInside];
    unlockButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [unlockButton.titleLabel setFont: [UIFont fontWithName: @"American Typewriter" size: 15.]];
    unlockButton.translatesAutoresizingMaskIntoConstraints = NO;
    unlockButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    [blockedBackground addSubview: imageView];
    [blockedBackground addSubview: textLabel];
    [blockedBackground addSubview: videoButton];
    [blockedBackground addSubview: unlockButton];
    
    [blockedBackground addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-[imageView]-[textLabel]-|"
                                                                               options: 0
                                                                               metrics: nil
                                                                                 views: NSDictionaryOfVariableBindings(imageView, textLabel)]];
    [blockedBackground addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-[imageView]"
                                                                               options: 0
                                                                               metrics: nil
                                                                                 views: NSDictionaryOfVariableBindings(imageView)]];
    [blockedBackground addConstraint: [NSLayoutConstraint constraintWithItem: textLabel
                                                                   attribute: NSLayoutAttributeCenterY
                                                                   relatedBy: NSLayoutRelationEqual
                                                                      toItem: imageView
                                                                   attribute: NSLayoutAttributeCenterY
                                                                  multiplier: 1.
                                                                    constant: 0.]];
    [blockedBackground addConstraint: [NSLayoutConstraint constraintWithItem: imageView
                                                                   attribute: NSLayoutAttributeHeight
                                                                   relatedBy: NSLayoutRelationEqual
                                                                      toItem: imageView
                                                                   attribute: NSLayoutAttributeWidth
                                                                  multiplier: 1.0
                                                                    constant: 0.0]];
    [blockedBackground addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-[videoButton]-|"
                                                                               options: 0
                                                                               metrics: nil
                                                                                 views: NSDictionaryOfVariableBindings(videoButton)]];
    [blockedBackground addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:[imageView]-[videoButton]"
                                                                               options: 0
                                                                               metrics: nil
                                                                                 views: NSDictionaryOfVariableBindings(imageView, videoButton)]];
    [blockedBackground addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-[unlockButton]-|"
                                                                               options: 0
                                                                               metrics: nil
                                                                                 views: NSDictionaryOfVariableBindings(unlockButton)]];
    [blockedBackground addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:[videoButton]-[unlockButton]"
                                                                               options: 0
                                                                               metrics: nil
                                                                                 views: NSDictionaryOfVariableBindings(unlockButton, videoButton)]];
    
    return blockedBackground;
}

- (void) reloadData {
    self.title = self.advice.theme.name;
    self.titleLabel.text = [NSString stringWithFormat: @"\n%@\n ", self.advice.title];
    
    NSString* htmlString = self.advice.text;
    
    [self.webView loadHTMLString: HTML_STRING_FROM_TEXT(htmlString) baseURL: nil];
    
    [self.activityIndicator startAnimating];
}

#pragma mark - Actions
- (IBAction) videoPushed:(id)sender {
    [AdColony playVideoAdForZone: @"vzd5640bc5e87746d083"
                    withDelegate: self
                withV4VCPrePopup: YES
                andV4VCPostPopup: YES];
}

- (IBAction) unlockPushed:(id)sender {
    
    BOOL tryingToUnlock = [ContentLock unlockWithCompletion: ^(NSError *error) {
        if( error ) {
            DLogError(error);
        }
        else {
            NSParameterAssert(![ContentLock tryLock]);
            [UIView transitionWithView: self.view
                              duration: 0.3
                               options: UIViewAnimationOptionCurveEaseInOut
                            animations: ^{
                                [self.blockedMessageView removeFromSuperview];
                                self.maskImageView.hidden = YES;
                            } completion: NULL];
        }
    }];
    
    if( !tryingToUnlock ) {
        NSString* title = NSLocalizedString(@"Purchases disabled", @"");
        NSString* msg = NSLocalizedString(@"You must enable In-App Purchases in your device Settings app (General > Restrictions > In-App Purchases)", @"");
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                        message: msg
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                              otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)sharePushed:(id)sender {
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
    
    if( !self.blocked )
        return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIGraphicsBeginImageContextWithOptions(self.maskImageView.bounds.size, NO, [UIScreen mainScreen].scale);
        [self.view drawViewHierarchyInRect: CGRectMake(0, -CGRectGetMinY(self.titleLabel.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)) afterScreenUpdates:YES];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.maskImageView.image = [image applyBlurWithRadius: 2.5
                                                    tintColor: [UIColor clearColor]
                                        saturationDeltaFactor: 1.8
                                                    maskImage: nil];
        self.maskImageView.hidden = NO;
        
        UIView* msgView = [self blockedView];
        [UIView transitionWithView: self.view
                          duration: 0.3
                           options: UIViewAnimationOptionCurveEaseIn
                        animations: ^{
                            [self.view addSubview: msgView];
                        } completion:^(BOOL finished) {
                            self.blockedMessageView = msgView;
                        }];
    });
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    DLogError(error);
}

#pragma mark - AdColonyAdDelegate
- ( void ) onAdColonyAdStartedInZone:( NSString * )zoneID {
    
}

- ( void ) onAdColonyAdAttemptFinished:(BOOL)shown inZone:( NSString * )zoneID {
    if( shown ) {
        [UIView transitionWithView: self.view
                          duration: 0.3
                           options: UIViewAnimationOptionCurveEaseIn
                        animations: ^{
                            self.maskImageView.hidden = YES;
                            [self.blockedMessageView removeFromSuperview];
                        } completion: NULL];
    }
}

@end

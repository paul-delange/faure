//
//  AdvertisementNavigationController.m
//  Les Sexperts
//
//  Created by Paul de Lange on 7/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "AdvertisementNavigationController.h"

#import "ContentLock.h"

//#import "GADBannerView.h"
//#import "GADRequest.h"

#import "InMobi.h"
#import "IMBanner.h"

#define kBannerSize CGSizeMake(320, 50)

@interface AdvertisementNavigationController () <IMBannerDelegate> {
    __weak UIView* _contentView;
}

@property (weak) IMBanner* bannerView;
@property (strong) NSLayoutConstraint* contentViewHeightConstraint;
@end

@implementation AdvertisementNavigationController

- (void) showAdView {
    self.contentViewHeightConstraint.constant = -kBannerSize.height;
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration: 0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void) hideAdView {
    self.contentViewHeightConstraint.constant = 0;
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration: 0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Notififications
- (void) contentWasUnlocked: (id) sender {
    self.bannerView.delegate = nil;
    [self.bannerView removeFromSuperview];
    
    [self hideAdView];
}

#pragma mark - NSObject
+ (void) initialize {
    [InMobi initialize: @"5f8cfe36e2584af38424d074069aeef5"];
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if( self ) {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(contentWasUnlocked:)
                                                     name: ContentLockWasRemovedNotification
                                                   object: nil];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    self.bannerView.delegate = nil;
}

#pragma mark - UIViewController
- (void) loadView {
    [super loadView];
    
    if( ![ContentLock tryLock] )
        return;
    
    UIView* contentView = self.view;
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.view = [[UIView alloc] initWithFrame: contentView.frame];
    
    IMBanner* banner = [[IMBanner alloc] initWithFrame: CGRectMake(0, 0, 320, 50) appId: @"5f8cfe36e2584af38424d074069aeef5" adSize: IM_UNIT_320x50];
    banner.translatesAutoresizingMaskIntoConstraints = NO;
    banner.delegate = self;
    [self.view addSubview: banner];
    self.bannerView = banner;
    
    //Content view must go above the banner view
    // If the banner is off the screen it will not be updated
    [self.view addSubview: contentView];
    _contentView = contentView;
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[banner]|"
                                                                       options: 0
                                                                       metrics: nil
                                                                         views: NSDictionaryOfVariableBindings(banner)]];
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[contentView]|"
                                                                       options: 0
                                                                       metrics: nil
                                                                         views: NSDictionaryOfVariableBindings(contentView)]];
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:[banner]|"
                                                                       options: 0
                                                                       metrics: nil
                                                                         views: NSDictionaryOfVariableBindings(contentView, banner)]];
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[contentView]"
                                                                       options: 0
                                                                       metrics: nil
                                                                         views: NSDictionaryOfVariableBindings(contentView)]];
    self.contentViewHeightConstraint = [NSLayoutConstraint constraintWithItem: contentView
                                                                    attribute: NSLayoutAttributeHeight
                                                                    relatedBy: NSLayoutRelationEqual
                                                                       toItem: self.view
                                                                    attribute: NSLayoutAttributeHeight
                                                                   multiplier: 1.0
                                                                     constant: 0];
    [self.view addConstraint: self.contentViewHeightConstraint];
    
    
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
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
    
    [self.bannerView loadBanner];
    
    /*
    GADRequest* request = [GADRequest request];
    
    request.testDevices = @[ GAD_SIMULATOR_ID,
                             @"5847239deac1f26ea408b154815af621"            //Paul iPhone4
                             ];
    
    self.bannerView.delegate = self;
    
    [self.bannerView loadRequest: request];
     */
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    
    [self hideAdView];
    self.bannerView.delegate = nil;
    [self.bannerView stopLoading];
    //[self.bannerView loadRequest: nil];
}

- (BOOL) shouldAutomaticallyForwardAppearanceMethods {
    return YES;
}

#pragma mark IMBannerDelegate
- (void)bannerDidReceiveAd:(IMBanner *)banner {
    [self showAdView];
}

- (void)banner:(IMBanner *)banner didFailToReceiveAdWithError:(IMError *)error {
    [self hideAdView];
    DLogError(error);
}

/*
#pragma mark - GADBannerViewDelegate
- (void)adViewDidReceiveAd:(GADBannerView *)view {
    [self showAdView];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
   [self hideAdView];
    DLogError(error);
}*/

@end

//
//  AdvertisementNavigationController.m
//  Les Sexperts
//
//  Created by Paul de Lange on 7/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "AdvertisementNavigationController.h"

#import "ContentLock.h"

#if USE_MEDIATION
#import "GADBannerView.h"
#import "GADRequest.h"
#define kBannerSize kGADAdSizeBanner
#else
#import "IMBanner.h"
#import "IMBannerDelegate.h"
#define kBannerSize CGRectMake(0, 0, 320, 48)
#endif

@interface AdvertisementNavigationController () <
#if USE_MEDIATION
GADBannerViewDelegate
#else
IMBannerDelegate
#endif
>
{
    NSUInteger retryCount;
    __weak UIView* _contentView;
}

#if USE_MEDIATION
@property (weak) GADBannerView* bannerView;
#else
@property (weak) IMBanner* bannerView;
#endif
@property (strong) NSLayoutConstraint* contentViewHeightConstraint;
@end

@implementation AdvertisementNavigationController

- (void) showAdView {
    self.contentViewHeightConstraint.constant = -kBannerSize.size.height;
    
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
#if !USE_MEDIATION
+ (void) initialize {
    [InMobi initialize: @"5f8cfe36e2584af38424d074069aeef5"];
#if DEBUG
    [InMobi setLogLevel: IMLogLevelDebug];
#endif
}
#endif

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
    
#if USE_MEDIATION
    GADBannerView* banner = [[GADBannerView alloc] initWithAdSize: kBannerSize];
    banner.adUnitID = @"ca-app-pub-1332160865070772/3760720045";
    banner.rootViewController = self;
#else
    IMBanner* banner = [[IMBanner alloc] initWithFrame: kBannerSize
                                                 appId: @"5f8cfe36e2584af38424d074069aeef5"
                                                adSize: IM_UNIT_320x48];
    banner.refreshInterval = 60;
#endif
    banner.translatesAutoresizingMaskIntoConstraints = NO;
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
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[contentView][banner(==bannerHeight)]"
                                                                       options: 0
                                                                       metrics: @{ @"bannerHeight" : @(kBannerSize.size.height) }
                                                                         views: NSDictionaryOfVariableBindings(contentView, banner)]];
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
    
    self.bannerView.delegate = self;
    
#if USE_MEDIATION
    GADRequest* request = [GADRequest request];
    request.gender = kGADGenderMale;
    
    request.testDevices = @[ GAD_SIMULATOR_ID,
                             @"5847239deac1f26ea408b154815af621"            //Paul iPhone4
                             ];
    
    [self.bannerView loadRequest: request];
#else
    [self.bannerView loadBanner];
#endif
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    
    [self hideAdView];
    self.bannerView.delegate = nil;
#if USE_MEDIATION
    [self.bannerView loadRequest: nil];
#else
    [self.bannerView stopLoading];
#endif
}

- (BOOL) shouldAutomaticallyForwardAppearanceMethods {
    return YES;
}

#if USE_MEDIATION
#pragma mark - GADBannerViewDelegate
- (void)adViewDidReceiveAd:(GADBannerView *)view {
    [self showAdView];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
   [self hideAdView];
    DLogError(error);
}
#else
#pragma mark - IMBannerDelegate
- (void) bannerDidReceiveAd:(IMBanner *)banner {
    [self showAdView];
}

- (void) banner:(IMBanner *)banner didFailToReceiveAdWithError:(IMError *)error {
    //HACK: This fails on the very first launch...
    if( error.code == kIMErrorInternal && retryCount < 10 ) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [banner loadBanner];
        });
        
        retryCount++;
    }
    
    DLogError(error);
    [self hideAdView];
}
#endif

@end

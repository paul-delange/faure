//
//  AdvertisementNavigationController.m
//  Les Sexperts
//
//  Created by Paul de Lange on 7/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "AdvertisementNavigationController.h"

#import "ContentLock.h"

#import "GADBannerView.h"
#import "GADRequest.h"

@interface AdvertisementNavigationController () <GADBannerViewDelegate>
@property (weak) GADBannerView* bannerView;

@end

@implementation AdvertisementNavigationController

- (void) showAdView {
    [UIView animateWithDuration: 0.5 animations:^{
        CGRect frame = self.view.superview.bounds;
        frame.size.height -= kGADAdSizeBanner.size.height;
        self.view.frame = frame;
    }];
}

- (void) hideAdView {
    [UIView animateWithDuration: [[UIApplication sharedApplication] statusBarOrientationAnimationDuration] animations:^{
        self.view.frame = self.view.superview.bounds;
    }];
}

#pragma mark - NSObject
- (void) dealloc {
    self.bannerView.delegate = nil;
}

#pragma mark - UIViewController
- (void) viewDidLoad {
    [super viewDidLoad];
    
    GADBannerView* banner = [[GADBannerView alloc] initWithAdSize: kGADAdSizeBanner];
    banner.delegate = self;
    banner.adUnitID = @"ca-app-pub-1332160865070772/2668997243";
    banner.rootViewController = self;
    banner.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview: banner];
    self.bannerView = banner;
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    GADRequest* request = [GADRequest request];
    request.testDevices = @[ GAD_SIMULATOR_ID ];
    
    [self.bannerView loadRequest: request];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    
    [self.bannerView loadRequest: nil];
    [self hideAdView];
}

- (void) viewWillLayoutSubviews {
    
    UIView* view = self.view;
    UIView* superview = view.superview;
    
    if( superview && self.bannerView ) {
        UIView* banner = self.bannerView;
        
        //[superview addSubview: self.bannerView];
        
        [superview addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[banner]|"
                                                                           options: 0
                                                                           metrics: nil
                                                                             views: NSDictionaryOfVariableBindings(banner)]];
        [superview addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:[view][banner]"
                                                                           options: 0
                                                                           metrics: nil
                                                                             views: NSDictionaryOfVariableBindings(view, banner)]];
    }
    
    [super viewWillLayoutSubviews];
}

#pragma mark - GADBannerViewDelegate
- (void)adViewDidReceiveAd:(GADBannerView *)view {
    [self showAdView];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    [self hideAdView];
    
    DLogError(error);
}

@end

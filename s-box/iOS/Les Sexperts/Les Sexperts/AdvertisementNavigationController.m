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

#define kBannerSize kGADAdSizeBanner

@interface AdvertisementNavigationController () <GADBannerViewDelegate> {
    __weak UIView* _contentView;
}

@property (weak) GADBannerView* bannerView;
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
- (void) purchaseWasMade: (id) sender {
    self.bannerView.delegate = nil;
    [self.bannerView removeFromSuperview];
    
    [self hideAdView];
}

#pragma mark - NSObject
- (void) dealloc {
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
    
    GADBannerView* banner = [[GADBannerView alloc] initWithAdSize: kBannerSize];
    banner.delegate = self;
    banner.adUnitID = @"ca-app-pub-1332160865070772/2668997243";
    banner.rootViewController = self;
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

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    GADRequest* request = [GADRequest request];
    
    request.testDevices = @[ GAD_SIMULATOR_ID,
                             @"5847239deac1f26ea408b154815af621"            //Paul iPhone4
                             ];
    
    self.bannerView.delegate = self;
    
    [self.bannerView loadRequest: request];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    
    [self hideAdView];
    self.bannerView.delegate = nil;
    [self.bannerView loadRequest: nil];
}

- (BOOL) shouldAutomaticallyForwardAppearanceMethods {
    return YES;
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

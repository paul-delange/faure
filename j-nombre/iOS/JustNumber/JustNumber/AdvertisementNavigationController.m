//
//  AdvertisementNavigationController.m
//  94-percent
//
//  Created by Paul de Lange on 7/03/2014.
//  Copyright (c) 2014 Scimob. All rights reserved.
//

#import "AdvertisementNavigationController.h"

#import "GADBannerView.h"
#import "GADRequest.h"

#import "ContentLock.h"

#define kBannerSize ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? kGADAdSizeBanner : kGADAdSizeLeaderboard)

@interface AdvertisementNavigationController () <GADBannerViewDelegate> {
    __weak UIView* _contentView;
}

@property (weak) GADBannerView* bannerView;
@property (strong) NSLayoutConstraint* contentViewHeightConstraint;
@end

@implementation AdvertisementNavigationController

- (void) showAdView {
    NSParameterAssert([ContentLock tryLock]);
    
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
    
    [UIView transitionWithView: self.view
                      duration: 0.5
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations: ^{
                        [self.bannerView removeFromSuperview];
                    } completion: NULL];
    
    [self hideAdView];
}

#pragma mark - NSObject
- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if( self ) {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(purchaseWasMade:)
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
    
    GADBannerView* banner = [[GADBannerView alloc] initWithAdSize: kBannerSize];
    banner.delegate = self;
    banner.adUnitID = @"ca-app-pub-1332160865070772/9575947645";
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
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[contentView][banner]"
                                                                       options: 0
                                                                       metrics: nil
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

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    GADRequest* request = [GADRequest request];
    request.testDevices = @[ GAD_SIMULATOR_ID ];
    
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
    NSParameterAssert([ContentLock tryLock]);
    [self showAdView];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    NSParameterAssert([ContentLock tryLock]);
    [self hideAdView];
    DLogError(error);
}

@end

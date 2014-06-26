//
//  HomeViewController.m
//  JustNumber
//
//  Created by Paul de Lange on 27/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "HomeViewController.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "GameViewController.h"

#import "ContentLock.h"

#import "Level.h"
#import "LifeBank.h"

#import "UIImage+ImageEffects.h"
#import "UIViewController+SocialMedia.h"

#define kAlertViewEndGameTag    916
#define kAlertViewAdsBlockTag   777

@interface HomeViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *buyViewGroup;
@property (weak, nonatomic) IBOutlet UILabel *adsLabel;
@property (weak, nonatomic) IBOutlet UISwitch *adsSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation HomeViewController

#pragma mark - Actions
- (IBAction)menuPushed:(id)sender {
    JASidePanelController* panelVC = self.sidePanelController;
    [panelVC showLeftPanelAnimated: YES];
}

- (IBAction)adsPushed:(UISwitch*)sender {
    
    NSString* title = NSLocalizedString(@"Thank you!", @"");
    NSString* msg = [NSString localizedStringWithFormat: NSLocalizedString(@"For a small price you can turn off advertisement and get +%d extra lives!", @""), LIVES_FOR_AD_STOP];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                    message: msg
                                                   delegate: self
                                          cancelButtonTitle: NSLocalizedString(@"Cancel", @"")
                                          otherButtonTitles: NSLocalizedString(@"Continue", @""), nil];
    alert.tag = kAlertViewAdsBlockTag;
    [alert show];
}

#pragma mark - Notififications
- (void) purchaseWasMade: (id) sender {
    [UIView animateWithDuration: 0.6 animations: ^{
        self.buyViewGroup.alpha = 0.;
    } completion: ^(BOOL finished) {
        self.buyViewGroup.hidden = YES;
    }];
}

#pragma mark - NSObject
- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if( self ) {
        self.screenName = @"Home";
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(purchaseWasMade:)
                                                     name: ContentLockWasRemovedNotification
                                                   object: nil];
    }
    return self;
}

#pragma mark - UIViewController
- (void) viewDidLoad {
    [super viewDidLoad];

    UIImage* template = [self.backgroundImageView.image imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
    self.backgroundImageView.image = template;
    
    self.adsLabel.text = NSLocalizedString(@"Advertising", @"");
    self.titleLabel.text = kAppName();
    
    [self.playButton setTitle: NSLocalizedString(@"Play", @"") forState: UIControlStateNormal];
    
    self.navigationController.navigationBar.topItem.title = @"";
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden: YES animated: YES];
    
    self.buyViewGroup.hidden = ![ContentLock tryLock];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString: @"GamePushSegue"] ) {
        GameViewController* gameVC = segue.destinationViewController;
        gameVC.level = [Level currentLevel];
    }
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if( [identifier isEqualToString: @"GamePushSegue"] ) {
        if( [Level currentLevel] ) {
            return YES;
        }
        else {
            NSString* title = NSLocalizedString(@"No more levels!", @"");
            NSString* msg = NSLocalizedString(@"New levels are coming soon, follow us on Twitter to find out more!", @"");
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                            message: msg
                                                           delegate: self
                                                  cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles: NSLocalizedString(@"Follow", @""), nil];
            alert.tag = kAlertViewEndGameTag;
            [alert show];
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - UIAlertViewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case kAlertViewEndGameTag:
        {
            if( buttonIndex != alertView.cancelButtonIndex ) {
                [self followUsOn: SLServiceTypeTwitter completion: ^(NSError *error) {
                    
                }];
            }
            break;
        }
        case kAlertViewAdsBlockTag:
        {
            if( buttonIndex == alertView.cancelButtonIndex ) {
                self.adsSwitch.on = YES;
            }
            else {
                if( ![ContentLock unlockWithCompletion: ^(NSError *error) {
                    
                    if( error ) {
                        self.adsSwitch.on = YES;
                    }
                    else {
                        [LifeBank addLives: LIVES_FOR_AD_STOP];
                    }
                    
                    DLogError(error);
                }]) {
                    NSString* title = NSLocalizedString(@"Store not available", @"");
                    NSString* msg = NSLocalizedString(@"Your device settings are blocking the store. Please enable In-App Purchases and try again.", @"");
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                                    message: msg
                                                                   delegate: nil
                                                          cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                                          otherButtonTitles: nil];
                    [alert show];
                    self.adsSwitch.on = YES;
                }
            }
            break;
        }
        default:
            break;
    }
}

@end

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

#import "ContentLock.h"

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UIView *buyViewGroup;
@property (weak, nonatomic) IBOutlet UILabel *adsLabel;
@property (weak, nonatomic) IBOutlet UISwitch *adsSwitch;

@end

@implementation HomeViewController

#pragma mark - Actions
- (IBAction)menuPushed:(id)sender {
    JASidePanelController* panelVC = self.sidePanelController;
    [panelVC showLeftPanelAnimated: YES];
}

- (IBAction)adsPushed:(UISwitch*)sender {
    if( ![ContentLock unlockWithCompletion: ^(NSError *error) {
        
        if( error ) {
            sender.on = YES;
        }
        else {
        
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
        sender.on = YES;
    }
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
    
    self.adsLabel.text = NSLocalizedString(@"Advertising", @"");
    
    self.navigationController.navigationBar.topItem.title = @"";
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden: YES animated: YES];
    
    self.buyViewGroup.hidden = ![ContentLock tryLock];
}

@end

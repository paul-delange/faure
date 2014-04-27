//
//  MenuViewController.m
//  JustNumber
//
//  Created by Paul de Lange on 27/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "MenuViewController.h"

#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"

#import "AppDelegate.h"

#import "ContentLock.h"

@import StoreKit;
@import MessageUI;

#define ITEM_TITLE_KEY          @"text"
#define ITEM_IMAGE_NAME_KEY     @"img"
#define ITEM_ACTION_KEY         @"action"

typedef NS_ENUM(NSUInteger, kSettingsTableViewSection) {
    
    kSettingsTableViewSectionRecommend = 0,
    kSettingsTableViewSectionRate,
    kSettingsTableViewSectionPremium,
    kSettingsTableViewSectionShareFacebook,
    kSettingsTableViewSectionShareTwitter,
    kSettingsTableViewSectionContactUs,
    
    kSettingsTableViewSectionCount
};

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, SKStoreProductViewControllerDelegate> {
    NSArray* _sections;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MenuViewController

- (FBSession*) facebookSession {
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return delegate.facebookSession;
}

- (CoreDataStack*) dataStack {
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return delegate.dataStore;
}

- (void) constructAvailableOptions {
    
    NSMutableArray* items = [NSMutableArray new];
    for(NSUInteger section = 0; section<kSettingsTableViewSectionCount; section++) {
        NSMutableArray* secion_items = [NSMutableArray new];
        
        NSUInteger rows = 1;
        for(NSUInteger row = 0;row < rows; row++) {
            
            NSDictionary* dict;
            
            switch (section) {
                case kSettingsTableViewSectionPremium:
                {
                    if( [ContentLock tryLock] ) {
                    dict = @{
                             ITEM_TITLE_KEY : NSLocalizedString(@"Become a Premium Member", @""),
                             ITEM_ACTION_KEY : [NSValue valueWithPointer: @selector(premiumPushed:)],
                             ITEM_IMAGE_NAME_KEY : @"ic_menu_store"
                             };
                    }
                    break;
                }
                case kSettingsTableViewSectionRecommend:
                {
                    
                        dict = @{
                                 ITEM_TITLE_KEY : NSLocalizedString(@"Recommend the App", @""),
                                 ITEM_ACTION_KEY : [NSValue valueWithPointer: @selector(recommendPushed:)],
                                 ITEM_IMAGE_NAME_KEY : @"ic_menu_trophies"
                                 };
                    break;
                }
                case kSettingsTableViewSectionRate:
                {
                    dict = @{
                             ITEM_TITLE_KEY : NSLocalizedString(@"Rate the App", @""),
                                 ITEM_ACTION_KEY : [NSValue valueWithPointer: @selector(ratePushed:)],
                                 ITEM_IMAGE_NAME_KEY : @"ic_menu_fb"
                                 };
                    
                    break;
                }
                case kSettingsTableViewSectionShareFacebook:
                {
                    dict = @{
                             
                             ITEM_TITLE_KEY : NSLocalizedString(@"Like us on Facebook", @""),
                             ITEM_ACTION_KEY : [NSValue valueWithPointer: @selector(likePushed:)],
                             ITEM_IMAGE_NAME_KEY : @"ic_menu_language"
                             };
                    
                    break;
                }
                case kSettingsTableViewSectionShareTwitter:
                {
                            dict = @{
                                     ITEM_TITLE_KEY : NSLocalizedString(@"Follow us on Twitter", @""),
                                     ITEM_ACTION_KEY : [NSValue valueWithPointer: @selector(followPushed:)],
                                     ITEM_IMAGE_NAME_KEY : @"ic_menu_contact"
                                     };
   
                    break;
                }
                case kSettingsTableViewSectionContactUs:
                {
                                                dict = @{
                                     ITEM_TITLE_KEY : NSLocalizedString(@"Contact Us", @""),
                                     ITEM_ACTION_KEY : [NSValue valueWithPointer: @selector(ratePushed:)],
                                     ITEM_IMAGE_NAME_KEY : @"ic_menu_review"
                                     };
    
                    break;
                }
                default:
                    break;
            }
            
            if(dict)
                [secion_items addObject: dict];
        }
        
        if( [secion_items count] )
            [items addObject: secion_items];
    }
    
    _sections = [items copy];
}

#pragma mark - Actions
- (IBAction) contactUsPushed: (id)sender {
    MFMailComposeViewController* vc = [MFMailComposeViewController new];
    [vc setToRecipients: @[NSLocalizedString(@"contact@bentley.fr", @"")]];
    [vc setSubject: [NSString stringWithFormat: NSLocalizedString(@"%@ Support", @""), kAppName()]];
    vc.mailComposeDelegate = self;
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController: vc animated: YES completion: ^{
        
    }];
}

- (void) premiumPushed: (id) sender {
    if( [ContentLock unlockWithCompletion: ^(NSError* error) {
        
        if( !error ) {
            [self.tableView reloadData];
        }
        
        DLogError(error);
    }] ) {
        
    }
    else {
        NSString* title = NSLocalizedString(@"Store not available", @"");
        NSString* msg = NSLocalizedString(@"Your device settings are blocking the store. Please enable In-App Purchases and try again.", @"");
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                        message: msg
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                              otherButtonTitles: nil];
        [alert show];
    }
}

- (void) likePushed: (id) sender {
    /*[[self facebookSession] closeAndClearTokenInformation];
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.facebookSession = nil;
    
    NSManagedObjectContext* ctx = NSManagedObjectContextGetMain();
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName: @"Friend"];
    NSError* error;
    NSArray* allFriends = [ctx executeFetchRequest: fr error: &error];
    DLogError(error);
    for(NSManagedObject* obj in allFriends) {
        [ctx deleteObject: obj];
    }
    
    [ctx threadSafeSave: &error];
    DLogError(error); */
}

- (void) followPushed: (id) sender {
    
}

- (IBAction) recommendPushed:(id)sender {
    
}

- (IBAction) ratePushed: (id)sender {
    NSString* app_id = @"870090206";
    
#if TARGET_IPHONE_SIMULATOR
    //Can't use this for review, but works on simulator
    NSDictionary* params = @{ SKStoreProductParameterITunesItemIdentifier : @([app_id integerValue]) };
    
    SKStoreProductViewController* storeVC = [SKStoreProductViewController new];
    [storeVC loadProductWithParameters: params completionBlock: NULL];
    storeVC.delegate = self;
    [self presentViewController: storeVC animated: YES completion: NULL];
#else
    NSString* appPagePath = [NSString stringWithFormat: @"itms-apps://itunes.apple.com/app/id%@", app_id];
    
    NSURL* appPageURL = [NSURL URLWithString: appPagePath];
    
    [[UIApplication sharedApplication] openURL: appPageURL];
#endif
}

#pragma mark - UIViewController
- (void) viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self constructAvailableOptions];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [_sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_sections[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"MenuTableViewCellIdentifier" forIndexPath: indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize: 18.];
    
    NSArray* rows = _sections[indexPath.section];
    NSDictionary* data = rows[indexPath.row];
    
    cell.textLabel.text = data[ITEM_TITLE_KEY];
    cell.imageView.image = data[ITEM_IMAGE_NAME_KEY] ? [UIImage imageNamed: data[ITEM_IMAGE_NAME_KEY]] : nil;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    NSArray* rows = _sections[indexPath.section];
    NSDictionary* data = rows[indexPath.row];
    NSValue* selector = data[ITEM_ACTION_KEY];
    
    if( selector ) {
        SEL ptr = [selector pointerValue];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector: ptr withObject: [tableView cellForRowAtIndexPath: indexPath]];
#pragma clang diagnostic pop
    }
    
    JASidePanelController* panel = self.sidePanelController;
    [panel showCenterPanelAnimated: YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.;
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated: YES completion: ^{
        
    }];
}

#pragma mark - SKStoreProductsViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated: YES completion: NULL];
}


@end

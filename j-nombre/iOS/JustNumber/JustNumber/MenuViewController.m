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
#import "UIViewController+SocialMedia.h"

#import "AppDelegate.h"

#import "ContentLock.h"
#import "LifeBank.h"

@import StoreKit;
@import MessageUI;

#define ITEM_TITLE_KEY          @"text"
#define ITEM_IMAGE_NAME_KEY     @"img"
#define ITEM_ACTION_KEY         @"action"

#define kAlertViewTagSetLives   91

typedef NS_ENUM(NSUInteger, kSettingsTableViewSection) {
    
    //kSettingsTableViewSectionShareFacebook = 0,
    kSettingsTableViewSectionShareTwitter = 0,
    kSettingsTableViewSectionContactUs,
#if DEBUG
    kSettingsTableViewSectionSetLives,
#endif
    kSettingsTableViewSectionCount
};

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, SKStoreProductViewControllerDelegate, UIAlertViewDelegate> {
    NSArray* _sections;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MenuViewController

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
                /*case kSettingsTableViewSectionShareFacebook:
                {
                    dict = @{
                             
                             ITEM_TITLE_KEY : NSLocalizedString(@"Follow us on Facebook", @""),
                             ITEM_ACTION_KEY : [NSValue valueWithPointer: @selector(likePushed:)],
                             ITEM_IMAGE_NAME_KEY : @"ic_menu_language"
                             };
                    
                    break;
                } */
                case kSettingsTableViewSectionShareTwitter:
                {
                    
                    if( [SLComposeViewController isAvailableForServiceType: SLServiceTypeTwitter] ) {
                            dict = @{
                                     ITEM_TITLE_KEY : NSLocalizedString(@"Follow us on Twitter", @""),
                                     ITEM_ACTION_KEY : [NSValue valueWithPointer: @selector(followPushed:)],
                                     ITEM_IMAGE_NAME_KEY : @"ic_menu_contact"
                                     };
                    }
   
                    break;
                }
                case kSettingsTableViewSectionContactUs:
                {
                                                dict = @{
                                     ITEM_TITLE_KEY : NSLocalizedString(@"Contact Us", @""),
                                     ITEM_ACTION_KEY : [NSValue valueWithPointer: @selector(contactUsPushed:)],
                                     ITEM_IMAGE_NAME_KEY : @"ic_menu_review"
                                     };
    
                    break;
                }
#if DEBUG
                case kSettingsTableViewSectionSetLives:
                {
                    dict = @{
                             ITEM_TITLE_KEY : @"Manually Set Lives",
                             ITEM_ACTION_KEY : [NSValue valueWithPointer: @selector(setLives:)],
                             ITEM_IMAGE_NAME_KEY : @"ic_menu_review",
                             @"COLOR" : [UIColor redColor]
                             };
                    break;
                }
#endif
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
#if DEBUG
- (IBAction) setLives:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: nil
                                                    message: @"How many lives do you want?"
                                                   delegate: self
                                          cancelButtonTitle: @"Cancel"
                                          otherButtonTitles: @"Set", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = kAlertViewTagSetLives;
    [alert show];
}
#endif

- (IBAction) contactUsPushed: (id)sender {
    MFMailComposeViewController* vc = [MFMailComposeViewController new];
    [vc setToRecipients: @[NSLocalizedString(@"gilmert.bentley@gmail.com", @"")]];
    [vc setSubject: [NSString stringWithFormat: NSLocalizedString(@"%@ Support", @""), kAppName()]];
    vc.mailComposeDelegate = self;
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController: vc animated: YES completion: ^{
        
    }];
}

- (void) followPushed: (id) sender {
    [self.sidePanelController followUsOn: SLServiceTypeTwitter completion: ^(NSError *error) {
        /*if( !error ) {
            UITableViewCell* cell = (UITableViewCell*)sender;
            NSIndexPath* indexPath = [self.tableView indexPathForCell: cell];
            
            NSMutableArray* sections = [_sections mutableCopy];
            [sections removeObjectAtIndex: indexPath.row];
            _sections = [sections copy];
            
            [self.tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
        }*/
    }];
}

#pragma mark - UIViewController
- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
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
    
    UIColor* color = data[@"COLOR"];
    if( color ) {
        cell.textLabel.textColor = color;
    }
    else {
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
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

#if DEBUG
#pragma mark - UIAlertViewDelegate
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case kAlertViewTagSetLives:
        {
            if( buttonIndex != alertView.cancelButtonIndex ) {
                UITextField* field = [alertView textFieldAtIndex: 0];
                NSInteger val = [field.text intValue];
                [LifeBank set: val];
            }
            break;
        }
        default:
            break;
    }
}
#endif

@end

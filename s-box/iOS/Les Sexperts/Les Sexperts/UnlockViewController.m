//
//  UnlockViewController.m
//  Les Sexperts
//
//  Created by Paul de Lange on 14/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "UnlockViewController.h"
#import "MZFormSheetController.h"

#import "ContentLock.h"

typedef NS_ENUM(NSUInteger, kUnlockFeatureType) {
    kUnlockFeatureTypeConseils = 0,
    kUnlockFeatureTypeBlagues,
    kUnlockFeatureTypeNoAdvertisement,
    kUnlockFeatureTypeCount
};

@interface UnlockViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *titleImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;

@end

@implementation UnlockViewController

#pragma mark - Action
- (IBAction)buyPushed:(id)sender {
    BOOL tryingToUnlock = [ContentLock unlockWithCompletion: ^(NSError *error) {
        if( error ) {
            DLogError(error);
        }
        else {
            [self mz_dismissFormSheetControllerAnimated: YES
                                      completionHandler: NULL];
        }
    }];
    
    if( !tryingToUnlock ) {
        NSString* title = NSLocalizedString(@"Purchases disabled", @"");
        NSString* msg = NSLocalizedString(@"You must enable In-App Purchases in your device Settings app (General>Restrictions>In-App Purchases)", @"");
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                        message: msg
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                              otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = NSLocalizedString(@"Become The Sexpert!", @"Devenez un(e) véritable Sexpert(e)");
    [self.buyButton setTitle: NSLocalizedString(@"Become a Sexpert", @"Devenir un(e) Sexpert(e)") forState: UIControlStateNormal];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kUnlockFeatureTypeCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"UnlockFeatureCellIdentifier"
                                                            forIndexPath: indexPath];
    
    switch (indexPath.item) {
        case kUnlockFeatureTypeConseils:
            cell.imageView.image = [UIImage imageNamed: @"conseil"];
            cell.textLabel.text = NSLocalizedString(@"Unlimited Advice", @"");
            cell.detailTextLabel.text = NSLocalizedString(@"Get all the advice you need to get on top. Or bottom...", @"");
            break;
        case kUnlockFeatureTypeBlagues:
            cell.imageView.image = nil;
            cell.textLabel.text = NSLocalizedString(@"Unlimited Jokes", @"");
            cell.detailTextLabel.text = NSLocalizedString(@"In a recent survey, 77% of women found humor attractive", @"");
            break;
        case kUnlockFeatureTypeNoAdvertisement:
            cell.imageView.image = nil;
            cell.textLabel.text = NSLocalizedString(@"No Advertising", @"");
            cell.detailTextLabel.text = NSLocalizedString(@"Let nothing get in the way of you becoming a Sexpert!", @"");
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CGRectGetHeight(tableView.bounds) / kUnlockFeatureTypeCount;
}

@end

//
//  AdviceTableViewController.m
//  Les Sexperts
//
//  Created by Paul De Lange on 28/02/14.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "AdviceTableViewController.h"
#import "AdviceViewController.h"

#import "Theme.h"
#import "Advice.h"

#import "ContentLock.h"

#define     kUserDefaultsGenderPreferenceKey        @"GenderPreference"

@interface AdviceTableViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong) NSFetchedResultsController* resultsController;

@end

@implementation AdviceTableViewController

- (NSPredicate*) currentPredicate {
    kAdviceGenderType gender = [[NSUserDefaults standardUserDefaults] integerForKey: kUserDefaultsGenderPreferenceKey];
    
    NSPredicate* correctGenderPredicate = [NSPredicate predicateWithFormat: @"targetGender = %d", gender];
    NSPredicate* bothGenderPredicate = [NSPredicate predicateWithFormat: @"targetGender = %d", kAdviceGenderTypeBoth];
    NSPredicate* themePredicate = [NSPredicate predicateWithFormat: @"theme = %@", self.theme];
    
    NSPredicate* genderPredicate = [NSCompoundPredicate orPredicateWithSubpredicates: @[correctGenderPredicate, bothGenderPredicate]];
    return [NSCompoundPredicate andPredicateWithSubpredicates: @[genderPredicate, themePredicate]];
}

- (void) setTheme:(Theme *)theme {
    if( theme != _theme ) {
        _theme = theme;
        
        if( _theme ) {
            NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName: @"Advice"];
            [request setSortDescriptors: @[[NSSortDescriptor sortDescriptorWithKey: @"title" ascending: YES]]];
            
            [request setPredicate: [self currentPredicate]];
            
            self.resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: request
                                                                         managedObjectContext: kMainManagedObjectContext()
                                                                           sectionNameKeyPath: nil
                                                                                    cacheName: nil];
            self.resultsController.delegate = self;
        }
        else {
            self.resultsController = nil;
        }
        
        self.title = _theme.name;
        
        if( [self isViewLoaded] ) {
            NSError* error;
            [self.resultsController performFetch: &error];
            DLogError(error);
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Actions
- (IBAction)genderScopeValueChanged:(id)sender {
    kAdviceGenderType type = self.genderSegmentedControl.selectedSegmentIndex == 0 ? kAdviceGenderTypeMale : kAdviceGenderTypeFemale;
    [[NSUserDefaults standardUserDefaults] setInteger: type forKey: kUserDefaultsGenderPreferenceKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSFetchRequest* fetchRequest = self.resultsController.fetchRequest;
    [fetchRequest setPredicate: [self currentPredicate]];
    
    NSError* error;
    [self.resultsController performFetch: &error];
    DLogError(error);
    [self.tableView reloadData];
}

#pragma mark - NSObject
+ (void) initialize {
    [[NSUserDefaults standardUserDefaults] registerDefaults: @{kUserDefaultsGenderPreferenceKey : @(kAdviceGenderTypeMale)}];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSError* error;
    [self.resultsController performFetch: &error];
    DLogError(error);
    [self.tableView reloadData];
    
    kAdviceGenderType gender = [[NSUserDefaults standardUserDefaults] integerForKey: kUserDefaultsGenderPreferenceKey];
    switch (gender) {
        case kAdviceGenderTypeMale:
            [self.genderSegmentedControl setSelectedSegmentIndex: 0];
            break;
        case kAdviceGenderTypeFemale:
            [self.genderSegmentedControl setSelectedSegmentIndex: 1];
            break;
        default:
            break;
    }
    
    [self.genderSegmentedControl setTitle: NSLocalizedString(@"Pour LUI", @"") forSegmentAtIndex: 0];
    [self.genderSegmentedControl setTitle: NSLocalizedString(@"Pour ELLE", @"") forSegmentAtIndex: 1];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString: @"AdvicePushSegue"] ) {
        NSParameterAssert([segue.destinationViewController isKindOfClass: [AdviceViewController class]]);
        NSParameterAssert([sender isKindOfClass: [UITableViewCell class]]);
        AdviceViewController* adviceTV = (AdviceViewController*)segue.destinationViewController;
        NSIndexPath* indexPath = [self.tableView indexPathForCell: sender];
        Advice* advice = [self.resultsController objectAtIndexPath: indexPath];
        adviceTV.advice = advice;
    }
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if( [identifier isEqualToString: @"AdvicePushSegue"] ) {
        NSIndexPath* indexPath = [self.tableView indexPathForCell: sender];
        if( indexPath.row ) {
            BOOL available = [ContentLock tryLock];
            
            if( !available ) {
                BOOL tryingToUnlock = [ContentLock unlockWithCompletion: ^(NSError *error) {
                    if( error ) {
                        DLogError(error);
                    }
                    else {
                        NSParameterAssert([ContentLock tryLock]);
                        
                        [self performSegueWithIdentifier: identifier sender: sender];
                        
                        [self.tableView reloadData];
                    }
                }];
                
                if( !tryingToUnlock ) {
                    NSString* title = NSLocalizedString(@"Purchases disabled", @"");
                    NSString* msg = NSLocalizedString(@"You must enable In-App Purchases in your device Settings app (General > Restrictions > In-App Purchases)", @"");
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                                    message: msg
                                                                   delegate: nil
                                                          cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                                          otherButtonTitles: nil];
                    [alert show];
                }
            }
            
            return available;
        }
    }
    
    return YES;
}

#pragma mark - UITableViewDataSource
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"AdviceTableViewCellIdentifier" forIndexPath: indexPath];
    
    Advice* advice = [self.resultsController objectAtIndexPath: indexPath];
    cell.textLabel.text = advice.title;
    
    if( indexPath.row ) {
        cell.imageView.image = [ContentLock tryLock] ? nil : [UIImage imageNamed: @"lock_icon"];
    }
    else {
        cell.imageView.image = nil;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> info = [self.resultsController.sections objectAtIndex: section];
    return [info numberOfObjects];
}

@end

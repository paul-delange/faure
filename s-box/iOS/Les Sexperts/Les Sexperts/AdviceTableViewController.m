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

#import "MZFormSheetController.h"

NSString * const NSUserDefaultsAdviceAvailableCount = @"8A9EA00C4";

@interface AdviceTableViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong) NSFetchedResultsController* resultsController;

@end

@implementation AdviceTableViewController

- (NSPredicate*) currentPredicate {
    NSPredicate* themePredicate = [NSPredicate predicateWithFormat: @"theme = %@", self.theme];
    
    return themePredicate;
}

- (void) setTheme:(Theme *)theme {
    if( theme != _theme ) {
        _theme = theme;
        
        if( _theme ) {
            NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName: @"Advice"];
            [request setSortDescriptors: @[[NSSortDescriptor sortDescriptorWithKey: @"free" ascending: NO],
                                           [NSSortDescriptor sortDescriptorWithKey: @"title" ascending: YES]]];
            
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
        self.screenName = _theme.name;
        
        if( [self isViewLoaded] ) {
            NSError* error;
            [self.resultsController performFetch: &error];
            DLogError(error);
            [self.tableView reloadData];
        }
    }
}

- (void) contentWasUnlocked: (NSNotification*) notification  {
    [self.tableView reloadData];
}

#pragma mark - NSObject
+ (void) initialize {
    NSDictionary* params = @{ NSUserDefaultsAdviceAvailableCount : @(0) };
    [[NSUserDefaults standardUserDefaults] registerDefaults: params];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if( self ) {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(contentWasUnlocked:)
                                                     name: ContentLockWasRemovedNotification
                                                   object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(contentWasUnlocked:)
                                                     name: NSUserDefaultsDidChangeNotification
                                                   object: nil];
        
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
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
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self.tableView reloadData];
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
        Advice* advice = [self.resultsController objectAtIndexPath: indexPath];
        
        if( !advice.freeValue && [ContentLock tryLock] ) {
            
            NSInteger freeLeft = [[NSUserDefaults standardUserDefaults] integerForKey: NSUserDefaultsAdviceAvailableCount];
            if( freeLeft > 0 ) {
                freeLeft--;
                
                [[NSUserDefaults standardUserDefaults] setInteger: freeLeft forKey: NSUserDefaultsAdviceAvailableCount];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self.tableView reloadData];
                return YES;
            }
            
            UIViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier: @"UnlockViewController"];
            
            MZFormSheetController* formSheet = [[MZFormSheetController alloc] initWithViewController: vc];
            formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
            formSheet.presentedFormSheetSize = CGSizeMake(300., 360.);
            formSheet.didTapOnBackgroundViewCompletionHandler = ^(CGPoint location) {
                [self mz_dismissFormSheetControllerAnimated: YES completionHandler: NULL];
            };
            [self mz_presentFormSheetController: formSheet
                                       animated: YES
                              completionHandler: NULL];
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - UITableViewDataSource
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"AdviceTableViewCellIdentifier" forIndexPath: indexPath];
    
    Advice* advice = [self.resultsController objectAtIndexPath: indexPath];
    cell.textLabel.text = advice.title;
    
    if( !advice.freeValue && [ContentLock tryLock] ) {
        if( [[NSUserDefaults standardUserDefaults] integerForKey: NSUserDefaultsAdviceAvailableCount] > 0 )
            cell.accessoryView = nil;
        else
            cell.accessoryView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"lock_icon"]];
    }
    else {
        cell.accessoryView = nil;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> info = [self.resultsController.sections objectAtIndex: section];
    return [info numberOfObjects];
}

#pragma mark - UITableViewDelegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

@end

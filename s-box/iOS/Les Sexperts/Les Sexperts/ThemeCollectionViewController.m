//
//  ThemeCollectionViewController.m
//  Les Sexperts
//
//  Created by Paul De Lange on 28/02/14.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "ThemeCollectionViewController.h"
#import "AdviceTableViewController.h"

#import "Theme.h"

#import "ThemeCollectionViewCell.h"

@interface ThemeCollectionViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong) NSFetchedResultsController* resultsController;

@end

@implementation ThemeCollectionViewController

#pragma mark - NSObject
- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if( self ) {
        self.title = NSLocalizedString(@"Themes", @"");
    }
    return self;
}

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName: @"Theme"];
    [fetchRequest setSortDescriptors: @[[NSSortDescriptor sortDescriptorWithKey: @"name" ascending: YES]]];
    
    self.resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                 managedObjectContext: kMainManagedObjectContext()
                                                                   sectionNameKeyPath: nil
                                                                            cacheName: @"ThemeCache"];
    self.resultsController.delegate = self;
    NSError* error;
    [self.resultsController performFetch: &error];
    DLogError(error);
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.tableView reloadData];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    
    [self.navigationController setNavigationBarHidden: NO animated: YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString: @"AdvicePushSegue"] ) {
        NSParameterAssert([segue.destinationViewController isKindOfClass: [AdviceTableViewController class]]);
        NSParameterAssert([sender isKindOfClass: [UITableViewCell class]]);
        AdviceTableViewController* adviceTVC = (AdviceTableViewController*)segue.destinationViewController;
        NSIndexPath* indexPath = [self.tableView indexPathForCell: sender];
        Theme* theme = [self.resultsController objectAtIndexPath: indexPath];
        adviceTVC.theme = theme;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.resultsController.sections objectAtIndex: section];
    return [sectionInfo numberOfObjects];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ThemeCollectionViewCell* cell = (ThemeCollectionViewCell*)[tableView dequeueReusableCellWithIdentifier: @"AdviceCellIdentifier" forIndexPath: indexPath];
    NSParameterAssert(cell);
    
    Theme* theme = [self.resultsController objectAtIndexPath: indexPath];
    cell.textLabel.text = theme.name;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.;
}

@end

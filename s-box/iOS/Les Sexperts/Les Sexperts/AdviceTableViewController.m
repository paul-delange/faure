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

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if( self ) {
        
    }
    return self;
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
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString: @"AdvicePushSegue"] ) {
        NSParameterAssert([segue.destinationViewController isKindOfClass: [AdviceViewController class]]);
        NSParameterAssert([sender isKindOfClass: [UITableViewCell class]]);
        AdviceViewController* adviceTV = (AdviceViewController*)segue.destinationViewController;
        NSIndexPath* indexPath = [self.tableView indexPathForCell: sender];
        Advice* advice = [self.resultsController objectAtIndexPath: indexPath];
        adviceTV.advice = advice;
        
        if( indexPath.row && [ContentLock tryLock] )
            adviceTV.blocked = YES;
    }
}

#pragma mark - UITableViewDataSource
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"AdviceTableViewCellIdentifier" forIndexPath: indexPath];
    
    Advice* advice = [self.resultsController objectAtIndexPath: indexPath];
    cell.textLabel.text = advice.title;
    /*
    if( indexPath.row ) {
        cell.imageView.image = [ContentLock tryLock] ? nil : [UIImage imageNamed: @"lock_icon"];
    }
    else {
        cell.imageView.image = nil;
    }*/
    
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

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

@interface ThemeCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate>

@property (strong) NSFetchedResultsController* resultsController;

@end

@implementation ThemeCollectionViewController

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName: @"Theme"];
    [fetchRequest setSortDescriptors: @[[NSSortDescriptor sortDescriptorWithKey: @"name" ascending:@""]]];
    
    self.resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                 managedObjectContext: kMainManagedObjectContext()
                                                                   sectionNameKeyPath: nil
                                                                            cacheName: @"ThemeCache"];
    self.resultsController.delegate = self;
    NSError* error;
    [self.resultsController performFetch: &error];
    DLogError(error);
    
    [self.collectionView reloadData];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString: @"AdvicePushSegue"] ) {
        NSParameterAssert([segue.destinationViewController isKindOfClass: [AdviceTableViewController class]]);
        NSParameterAssert([sender isKindOfClass: [UICollectionViewCell class]]);
        AdviceTableViewController* adviceTVC = (AdviceTableViewController*)segue.destinationViewController;
        NSIndexPath* indexPath = [self.collectionView indexPathForCell: sender];
        Theme* theme = [self.resultsController objectAtIndexPath: indexPath];
        adviceTVC.theme = theme;
    }
}

#pragma mark - UICollectionViewDataSource 
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.resultsController.sections objectAtIndex: section];
    return [sectionInfo numberOfObjects];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ThemeCollectionViewCell* cell = (ThemeCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier: @"AdviceCellIdentifier" forIndexPath: indexPath];
    NSParameterAssert(cell);
    
    Theme* theme = [self.resultsController objectAtIndexPath: indexPath];
    cell.textLabel.text = theme.name;
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds)/2.f-10, 60);
}

@end

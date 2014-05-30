//
//  ResultsViewController.h
//  Les Sexperts
//
//  Created by Paul de Lange on 4/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GAITrackedViewController.h"

@interface ResultsViewController : GAITrackedViewController

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (copy) NSArray* questionsArray;
@property (copy) NSArray* answersArray;

@end

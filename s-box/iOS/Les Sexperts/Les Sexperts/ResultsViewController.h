//
//  ResultsViewController.h
//  Les Sexperts
//
//  Created by Paul de Lange on 4/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *totalScoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@property (copy) NSArray* questionsArray;
@property (copy) NSArray* answersArray;

@end

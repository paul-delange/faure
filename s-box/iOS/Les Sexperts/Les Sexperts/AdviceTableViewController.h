//
//  AdviceTableViewController.h
//  Les Sexperts
//
//  Created by Paul De Lange on 28/02/14.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GAITrackedViewController.h"

@class Theme;

@interface AdviceTableViewController : GAITrackedViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) Theme* theme;

@end

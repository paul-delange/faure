//
//  HomeViewController.m
//  Les Sexperts
//
//  Created by Paul De Lange on 28/02/14.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "HomeViewController.h"

#import "Joke.h"

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation HomeViewController

#pragma mark - Actions
- (IBAction)menuPushed:(id)sender {

}

- (IBAction)unwindGame:(UIStoryboardSegue*)sender {
    
}

#pragma mark - UIViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UITableView* tableView = [[UITableView alloc] initWithFrame: self.view.bounds];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview: tableView];
    [tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: nil];
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Jouer";
            break;
        case 1:
            cell.textLabel.text = @"Conseils";
            break;
        case 2:
            cell.textLabel.text = @"Blagues";
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath: indexPath];
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier: @"GamePushSegue" sender: cell];
            break;
        case 1:
            [self performSegueWithIdentifier: @"ThemePushSegue" sender: cell];
            break;
            
        case 2:
            [self performSegueWithIdentifier: @"JokePushSegue" sender: cell];
            break;
        default:
            break;
    }
}

@end

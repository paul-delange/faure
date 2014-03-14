//
//  HomeViewController.m
//  Les Sexperts
//
//  Created by Paul De Lange on 28/02/14.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "HomeViewController.h"

#import "Joke.h"

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *adviceButton;
@property (weak, nonatomic) IBOutlet UIButton *jokeButton;

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
}

@end

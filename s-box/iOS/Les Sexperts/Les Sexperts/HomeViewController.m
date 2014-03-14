//
//  HomeViewController.m
//  Les Sexperts
//
//  Created by Paul De Lange on 28/02/14.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "HomeViewController.h"
#import "MZFormSheetController.h"

#import "Joke.h"

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *adviceButton;
@property (weak, nonatomic) IBOutlet UIButton *jokeButton;
@property (weak, nonatomic) IBOutlet UIButton *upgradeButton;

@end

@implementation HomeViewController

#pragma mark - Actions
- (IBAction)menuPushed:(id)sender {

}

- (IBAction)upgradePushed:(id)sender {
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
}

- (IBAction)unwindGame:(UIStoryboardSegue*)sender {
    
}

#pragma mark - NSObject
+ (void) initialize {
    [super initialize];
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
    [self.playButton setTitle: NSLocalizedString(@"Play", @"") forState: UIControlStateNormal];
    [self.adviceButton setTitle: NSLocalizedString(@"Advice", @"") forState: UIControlStateNormal];
    [self.jokeButton setTitle: NSLocalizedString(@"Jokes", @"") forState: UIControlStateNormal];
    [self.upgradeButton setTitle: NSLocalizedString(@"Become a Sexpert", @"Devenir un(e) Sexpert(e)") forState: UIControlStateNormal];
}

@end

//
//  JokePageViewController.m
//  Les Sexperts
//
//  Created by Paul de Lange on 4/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "JokePageViewController.h"
#import "JokeViewController.h"

#import "Joke.h"

#import <AdColony/AdColony.h>

@import MessageUI;

@interface JokePageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, MFMailComposeViewControllerDelegate> {
    NSArray* _jokes;
    Joke*    _currentJoke;
}

@end

@implementation JokePageViewController

#pragma mark - Actions
- (IBAction) addPushed:(id)sender {
    MFMailComposeViewController* mailVC = [MFMailComposeViewController new];
    mailVC.mailComposeDelegate = self;
    
    NSString* format = NSLocalizedString(@"%@: Joke Submission", @"");
    [mailVC setSubject: [NSString stringWithFormat: format, kAppName()]];
    [mailVC setToRecipients: @[@"gilmert.bentley@gmail.com"]];
    
    [self presentViewController: mailVC animated: YES completion: NULL];
}

- (IBAction) sharePushed:(id)sender {
    if( [_currentJoke.text length] ) {
        NSString* format = NSLocalizedString(@"'%@'\n\nJoke from %@", @"");
        NSString* msg = [NSString stringWithFormat: format, _currentJoke.text, kAppName()];
        
        UIActivityViewController* activityVC = [[UIActivityViewController alloc] initWithActivityItems: @[msg]
                                                                                 applicationActivities: nil];
        activityVC.completionHandler = ^(NSString* activityType, BOOL completed) {
            
        };
        
        [self presentViewController: activityVC animated: YES completion: NULL];
    }
}

#pragma mark - NSObject
- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if( self) {
        self.dataSource = self;
        self.delegate = self;
        
        NSFetchRequest* fetch = [NSFetchRequest fetchRequestWithEntityName: @"Joke"];
        NSMutableArray* results = [[kMainManagedObjectContext() executeFetchRequest: fetch error: nil] mutableCopy];
        NSUInteger count = [results count];
        for (NSUInteger i = 0; i < count; ++i) {
            // Select a random element between i and end of array to swap with.
            NSInteger nElements = count - i;
            NSInteger n = arc4random_uniform(nElements) + i;
            [results exchangeObjectAtIndex:i withObjectAtIndex:n];
        }
        
        _jokes = [results copy];
    }
    
    return self;
}

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Jokes", @"");
    
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd
                                                                               target: self
                                                                               action: @selector(addPushed:)];
    UIBarButtonItem* shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAction
                                                                                 target: self
                                                                                 action: @selector(sharePushed:)];
    if( [MFMailComposeViewController canSendMail] )
        self.navigationItem.rightBarButtonItems = @[shareButton, addButton];
    else
        self.navigationItem.rightBarButtonItems = @[shareButton];
    
    UIViewController* vc = [self pageViewController: self viewControllerAfterViewController: nil];
    [self setViewControllers: @[vc] direction: UIPageViewControllerNavigationDirectionForward animated: NO completion: NULL];
    _currentJoke = _jokes[0];
}

// Custom logic goes here.
#pragma mark - UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    UIStoryboard* storyboard = pageViewController.storyboard;
    
    JokeViewController* previousVC = (JokeViewController*)viewController;
    
    Joke* previousJoke = previousVC.joke;
    
    //TODO: Maybe need to watch video:
    // ZoneID: vz51c5cf827bd54c548a
    
    if( previousJoke ) {
        NSUInteger index = [_jokes indexOfObject: previousJoke];
        if( index < [_jokes count] - 1 ) {
            JokeViewController* newVC = [storyboard instantiateViewControllerWithIdentifier: @"JokeViewController"];
            newVC.joke = _jokes[index+1];
            return newVC;
        }
    }
    else {
        JokeViewController* newVC = [storyboard instantiateViewControllerWithIdentifier: @"JokeViewController"];
        newVC.joke = _jokes[0];
        return newVC;
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    UIStoryboard* storyboard = pageViewController.storyboard;
    
    JokeViewController* previousVC = (JokeViewController*)viewController;
    
    Joke* previousJoke = previousVC.joke;
    
    NSUInteger index = [_jokes indexOfObject: previousJoke];
    if( index > 0 ) {
        JokeViewController* newVC = [storyboard instantiateViewControllerWithIdentifier: @"JokeViewController"];
        newVC.joke = _jokes[index-1];
        return newVC;
    }
    else {
        return nil;
    }
}

#pragma mark - UIPageViewControllerDelegate
- (void) pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    NSParameterAssert([pendingViewControllers count] == 1);
    JokeViewController* jokeVC = [pendingViewControllers lastObject];
    _currentJoke = jokeVC.joke;
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated: YES completion: NULL];
}

@end

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
#import "ContentLock.h"

#import "UnlockViewController.h"
#import "MZFormSheetController.h"

@import MessageUI;

@interface JokePageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, MFMailComposeViewControllerDelegate> {
    NSArray* _jokes;
    Joke*    _currentJoke;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem* backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* nextButton;
@property (weak) UIBarButtonItem* shareButton;
@property (weak, nonatomic) IBOutlet UILabel* counterLabel;

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

- (IBAction) nextPushed:(id)sender {
    UIViewController* currentVC;
    for(JokeViewController* jokeVC in self.viewControllers) {
        if( [jokeVC.joke isEqual: _currentJoke] ) {
            currentVC = jokeVC;
            break;
        }
    }
    
    JokeViewController* nextVC = (JokeViewController*)[self pageViewController: self viewControllerAfterViewController: currentVC];
    if( nextVC ) {
        [self setViewControllers: @[nextVC] direction: UIPageViewControllerNavigationDirectionForward animated: YES completion: NULL];
        [self pageViewController: self willTransitionToViewControllers: @[nextVC]];
    }
}

- (IBAction) previousPushed:(id)sender {
    UIViewController* currentVC;
    for(JokeViewController* jokeVC in self.viewControllers) {
        if( [jokeVC.joke isEqual: _currentJoke] ) {
            currentVC = jokeVC;
            break;
        }
    }
    
    JokeViewController* previousVC = (JokeViewController*)[self pageViewController: self viewControllerBeforeViewController: currentVC];
    if( previousVC ) {
        [self setViewControllers: @[previousVC] direction: UIPageViewControllerNavigationDirectionReverse animated: YES completion: NULL];
        [self pageViewController: self willTransitionToViewControllers: @[previousVC]];
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
            NSInteger n = arc4random_uniform((uint32_t)nElements) + i;
            [results exchangeObjectAtIndex:i withObjectAtIndex:n];
        }
        
        _jokes = [results copy];
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
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
    
    self.shareButton = shareButton;
    
    UIViewController* vc = [self pageViewController: self viewControllerAfterViewController: nil];
    [self setViewControllers: @[vc] direction: UIPageViewControllerNavigationDirectionForward animated: NO completion: NULL];
    _currentJoke = _jokes[0];
    
    UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, CGRectGetHeight(self.view.frame)-44., CGRectGetWidth(self.view.frame), 44.)];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRewind
                                                                                target: self
                                                                                action: @selector(previousPushed:)];
    UIBarButtonItem* nextButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFastForward
                                                                                target: self
                                                                                action: @selector(nextPushed:)];
    
    UILabel* countLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 100, 32)];
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.textColor = [UIColor whiteColor];
    countLabel.font = [UIFont fontWithName: @"American Typewriter" size: 15.];
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.text = @"";//[NSString stringWithFormat: NSLocalizedString( @"%@/%@", @""), @(1), @(_jokes.count)];
    
    [toolbar setItems: @[ backButton,
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                          [[UIBarButtonItem alloc] initWithCustomView: countLabel],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                          nextButton
                          ]];
    
    backButton.enabled = NO;
    
    //self.counterLabel = countLabel;
    self.nextButton = nextButton;
    self.backButton = backButton;
    
    [self.view addSubview: toolbar];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self.navigationController setNavigationBarHidden: NO animated: YES];
}

// Custom logic goes here.
#pragma mark - UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    UIStoryboard* storyboard = pageViewController.storyboard;
    
    JokeViewController* previousVC = (JokeViewController*)viewController;
    
    Joke* previousJoke = previousVC.joke;
    
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
    
    NSUInteger index = [_jokes indexOfObject: _currentJoke];
    
    self.counterLabel.text = [NSString stringWithFormat: NSLocalizedString( @"%@/%@", @""), @(index+1), @(_jokes.count)];
    
    jokeVC.blocked = !_currentJoke.freeValue && [ContentLock tryLock];
    self.shareButton.enabled = !jokeVC.blocked;
    NSLog(@"Blocked: %d", jokeVC.blocked);
    
    if( jokeVC.blocked && !self.formSheetController ) {
        UnlockViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier: @"UnlockViewController"];
        
        
        MZFormSheetController* formSheet = [[MZFormSheetController alloc] initWithViewController: vc];
        formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
        formSheet.presentedFormSheetSize = CGSizeMake(300., 360.);
        formSheet.didTapOnBackgroundViewCompletionHandler = ^(CGPoint location) {
            [self mz_dismissFormSheetControllerAnimated: YES completionHandler: NULL];
        };
        [self mz_presentFormSheetController: formSheet
                                   animated: YES
                          completionHandler: ^(MZFormSheetController* controller) {
                              vc.canWatchVideo = NO;
                          }];
    }
    
    if( [_currentJoke isEqual: [_jokes lastObject]] ) {
        self.nextButton.enabled = NO;
    }
    else if( [_currentJoke isEqual: _jokes[0]] ) {
        self.backButton.enabled = NO;
    }
    else {
        self.nextButton.enabled = YES;
        self.backButton.enabled = YES;
    }
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated: YES completion: NULL];
}

@end

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

#import <AdColony/AdColony.h>

@import MessageUI;

@interface JokePageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, MFMailComposeViewControllerDelegate, AdColonyAdDelegate> {
    NSArray* _jokes;
    Joke*    _currentJoke;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem* backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* nextButton;
@property (weak, nonatomic) IBOutlet UILabel* counterLabel;

@property (weak, nonatomic) IBOutlet UIView* blockedMessageView;

@end

@implementation JokePageViewController

- (UIView*) blockedView {
    
    UIView* blockedBackground = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 300, 180)];
    blockedBackground.center = CGPointMake(160, CGRectGetMidY(self.view.bounds));
    blockedBackground.backgroundColor = [UIColor blackColor];
    blockedBackground.layer.borderColor = [[UIColor whiteColor] CGColor];
    blockedBackground.layer.borderWidth = 2.;
    blockedBackground.layer.cornerRadius = 10.;
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"lock_icon"]];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel* textLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    textLabel.text = NSLocalizedString(@"Blocked! To see this joke, you can:", @"");
    textLabel.numberOfLines = 0;
    textLabel.font = [UIFont fontWithName: @"American Typewriter" size: 20.];
    
    UIButton* videoButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [videoButton setTitle: NSLocalizedString(@"i. Watch a free video...", @"") forState: UIControlStateNormal];
    [videoButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [videoButton setTitleColor: [UIColor lightGrayColor] forState: UIControlStateHighlighted];
    [videoButton addTarget: self action: @selector(videoPushed:) forControlEvents: UIControlEventTouchUpInside];
    videoButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    videoButton.translatesAutoresizingMaskIntoConstraints = NO;
    videoButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [videoButton.titleLabel setFont: [UIFont fontWithName: @"American Typewriter" size: 15.]];
    
    UIButton* unlockButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [unlockButton setTitle: NSLocalizedString(@"ii. Unlock the app...", @"") forState: UIControlStateNormal];
    [unlockButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [unlockButton setTitleColor: [UIColor lightGrayColor] forState: UIControlStateHighlighted];
    [unlockButton addTarget: self action: @selector(unlockPushed:) forControlEvents: UIControlEventTouchUpInside];
    unlockButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [unlockButton.titleLabel setFont: [UIFont fontWithName: @"American Typewriter" size: 15.]];
    unlockButton.translatesAutoresizingMaskIntoConstraints = NO;
    unlockButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    [blockedBackground addSubview: imageView];
    [blockedBackground addSubview: textLabel];
    [blockedBackground addSubview: videoButton];
    [blockedBackground addSubview: unlockButton];
    
    [blockedBackground addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-[imageView]-[textLabel]-|"
                                                                               options: 0
                                                                               metrics: nil
                                                                                 views: NSDictionaryOfVariableBindings(imageView, textLabel)]];
    [blockedBackground addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-[imageView]"
                                                                               options: 0
                                                                               metrics: nil
                                                                                 views: NSDictionaryOfVariableBindings(imageView)]];
    [blockedBackground addConstraint: [NSLayoutConstraint constraintWithItem: textLabel
                                                                    attribute: NSLayoutAttributeCenterY
                                                                   relatedBy: NSLayoutRelationEqual
                                                                      toItem: imageView
                                                                   attribute: NSLayoutAttributeCenterY
                                                                  multiplier: 1.
                                                                    constant: 0.]];
    [blockedBackground addConstraint: [NSLayoutConstraint constraintWithItem: imageView
                                                                   attribute: NSLayoutAttributeHeight
                                                                   relatedBy: NSLayoutRelationEqual
                                                                      toItem: imageView
                                                                   attribute: NSLayoutAttributeWidth
                                                                  multiplier: 1.0
                                                                    constant: 0.0]];
    [blockedBackground addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-[videoButton]-|"
                                                                               options: 0
                                                                               metrics: nil
                                                                                 views: NSDictionaryOfVariableBindings(videoButton)]];
    [blockedBackground addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:[imageView]-[videoButton]"
                                                                               options: 0
                                                                               metrics: nil
                                                                                 views: NSDictionaryOfVariableBindings(imageView, videoButton)]];
    [blockedBackground addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-[unlockButton]-|"
                                                                               options: 0
                                                                               metrics: nil
                                                                                 views: NSDictionaryOfVariableBindings(unlockButton)]];
    [blockedBackground addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:[videoButton]-[unlockButton]"
                                                                               options: 0
                                                                               metrics: nil
                                                                                 views: NSDictionaryOfVariableBindings(unlockButton, videoButton)]];
    
    return blockedBackground;
}

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

- (IBAction) videoPushed:(id)sender {
    [AdColony playVideoAdForZone: @"vz51c5cf827bd54c548a"
                    withDelegate: self
                withV4VCPrePopup: YES
                andV4VCPostPopup: YES];
}

- (IBAction) unlockPushed:(id)sender {
    BOOL tryingToUnlock = [ContentLock unlockWithCompletion: ^(NSError *error) {
        if( error ) {
            DLogError(error);
        }
        else {
            NSParameterAssert([ContentLock tryLock]);
            [UIView transitionWithView: self.view
                              duration: 0.3
                               options: UIViewAnimationOptionCurveEaseInOut
                            animations: ^{
                                [self.blockedMessageView removeFromSuperview];
                                for(JokeViewController* jokeVC in self.viewControllers) {
                                    if( [jokeVC.joke isEqual: _currentJoke] ) {
                                        jokeVC.blocked = NO;
                                    }
                                }
                            } completion: NULL];
        }
    }];
    
    if( !tryingToUnlock ) {
        NSString* title = NSLocalizedString(@"Purchases disabled", @"");
        NSString* msg = NSLocalizedString(@"You must enable In-App Purchases in your device Settings app (General > Restrictions > In-App Purchases)", @"");
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                        message: msg
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                              otherButtonTitles: nil];
        [alert show];
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
    countLabel.text = [NSString stringWithFormat: NSLocalizedString( @"%@/%@", @""), @(1), @(_jokes.count)];
    
    [toolbar setItems: @[ backButton,
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                          [[UIBarButtonItem alloc] initWithCustomView: countLabel],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                          nextButton
                          ]];
    
    backButton.enabled = NO;
    
    self.counterLabel = countLabel;
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
    
    jokeVC.blocked = index >= 10 && ![ContentLock tryLock];
    
    if( jokeVC.blocked && !self.blockedMessageView ) {
        UIView* msgView = [self blockedView];
        [UIView transitionWithView: self.view
                          duration: 0.3
                           options: UIViewAnimationOptionCurveEaseIn
                        animations: ^{
                            [self.view addSubview: msgView];
                        } completion:^(BOOL finished) {
                            self.blockedMessageView = msgView;
                        }];
    }
    else if( !jokeVC.blocked ) {
        [UIView transitionWithView: self.view
                          duration: 0.3
                           options: UIViewAnimationOptionCurveEaseOut
                        animations: ^{
                            [self.blockedMessageView removeFromSuperview];
                        } completion:^(BOOL finished) {
                            self.blockedMessageView = nil;
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

#pragma mark - AdColonyAdDelegate
- ( void ) onAdColonyAdStartedInZone:( NSString * )zoneID {
    
}

- ( void ) onAdColonyAdAttemptFinished:(BOOL)shown inZone:( NSString * )zoneID {
    if( shown ) {
        [UIView transitionWithView: self.view
                          duration: 0.3
                           options: UIViewAnimationOptionCurveEaseOut
                        animations: ^{
                            [self.blockedMessageView removeFromSuperview];
                            
                            for(JokeViewController* jokeVC in self.viewControllers) {
                                if( [jokeVC.joke isEqual: _currentJoke] ) {
                                    jokeVC.blocked = NO;
                                }
                            }
                            
                        } completion: NULL];
    }
}

@end

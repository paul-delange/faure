//
//  GameViewController.m
//  JustNumber
//
//  Created by Paul de Lange on 27/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "GameViewController.h"
#import "GameViewController+Animations.h"
#import "UIViewController+SocialMedia.h"

#import "UINumberField.h"

#import "Level.h"
#import "Question.h"
#import "ScoreSheet.h"

#import "LifeBank.h"
#import "ContentLock.h"

#import "LifeCountView.h"
#import "GuessView.h"
#import "JokerButton.h"

#import "UIImage+ImageEffects.h"

#import "CoreDataStack.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GADInterstitial.h"

#define kAlertViewCorrectTag    914
#define kAlertViewHelpExpTag    918
#define kAlertViewBragTag       917
#define kAlertViewLastLifeTag   919
#define kAlertViewEndGameTag    916

static NSString * const NSUserDefaultsShownHelpExplanation  = @"HelpExplanationShown";
static NSString * const NSUserDefaultsShownJokerExplanation  = @"JokerExplanationShown";

@interface GameViewController () <UINumberFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate, GADInterstitialDelegate> {
    GADInterstitial *_interstitial;
}

@property (weak, nonatomic) IBOutlet UINumberField *inputView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *numberButtons;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet JokerButton *jokerButton;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak) IBOutlet LifeCountView* lifeCountView;
@property (weak, nonatomic) IBOutlet GuessView *guessView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *jokerLabel;

@end

@implementation GameViewController

- (void) updateWithQuestion: (Question*) question animated: (BOOL) animated {
    
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.duration = 0.3;
    [self.questionLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
    
    
    self.questionLabel.text = question.text;
    
    self.inputView.unitString = question.unit;
    self.inputView.automaticallyFormatsInput = question.formatsValue;
    
    self.okButton.enabled = NO;
    self.title = [NSString localizedStringWithFormat: NSLocalizedString(@"Level %@", @""), self.level.identifier];
    
    self.guessView.actualValue = question.answer;
    self.guessView.automaticallyFormatsInput = question.formatsValue;
    self.guessView.unitString = question.unit;
    
    BOOL jokerVisible = [[ScoreSheet currentScoreSheet] jokerUsedForQuestion: question];
    self.jokerButton.enabled = !jokerVisible;
    self.jokerLabel.text = jokerVisible ? [question rangeString] : @"";
    
    DLog(@"Ans: %@", question.answer);
}

- (void) leveledUp {
    //self.level is already set
    
    if( self.level.identifierValue % 3 == 0 ) {
        [self animateMessage: NSLocalizedString(@"New Level!", @"") completion:^(BOOL finished) {
            if( _interstitial.isReady && [ContentLock tryLock]) {
                [_interstitial presentFromRootViewController: self];
            }
        }];
    }
}

- (void) advance {
    if( [self.level nextQuestion] ) {
        [self updateWithQuestion: [self.level nextQuestion] animated: YES];
    }
    else {
        self.level = [self.level nextLevel];
        
        if( self.level ) {
            NSAssert([self.level nextQuestion], @"No questions for level %@", self.level);
            [self updateWithQuestion: [self.level nextQuestion] animated: YES];
            [self leveledUp];
        }
        else {
            NSString* title = NSLocalizedString(@"No more levels!", @"");
            NSString* msg = NSLocalizedString(@"New levels are coming soon, follow us on Facebook or Twitter to find out more!", @"");
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                            message: msg
                                                           delegate: self
                                                  cancelButtonTitle: NSLocalizedString(@"Back", @"")
                                                  otherButtonTitles: NSLocalizedString(@"Facebook", @""), NSLocalizedString(@"Twitter", @""), nil];
            alert.tag = kAlertViewEndGameTag;
            [alert show];
            
            NSLocale* locale = NSManagedObjectContextGetMain().locale;
            [[[GAI sharedInstance] defaultTracker] send: [[GAIDictionaryBuilder createEventWithCategory: @"Feature Requests"
                                                                                                 action: @"New Levels"
                                                                                                  label: locale.localeIdentifier
                                                                                                  value: nil] build]];
        }
    }
    
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.duration = 0.3;
    [self.inputView.layer addAnimation:animation forKey:@"kCATransitionFade"];
}

#pragma mark - Actions
- (IBAction)numberPushed:(UIButton *)sender {
    NSInteger index = [self.numberButtons indexOfObject: sender];
    [self.inputView appendInteger: index];
}

- (IBAction)jokerPushed:(UIButton*)sender {
    
    NSUInteger lives = [LifeBank count];
    
    if( lives < COST_OF_JOKER ) {
        //Can not attempt -> show popup that we need to buy before continuing...
        [self performSegueWithIdentifier: @"StorePushSegue" sender: sender];
        return;
    }
    
    ScoreSheet* sheet = [ScoreSheet currentScoreSheet];
    Question* question = [self.level nextQuestion];
    
    [sheet useJokerForQuestion: question];
    sender.enabled = NO;
    
    self.jokerLabel.text = [question rangeString];
    self.lifeCountView.count -= COST_OF_JOKER;
    
    [UIView animateWithDuration: 0.3
                     animations:^{
                         [self.jokerLabel layoutIfNeeded];
                     }];
    
    
    NSString* lang = [NSManagedObjectContextGetMain().locale objectForKey: NSLocaleLanguageCode];
    [[[GAI sharedInstance] defaultTracker] send: [[GAIDictionaryBuilder createEventWithCategory: lang
                                                                                         action: @"Joker"
                                                                                          label: [question.identifier stringValue]
                                                                                          value: nil] build]];
}

- (IBAction)okPushed:(UIButton *)sender {
    
    ScoreSheet* sheet = [ScoreSheet currentScoreSheet];
    Question* question = [self.level nextQuestion];
    
    NSUInteger tries = [sheet triesForQuestion: question];
    BOOL isFreeTry = NO;

    if( !isFreeTry ) {
        
        NSUInteger lives = [LifeBank count];
        
        if( lives == 1 && sender ) {
            NSString* title = NSLocalizedString(@"Danger!", @"");
            NSString* msg = NSLocalizedString(@"This is your last life! With zero lives you can not longer make guesses. Are you sure about this guess?", @"");
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                            message: msg
                                                           delegate: self
                                                  cancelButtonTitle: NSLocalizedString(@"Think again", @"")
                                                  otherButtonTitles: NSLocalizedString(@"It's right", @""), nil];
            alert.tag = kAlertViewLastLifeTag;
            [alert show];
            return;
        }
        
        //This needs lives if you make a mistake!!
        if( lives < COST_OF_BAD_RESPONSE ) {
            //Can not attempt -> show popup that we need to buy before continuing...
            [self performSegueWithIdentifier: @"StorePushSegue" sender: sender];
            return;
        }
    }
    
    NSUInteger answer = self.inputView.integerValue;
    
    NSComparisonResult result = [question.answer compare: @(answer)];
    
    switch (result) {
        case NSOrderedAscending:
        case NSOrderedDescending:
        {
            [sheet failedAtQuestion: question];
            
            if( !isFreeTry ) {
                [LifeBank subtractLives: COST_OF_BAD_RESPONSE];
                self.lifeCountView.count -= COST_OF_BAD_RESPONSE;
                
                if( ![[NSUserDefaults standardUserDefaults] boolForKey: NSUserDefaultsShownHelpExplanation] ) {
                    
                    NSString* title = NSLocalizedString(@"Ouch, that one hurt!", @"");
                    NSString* msg = NSLocalizedString(@"You lose one life per wrong guess. Can't find the answer? You can always ask your friends for help with the button in the top right!", @"");
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                                    message: msg
                                                                   delegate: self
                                                          cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                                          otherButtonTitles: NSLocalizedString(@"Get Help", @""), nil];
                    alert.tag = kAlertViewHelpExpTag;
                    [alert show];
                    
                    [[NSUserDefaults standardUserDefaults] setBool: YES forKey: NSUserDefaultsShownHelpExplanation];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                else if( ![[NSUserDefaults standardUserDefaults] boolForKey: NSUserDefaultsShownJokerExplanation] ) {
                    
                    NSString* title = NSLocalizedString(@"Not doing so well?", @"");
                    NSString* msg = NSLocalizedString(@"Try using the green Joker button to help yourself for a small life cost", @"");
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                                    message: msg
                                                                   delegate: self
                                                          cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                                          otherButtonTitles: nil];
                    [alert show];
                    
                    [[NSUserDefaults standardUserDefaults] setBool: YES forKey: NSUserDefaultsShownJokerExplanation];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            
            [self.guessView addGuess: @(answer) animated: YES];
            
            break;
        }
        case NSOrderedSame:
        {
            BOOL success = [sheet crossOfQuestion: question];
            NSParameterAssert(success);
            
            [self animateMessage: NSLocalizedString(@"Correct\nAnswer!", @"") completion: ^(BOOL finished) {
                [self advance];
            }];

            break;
        }
    }
    
    self.inputView.text = @"";
}

- (IBAction)helpPushed:(id)sender {
    
    Question* question = [self.level nextQuestion];
    NSString* format = NSLocalizedString(@"%@. Anyone know the answer?", @"Twitter");
    NSString* msg = [NSString localizedStringWithFormat: format, question.text];
    
    UIActivityViewController* activityVC = [[UIActivityViewController alloc] initWithActivityItems: @[msg]
                                                                             applicationActivities: nil];
    [activityVC setCompletionHandler: ^(NSString *activityType, BOOL completed) {
        [self dismissViewControllerAnimated: YES completion: nil];
    }];
    [self presentViewController: activityVC animated: YES completion: nil];
}

- (IBAction) unwindToGame:(UIStoryboardSegue*)sender {
    
}

#pragma mark - NSObject
+ (void) initialize {
    NSDictionary* params = @{ NSUserDefaultsShownHelpExplanation : @NO };
    [[NSUserDefaults standardUserDefaults] registerDefaults: params];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if( self ) {
        self.screenName = @"Game";
        
        if( [ContentLock tryLock] ) {
            GADRequest* request = [GADRequest request];
            request.testDevices = @[ GAD_SIMULATOR_ID,
                                     @"5847239deac1f26ea408b154815af621"            //Paul iPhone4
                                     ];
            
            _interstitial = [[GADInterstitial alloc] init];
            _interstitial.adUnitID = @"ca-app-pub-1332160865070772/1859473640";
            _interstitial.delegate = self;
            [_interstitial loadRequest:[GADRequest request]];
        }
    }
    return self;
}

- (void) dealloc {
    _interstitial.delegate = nil;
}

#pragma mark - UIViewController
- (void) viewDidLoad {
    [super viewDidLoad];
    
    NSParameterAssert(self.level);
    
    UIImage* template = [self.backgroundImageView.image imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
    self.backgroundImageView.image = template;
    
    Question* question = [self.level nextQuestion];
    [self updateWithQuestion: question animated: NO];
    
    LifeCountView* countView = [[LifeCountView alloc] initWithFrame: CGRectMake(0, 0, 40, 40)];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView: countView];
    self.navigationItem.rightBarButtonItems = @[self.navigationItem.rightBarButtonItem, item];
    self.lifeCountView = countView;
    
    for(UIView* v in self.numberButtons) {
        v.layer.cornerRadius = 5.;
    }
    
    self.jokerButton.layer.cornerRadius = 5.;
    self.okButton.layer.cornerRadius = 5.;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden: NO animated: YES];
    
    self.lifeCountView.count = [LifeBank count];
    
    [self.inputView becomeFirstResponder];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [self.inputView becomeFirstResponder];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.inputView becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate

#pragma mark - UINumberFieldDelegate
- (void) numberField:(UINumberField *)numberField didChangeToValue:(NSInteger)integerValue {
    self.okButton.enabled = integerValue > 0;
}

#pragma mark - UIAlertViewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case kAlertViewLastLifeTag:
        {
            if( buttonIndex != alertView.cancelButtonIndex ) {
                [self okPushed: nil];
            }
            break;
        }
        case kAlertViewHelpExpTag:
        {
            if( buttonIndex != alertView.cancelButtonIndex ) {
                [self helpPushed: self.navigationItem.rightBarButtonItem];
            }
            
            break;
        }
        case kAlertViewCorrectTag:
        {
            if( buttonIndex == alertView.cancelButtonIndex ) {
                [self advance];
            }
            else {
                NSString* title = NSLocalizedString(@"Share this answer on:", @"");
                UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle: title
                                                                   delegate: self
                                                          cancelButtonTitle: NSLocalizedString(@"Cancel", @"")
                                                     destructiveButtonTitle: nil
                                                          otherButtonTitles: NSLocalizedString(@"Facebook", @""), NSLocalizedString(@"Twitter", @""), nil];
                sheet.tag = kAlertViewBragTag;
                [sheet showFromBarButtonItem: self.navigationItem.rightBarButtonItem animated: YES];
            }
            break;
        }
        case kAlertViewEndGameTag:
        {
            if( buttonIndex == alertView.cancelButtonIndex ) {
                [self.navigationController popToRootViewControllerAnimated: YES];
            }
            else {
                [self followUsOn: SLServiceTypeTwitter completion: ^(NSError *error) {
                    [self.navigationController popToRootViewControllerAnimated: YES];
                }];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - GADInterstitialDelegate
- (void) interstitialDidDismissScreen:(GADInterstitial *)ad {
    if( [ad hasBeenUsed] && [ContentLock tryLock] ) {
        //Get another one:
        GADRequest* request = [GADRequest request];
        request.testDevices = @[ GAD_SIMULATOR_ID,
                                 @"5847239deac1f26ea408b154815af621"            //Paul iPhone4
                                 ];
        
        _interstitial = [[GADInterstitial alloc] init];
        _interstitial.adUnitID = @"ca-app-pub-1332160865070772/1859473640";
        _interstitial.delegate = self;
        [_interstitial loadRequest:[GADRequest request]];
    }
}

- (void) interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    DLogError(error);
}

@end

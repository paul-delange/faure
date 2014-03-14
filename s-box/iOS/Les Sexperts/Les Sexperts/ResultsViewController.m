//
//  ResultsViewController.m
//  Les Sexperts
//
//  Created by Paul de Lange on 4/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "ResultsViewController.h"
#import "QuestionViewController.h"
#import "ResumeViewController.h"
#import "MZFormSheetController.h"

#import "ContentLock.h"
#import "Question.h"
#import "Answer.h"

#import "ResultCollectionViewCell.h"

#import "ResultsCollectionViewFlowLayout.h"

@interface ResultsViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource> {
    NSInteger       _currentAnimatedCell;
}

@end

@implementation ResultsViewController

- (NSUInteger) totalCorrect {
    NSArray* correct = [self.answersArray filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"isCorrect = YES"]];
    return [correct count];
}

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	NSParameterAssert(self.answersArray);
    
    self.title = NSLocalizedString(@"Results", @"");
    
    NSString* format = NSLocalizedString(@"Total %@", @"");
    self.totalScoreLabel.text = [NSString stringWithFormat: format, @([self totalCorrect])];
    
    
    self.continueButton.enabled = NO;
    self.collectionView.scrollEnabled = NO;
    [self.continueButton setTitle: NSLocalizedString(@"Continue", @"") forState: UIControlStateNormal];
    
    [self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    dispatch_source_t sourceTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(sourceTimer, dispatch_time(DISPATCH_TIME_NOW, 0), 1 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(sourceTimer, ^{
        
        if( _currentAnimatedCell < [self collectionView: nil numberOfItemsInSection: 0] ) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow: _currentAnimatedCell inSection: 0];
            ResultsCollectionViewFlowLayout* layout = (ResultsCollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
            
            [layout setPosition: kResultCollectionViewCellPositionCenter atIndexPath: indexPath animated: YES];
            
            [self.collectionView scrollToItemAtIndexPath: indexPath atScrollPosition: UICollectionViewScrollPositionCenteredVertically animated: YES];
            
            _currentAnimatedCell++;
        }
        else {
            self.continueButton.enabled = YES;
            self.tableView.scrollEnabled = YES;
            dispatch_source_cancel(sourceTimer);
            
            NSUInteger score = [self totalCorrect];
            BOOL needsResume = ![ResumeViewController hasDisplayedForScore: score];
            
            if( needsResume ) {
                ResumeViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier: @"ResumeViewController"];
                vc.score = score;
                
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
        }
    });
    
    dispatch_resume(sourceTimer);
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if( [identifier isEqualToString: @"QuestionPushSegue"] ) {
        return [ContentLock tryLock];
    }
    
    return YES;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString: @"QuestionPushSegue"] ) {
        UITableViewCell* cell = (UITableViewCell*)sender;
        NSIndexPath* path = [self.tableView indexPathForCell: cell];
        Question* question = self.questionsArray[path.row];
        
        QuestionViewController* vc = segue.destinationViewController;
        vc.question = question;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.answersArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ResultCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"ResultsCellIdentifier" forIndexPath: indexPath];
    
    Question* question = self.questionsArray[indexPath.row];
    cell.textLabel.text = question.text;
    cell.textLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleHeadline];
    cell.detailTextLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleSubheadline];
    
    Answer* answer = self.answersArray[indexPath.row];
    
    if( answer.isCorrectValue ) {
        cell.detailTextLabel.text = answer.text;
        cell.detailTextLabel.textColor = [UIColor greenColor];
    }
    else {
        Answer* correctAnswer = [question correctAnswer];
        NSString* string = [NSString stringWithFormat: @"%@\n%@", answer.text, correctAnswer.text];
        NSMutableAttributedString* detailString = [[NSMutableAttributedString alloc] initWithString: string];
        
        NSRange correctRange = [string rangeOfString: correctAnswer.text];
        NSRange wrongRange = [string rangeOfString: answer.text];
        
        NSDictionary* correctAttributes = @{ NSForegroundColorAttributeName : [UIColor greenColor]};
        NSDictionary* wrongAttributes = @{ NSForegroundColorAttributeName : [UIColor redColor] };
        
        [detailString addAttributes: correctAttributes range: correctRange];
        [detailString addAttributes: wrongAttributes range: wrongRange];
        
        cell.detailTextLabel.attributedText = detailString;
    }
    
    
    return cell;
}

#pragma mark - UICollectionViewFlowLayoutDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    Question* question = self.questionsArray[indexPath.row];
    Answer* answer = self.answersArray[indexPath.row];
    Answer* correctAnswer = [question correctAnswer];
    
    NSDictionary* questionAttributes = @{ NSFontAttributeName : [UIFont preferredFontForTextStyle: UIFontTextStyleHeadline] };
    NSDictionary* answerAttribute = @{ NSFontAttributeName : [UIFont preferredFontForTextStyle: UIFontTextStyleSubheadline] };
    
    CGRect questionSize = [question.text boundingRectWithSize: CGSizeMake(CGRectGetWidth(collectionView.bounds),  MAXFLOAT)
                                                      options: NSStringDrawingUsesLineFragmentOrigin
                                                   attributes: questionAttributes
                                                      context: nil];
    
    CGRect answerSize = [answer.text boundingRectWithSize: CGSizeMake(CGRectGetWidth(collectionView.bounds),  MAXFLOAT)
                                                  options: NSStringDrawingUsesLineFragmentOrigin
                                               attributes: answerAttribute
                                                  context: nil];
    
    CGRect correctAnswerSize = [correctAnswer.text boundingRectWithSize: CGSizeMake(CGRectGetWidth(collectionView.bounds),  MAXFLOAT)
                                                                options: NSStringDrawingUsesLineFragmentOrigin
                                                             attributes: answerAttribute
                                                                context: nil];
    
    CGFloat height = CGRectGetHeight(questionSize) + CGRectGetHeight(answerSize);
    
    if( !answer.isCorrectValue )
        height += CGRectGetHeight(correctAnswerSize);
    
    height += (4 * 8 );
    
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), height);
}

@end

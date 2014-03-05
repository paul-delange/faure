//
//  ResultsViewController.m
//  Les Sexperts
//
//  Created by Paul de Lange on 4/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "ResultsViewController.h"

#import "Question.h"
#import "Answer.h"

@interface ResultsViewController () <UITableViewDataSource, UITableViewDelegate>

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
    
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.answersArray.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                                   reuseIdentifier: nil];
    
    Question* question = self.questionsArray[indexPath.row];
    cell.textLabel.text = question.text;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleHeadline];
    cell.detailTextLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleSubheadline];
    
    cell.detailTextLabel.numberOfLines = 0;
    
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

#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Question* question = self.questionsArray[indexPath.row];
    Answer* answer = self.answersArray[indexPath.row];
    Answer* correctAnswer = [question correctAnswer];
    
    NSDictionary* questionAttributes = @{ NSFontAttributeName : [UIFont preferredFontForTextStyle: UIFontTextStyleHeadline] };
    NSDictionary* answerAttribute = @{ NSFontAttributeName : [UIFont preferredFontForTextStyle: UIFontTextStyleSubheadline] };
    
    CGRect questionSize = [question.text boundingRectWithSize: CGSizeMake(CGRectGetWidth(tableView.bounds),  MAXFLOAT)
                                                      options: NSStringDrawingUsesLineFragmentOrigin
                                                   attributes: questionAttributes
                                                      context: nil];
    
    CGRect answerSize = [answer.text boundingRectWithSize: CGSizeMake(CGRectGetWidth(tableView.bounds),  MAXFLOAT)
                                                  options: NSStringDrawingUsesLineFragmentOrigin
                                               attributes: answerAttribute
                                                  context: nil];
    
    CGRect correctAnswerSize = [correctAnswer.text boundingRectWithSize: CGSizeMake(CGRectGetWidth(tableView.bounds),  MAXFLOAT)
                                                                options: NSStringDrawingUsesLineFragmentOrigin
                                                             attributes: answerAttribute
                                                                context: nil];
    
    CGFloat height = CGRectGetHeight(questionSize) + CGRectGetHeight(answerSize);
    
    if( !answer.isCorrectValue )
        height += CGRectGetHeight(correctAnswerSize);
    
    height += (4 * 8 );
    
    return height;
}

@end

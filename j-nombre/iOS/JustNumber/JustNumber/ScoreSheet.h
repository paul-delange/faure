#import "_ScoreSheet.h"

@class Question;

@interface ScoreSheet : _ScoreSheet {}

+ (instancetype) currentScoreSheet;

- (NSSet*) completedQuestionIdentifiers;

- (BOOL) crossOfQuestion: (Question*) question;
- (BOOL) failedAtQuestion: (Question*) question;

- (NSUInteger) triesForQuestion: (Question*) question;

@end

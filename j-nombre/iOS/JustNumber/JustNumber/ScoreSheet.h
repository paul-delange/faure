#import "_ScoreSheet.h"

@class Question;

@interface ScoreSheet : _ScoreSheet {}

+ (instancetype) currentScoreSheet;

- (NSSet*) completedQuestionIdentifiers;

- (BOOL) crossOfQuestion: (Question*) question;
- (BOOL) failedAtQuestion: (Question*) question;

- (NSUInteger) triesForQuestion: (Question*) question;

- (void) useJokerForQuestion: (Question*) question;
- (BOOL) jokerUsedForQuestion: (Question*) question;

@end

#import "_ScoreSheet.h"

@class Question;

@interface ScoreSheet : _ScoreSheet {}

+ (instancetype) currentScoreSheet;

- (NSSet*) completedQuestionIdentifiers;
- (BOOL) crossOfQuestion: (Question*) question;

@end

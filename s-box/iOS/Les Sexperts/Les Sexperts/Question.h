#import "_Question.h"

@interface Question : _Question {}
// Custom logic goes here.



+ (instancetype) leastUsedQuestion;

+ (void) resetHistoryAndShuffle;

- (Answer*) correctAnswer;

@end

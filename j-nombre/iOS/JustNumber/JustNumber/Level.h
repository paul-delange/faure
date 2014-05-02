#import "_Level.h"

@interface Level : _Level {}
// Custom logic goes here.

+ (instancetype) currentLevel;

- (instancetype) nextLevel;
- (Question*) nextQuestion;

@end

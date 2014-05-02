#import "_Score.h"

@class Question;

@interface Score : _Score {}
// Custom logic goes here.

+ (instancetype) scoreForQuestion: (Question*) question;

@end

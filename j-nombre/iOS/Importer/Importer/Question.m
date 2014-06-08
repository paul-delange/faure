#import "Question.h"


@interface Question ()

// Private interface goes here.

@end


@implementation Question

- (void) willSave {
    [super willSave];

    NSAssert([self.answer integerValue] <= [self.maxValue integerValue], @"Question %@ has an answer more than it's max", self.text);
    NSAssert([self.answer integerValue] >= [self.minValue integerValue], @"Question %@ has an answer less than it's min", self.text);
}

@end

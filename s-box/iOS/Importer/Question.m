#import "Question.h"


@interface Question ()

// Private interface goes here.

@end


@implementation Question

// Custom logic goes here.
- (void) awakeFromInsert {
    self.lastDisplayedTime = [NSDate date];
}

@end

#import "Question.h"


@interface Question ()

// Private interface goes here.

@end


@implementation Question

// Custom logic goes here.
- (NSString*) formattedAnswerString {
    if( self.formatsValue ) {
        NSLocale* locale = [NSLocale currentLocale];
        NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numberFormatter setGeneratesDecimalNumbers: YES];
        [numberFormatter setLocale: locale];
        
        return [numberFormatter stringFromNumber: self.answer];
    }
    else {
        return [self.answer stringValue];
    }
}

@end

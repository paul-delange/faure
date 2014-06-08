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
        [numberFormatter setGeneratesDecimalNumbers: NO];
        [numberFormatter setLocale: locale];
        
        return [numberFormatter stringFromNumber: self.answer];
    }
    else {
        return [self.answer stringValue];
    }
}

- (NSString*) rangeString {
    NSString* minValue = [self.minValue stringValue];
    NSString* maxValue = [self.maxValue stringValue];
    
    if( self.formatsValue ) {
        NSLocale* locale = [NSLocale currentLocale];
        NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numberFormatter setGeneratesDecimalNumbers: NO];
        [numberFormatter setLocale: locale];
        
        minValue = [numberFormatter stringFromNumber: self.minValue];
        maxValue = [numberFormatter stringFromNumber: self.maxValue];
    }
    
    return [NSString localizedStringWithFormat: NSLocalizedString(@"The answer is between %@ and %@", @""), minValue, maxValue];
}

@end

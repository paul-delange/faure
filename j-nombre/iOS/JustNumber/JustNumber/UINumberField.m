//
//  UINumberField.m
//  JustNumber
//
//  Created by Paul de Lange on 27/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "UINumberField.h"

#import <objc/runtime.h>

@interface UINumberField ()

@property (strong) NSNumberFormatter* numberFormatter;

@end

@implementation UINumberField

- (NSInteger) integerValue {
    NSCharacterSet* nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString *numberString = [[self.text componentsSeparatedByCharactersInSet: nonNumberSet] componentsJoinedByString:@""];
    return [numberString integerValue];
}

- (NSString*) formattedTextFromString: (NSString*) string {
    NSCharacterSet* nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString *numberString = [[string componentsSeparatedByCharactersInSet: nonNumberSet] componentsJoinedByString:@""];
    NSNumber* number = [self.numberFormatter numberFromString: numberString];
    return [self.numberFormatter stringFromNumber: number];
}

- (void) textDidChange: (NSNotification*) notification {
    NSString* formatted = [self formattedTextFromString: self.text];
    [super setText: formatted];
    
    id<UINumberFieldDelegate> del = (id<UINumberFieldDelegate>)self.delegate;
    if( [del respondsToSelector: @selector(numberField:didChangeToValue:)] )
        [del numberField: self didChangeToValue: [self integerValue]];
}

- (void) commonInit {
    NSLocale* locale = [NSLocale currentLocale];
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setGeneratesDecimalNumbers: YES];
    [numberFormatter setLocale: locale];
    
    self.numberFormatter = numberFormatter;
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(textDidChange:) name: UITextFieldTextDidChangeNotification object: nil];
}

#pragma mark - NSObject
- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if( self ) {
        [self commonInit];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark - UIView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

#pragma mark - UITextField
- (void) setText:(NSString *)text {
    NSString* formatted = [self formattedTextFromString: text];
    [super setText: formatted];
    
    id<UINumberFieldDelegate> del = (id<UINumberFieldDelegate>)self.delegate;
    if( [del respondsToSelector: @selector(numberField:didChangeToValue:)] )
        [del numberField: self didChangeToValue: [self integerValue]];
}

@end

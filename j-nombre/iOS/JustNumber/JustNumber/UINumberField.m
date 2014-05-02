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
@property (weak) UILabel* unitLabel;
@property (weak) UIButton* clearButton;

@end

@implementation UINumberField

- (void) setUnitString:(NSString *)unitString {
    _unitString = unitString;
    self.unitLabel.text = unitString;
    
    [self setNeedsLayout];
}

- (void) setAutomaticallyFormatsInput:(BOOL)automaticallyFormatsInput {
    _automaticallyFormatsInput = automaticallyFormatsInput;
    self.text = self.text;
}

- (NSInteger) integerValue {
    NSCharacterSet* nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString *numberString = [[self.text componentsSeparatedByCharactersInSet: nonNumberSet] componentsJoinedByString:@""];
    return [numberString integerValue];
}

- (void) appendInteger: (NSInteger) integer {
    self.text = [self.text stringByAppendingFormat: @"%d", (int)integer];
}

- (NSString*) formattedTextFromString: (NSString*) string {
    if( self.automaticallyFormatsInput ) {
        NSCharacterSet* nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        NSString *numberString = [[string componentsSeparatedByCharactersInSet: nonNumberSet] componentsJoinedByString:@""];
        NSNumber* number = [self.numberFormatter numberFromString: numberString];
        return [self.numberFormatter stringFromNumber: number];
    }
    else {
        return string;
    }
}

- (void) textDidChange: (NSNotification*) notification {
    NSString* formatted = [self formattedTextFromString: self.text];
    [super setText: formatted];
    
    id<UINumberFieldDelegate> del = (id<UINumberFieldDelegate>)self.delegate;
    if( [del respondsToSelector: @selector(numberField:didChangeToValue:)] )
        [del numberField: self didChangeToValue: [self integerValue]];
}

- (void) clearPushed: (UIButton*) sender {
    self.text = @"";
}

- (void) commonInit {
    self.automaticallyFormatsInput = YES;
    
    NSLocale* locale = [NSLocale currentLocale];
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setGeneratesDecimalNumbers: YES];
    [numberFormatter setLocale: locale];
    
    self.numberFormatter = numberFormatter;
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(textDidChange:) name: UITextFieldTextDidChangeNotification object: nil];
    
    UIView* dummy = [[UIView alloc] initWithFrame: CGRectZero];
    self.inputView = dummy;
    
    UILabel* unitLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 0, 32)];
    unitLabel.backgroundColor = [UIColor clearColor];
    unitLabel.text = @"";
    unitLabel.textAlignment = NSTextAlignmentRight;
    unitLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleFootnote];
    unitLabel.textColor = [UIColor lightGrayColor];
    
    UIButton* clearButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [clearButton setTitle: @"X" forState: UIControlStateNormal];
    clearButton.frame = CGRectMake(100, 0, 32, 32);
    [clearButton addTarget: self action: @selector(clearPushed:) forControlEvents: UIControlEventTouchUpInside];
    
    UIView* right = [[UIView alloc] initWithFrame: CGRectZero];
    right.backgroundColor = [UIColor clearColor];
    
    [right addSubview: unitLabel];
    [right addSubview: clearButton];
    self.unitLabel = unitLabel;
    self.clearButton = clearButton;
    
    self.rightView = right;
    self.rightViewMode = UITextFieldViewModeAlways;
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

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGSize clearSize = [self.clearButton intrinsicContentSize];
    CGSize unitSize = [self.unitLabel intrinsicContentSize];
    
    CGSize selfSize = self.frame.size;
    
    self.unitLabel.frame = CGRectMake(0, (selfSize.height-unitSize.height)/2., unitSize.width, unitSize.height);
    self.clearButton.frame = CGRectMake(CGRectGetMaxX(self.unitLabel.frame), (selfSize.height-clearSize.height)/2., clearSize.width, clearSize.height);
}

#pragma mark - UITextField
- (void) setText:(NSString *)text {
    NSString* formatted = [self formattedTextFromString: text];
    [super setText: formatted];
    
    id<UINumberFieldDelegate> del = (id<UINumberFieldDelegate>)self.delegate;
    if( [del respondsToSelector: @selector(numberField:didChangeToValue:)] )
        [del numberField: self didChangeToValue: [self integerValue]];
}

- (CGRect) rightViewRectForBounds:(CGRect)bounds {
    CGSize clearSize = [self.clearButton intrinsicContentSize];
    CGSize unitSize = [self.unitLabel intrinsicContentSize];

    return CGRectMake(CGRectGetWidth(bounds) - clearSize.width - unitSize.width, 0, clearSize.width + unitSize.width, CGRectGetHeight(bounds));
}

@end

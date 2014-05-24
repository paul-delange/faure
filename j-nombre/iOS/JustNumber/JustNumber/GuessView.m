//
//  GuessView.m
//  JustNumber
//
//  Created by Paul de Lange on 6/05/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "GuessView.h"

@interface GuessView () {
    NSMutableArray* _guesses;
}

@property (strong) NSNumberFormatter* numberFormatter;

- (void) reloadData;

@end

@implementation GuessView

- (void) setActualValue:(NSNumber *)actualValue {
    _actualValue = actualValue;
    
    [_guesses removeAllObjects];
    [self reloadData];
}

- (void) addGuess:(NSNumber *)guessValue animated:(BOOL)animated {
    NSParameterAssert(self.actualValue);
    [_guesses addObject: guessValue];
    
    UILabel* guessLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    guessLabel.font = [UIFont systemFontOfSize: 15];
    guessLabel.textAlignment = NSTextAlignmentCenter;
    guessLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    guessLabel.translatesAutoresizingMaskIntoConstraints = NO;
    guessLabel.textColor = [UIColor whiteColor];
    guessLabel.shadowColor = self.tintColor;
    guessLabel.shadowOffset = CGSizeMake(1, 1);
    
    NSString* formattedNumber = self.automaticallyFormatsInput ?
    [self.numberFormatter stringFromNumber: guessValue] :
    [guessValue stringValue];
    
    switch ([guessValue compare: self.actualValue]) {
        case NSOrderedAscending:
        {
            if( [self.unitString length] )
                guessLabel.text = [NSString localizedStringWithFormat: NSLocalizedString(@"It's more than %@ %@", @""), formattedNumber, self.unitString];
            else
                guessLabel.text = [NSString localizedStringWithFormat: NSLocalizedString(@"It's more than %@", @""), formattedNumber];
            break;
        }
        case NSOrderedDescending:
        {
            if( [self.unitString length] )
                guessLabel.text = [NSString localizedStringWithFormat: NSLocalizedString(@"It's less than %@ %@", @""), formattedNumber, self.unitString];
            else
                guessLabel.text = [NSString localizedStringWithFormat: NSLocalizedString(@"It's less than %@", @""), formattedNumber];
            break;
        }
        default:
            break;
    }
    
    CGSize guessSize = [guessLabel intrinsicContentSize];
    guessLabel.frame = CGRectMake((CGRectGetWidth(self.bounds)-guessSize.width)/2.,
                                  CGRectGetHeight(self.bounds),
                                  guessSize.width,
                                  32);
    
    [self addSubview: guessLabel];
    
    [self removeConstraints: self.constraints];
    
    __block UIView* lastGuessView = nil;
    NSUInteger totalGuesses = [_guesses count];
    
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UILabel* guessView = obj;
        
        [self addConstraint: [NSLayoutConstraint constraintWithItem: guessView
                                                          attribute: NSLayoutAttributeCenterX
                                                          relatedBy: NSLayoutRelationEqual
                                                             toItem: self
                                                          attribute: NSLayoutAttributeCenterX
                                                         multiplier: 1.0
                                                           constant: 0.0]];
        
        if( lastGuessView ) {
            [self addConstraint: [NSLayoutConstraint constraintWithItem: guessView
                                                              attribute: NSLayoutAttributeTop
                                                              relatedBy: NSLayoutRelationEqual
                                                                 toItem: lastGuessView
                                                              attribute: NSLayoutAttributeBottom
                                                             multiplier: 1.0
                                                               constant: 0.0]];
        }
        
        lastGuessView = guessView;
        
        NSUInteger i = totalGuesses - idx;
        CGFloat scale = 1. - .1*i;
        
        guessView.transform = CGAffineTransformMakeScale(scale, scale);
        guessView.textColor = [UIColor colorWithWhite: 1 alpha: 1. - 0.25*i];
    }];
    
    NSLayoutConstraint* finalConstant = [NSLayoutConstraint constraintWithItem: lastGuessView
                                                                     attribute: NSLayoutAttributeBottom
                                                                     relatedBy: NSLayoutRelationEqual
                                                                        toItem: self
                                                                     attribute: NSLayoutAttributeBottom
                                                                    multiplier: 1.0
                                                                      constant: -32.];
    [self addConstraint: finalConstant];
    
    [UIView animateWithDuration: animated * 0.3
                          delay: 0.0
                        options: 0
                     animations: ^{
                         finalConstant.constant = 0.;
                         [self layoutIfNeeded];
                     }
                     completion: NULL];
    
}

- (void) reloadData {
    [self.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    for(NSNumber* guess in _guesses) {
        [self addGuess: guess animated: NO];
    }
}

- (void) commonInit {
    _actualValue = @(0);
    _guesses = [NSMutableArray new];
    _automaticallyFormatsInput = YES;
    
    NSLocale* locale = [NSLocale currentLocale];
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setGeneratesDecimalNumbers: YES];
    [numberFormatter setLocale: locale];
    
    self.numberFormatter = numberFormatter;
    self.clipsToBounds = YES;
}

#pragma mark - NSObject
- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if( self ) {
        [self commonInit];
    }
    return self;
}

#pragma mark - UIView
- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if( self )
    {
        [self commonInit];
    }
    return self;
}

@end

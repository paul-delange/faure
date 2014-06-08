//
//  JokerButton.m
//  JustNumber
//
//  Created by Paul de Lange on 8/06/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "JokerButton.h"

#import "LifeBank.h"

@interface JokerButton ()

@property (weak, nonatomic) UILabel* costLabel;

@end

@implementation JokerButton

#pragma mark - NSObject
- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if( self ) {
        UILabel* clabel = [[UILabel alloc] initWithFrame: CGRectZero];
        clabel.translatesAutoresizingMaskIntoConstraints = NO;
        clabel.text = [NSString stringWithFormat: @" %@ ", [NSString localizedStringWithFormat: NSLocalizedString(@"-%d", @""), COST_OF_JOKER]];
        clabel.textColor = [UIColor whiteColor];
        clabel.backgroundColor = [UIColor redColor];
        clabel.font = [UIFont systemFontOfSize: 10];
        clabel.clipsToBounds = YES;
        
        clabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview: clabel];
        
        [self addConstraint: [NSLayoutConstraint constraintWithItem: clabel
                                                          attribute: NSLayoutAttributeCenterY
                                                          relatedBy: NSLayoutRelationEqual
                                                             toItem: self
                                                          attribute: NSLayoutAttributeTop
                                                         multiplier: 1.0
                                                           constant: 0.0]];
        [self addConstraint: [NSLayoutConstraint constraintWithItem: clabel
                                                          attribute: NSLayoutAttributeCenterX
                                                          relatedBy: NSLayoutRelationEqual
                                                             toItem: self
                                                          attribute: NSLayoutAttributeRight
                                                         multiplier: 1.0
                                                           constant: 0.0]];
        [self addConstraint: [NSLayoutConstraint constraintWithItem: clabel
                                                          attribute: NSLayoutAttributeHeight
                                                          relatedBy: NSLayoutRelationEqual
                                                             toItem: clabel
                                                          attribute: NSLayoutAttributeWidth
                                                         multiplier: 1.0
                                                           constant: 0.0]];
        
        self.costLabel = clabel;
        
    }
    return self;
}

#pragma mark - UIControl
- (void) setEnabled:(BOOL)enabled {
    [super setEnabled: enabled];
    
    self.alpha = enabled ? 1. : 0.5;
}

#pragma mark - UIView
- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.costLabel.layer.cornerRadius = CGRectGetWidth(self.costLabel.frame)/2.;
}

@end

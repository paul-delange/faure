//
//  TimerView.m
//  Les Sexperts
//
//  Created by Paul de Lange on 30/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "TimerView.h"

#define START_COLOR     [UIColor colorWithRed: 41/255. green: 74/255. blue: 124/255. alpha: 1.]

@implementation TimerView

- (void) setTimeRemaining:(NSTimeInterval)timeRemaining {
    _timeRemaining = timeRemaining;
    
    CGFloat percent = 1 - _timeRemaining / self.totalTime;
    
    CGFloat sr, sg, sb;
    [START_COLOR getRed: &sr green: &sg blue: &sb alpha: NULL];
    
    CGFloat fr = 1., fg = 0., fb = 0.;
    
    self.tintColor = [UIColor colorWithRed: (fr-sr) * percent + sr
                                     green: (fg-sg) * percent + sg
                                      blue: (fb-sb) * percent + sb
                                     alpha: 1.];
    
    [self setNeedsDisplay];
}

#pragma mark - NSObject 
- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if( self ) {
        self.tintColor = START_COLOR;
    }
    return self;
}

#pragma mark - UIView
- (void) drawRect:(CGRect)rect {
    [super drawRect: rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect remainingRect = rect;
    remainingRect.size.width *= ( self.timeRemaining / self.totalTime );
    
    CGContextSetFillColorWithColor(ctx, [self.tintColor CGColor]);
    CGContextFillRect(ctx, remainingRect);
}

- (CGSize) intrinsicContentSize {
    return CGSizeMake(CGRectGetWidth(self.superview.frame), 24.);
}

@end

//
//  ResultCollectionViewCell.m
//  Les Sexperts
//
//  Created by Paul de Lange on 6/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "ResultCollectionViewCell.h"

@implementation ResultCollectionViewCell

- (void) setIsCorrect:(BOOL)isCorrect {
    _isCorrect = isCorrect;
    
    [self setNeedsDisplay];
}

#pragma mark - UIView
- (void) drawRect:(CGRect)rect {
    
    CGRect titleRect = self.textLabel.frame;
    CGRect answerRect = self.detailTextLabel.frame;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(ctx, [[[UIColor darkTextColor] colorWithAlphaComponent: 0.5] CGColor]);
    CGContextFillRect(ctx, CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(titleRect)));
    
    CGContextSetFillColorWithColor(ctx, [[self.isCorrect ? [UIColor greenColor] : [UIColor redColor] colorWithAlphaComponent: 0.25] CGColor]);
    CGContextFillRect(ctx, CGRectMake(0, CGRectGetMinY(answerRect), CGRectGetWidth(self.frame), CGRectGetHeight(answerRect)));
    
    
    [super drawRect: rect];
}

@end

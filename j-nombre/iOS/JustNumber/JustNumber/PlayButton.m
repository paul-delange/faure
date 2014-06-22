//
//  PlayButton.m
//  JustNumber
//
//  Created by Paul de Lange on 22/06/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "PlayButton.h"

@implementation PlayButton

#pragma mark - UIButton
- (CGRect) imageRectForContentRect:(CGRect)contentRect {
    CGRect frame = [super imageRectForContentRect: contentRect];
    frame.origin.x = CGRectGetMaxX(contentRect) - CGRectGetWidth(frame) - self.imageEdgeInsets.right - self.imageEdgeInsets.left;
    return frame;
}

- (CGRect) titleRectForContentRect:(CGRect)contentRect {
    CGRect frame = [super titleRectForContentRect: contentRect];
    frame.origin.x = CGRectGetMinX(frame) - CGRectGetWidth([self imageRectForContentRect: contentRect]);
    return frame;
}

@end

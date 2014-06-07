//
//  LifeCountView.m
//  JustNumber
//
//  Created by Paul de Lange on 2/05/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "LifeCountView.h"

#import "LifeBank.h"
#import "ContentLock.h"

@interface LifeCountView () {
    NSUInteger _count;
}

@property (weak) IBOutlet UIImageView* imageView;
@property (weak) IBOutlet UILabel* textLabel;

@end

@implementation LifeCountView

- (NSInteger) count {
    return _count;
}

- (void) setCount:(NSInteger)count {
    
    if( count < self.count ) {
        /*CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI_4 ];
        rotationAnimation.duration = 0.15;
        rotationAnimation.autoreverses = YES;
        rotationAnimation.cumulative = YES;
        
        [self.imageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        */
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        anim.fromValue = [NSNumber numberWithFloat:0.0];
        anim.toValue = [NSNumber numberWithFloat:1.0];
        anim.duration = 0.15;
        anim.autoreverses = YES;
        [self.layer addAnimation:anim forKey:@"shadowOpacity"];
        self.layer.shadowOpacity = 0.0;
        
        CABasicAnimation *anim2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        anim2.fromValue = [NSNumber numberWithFloat:1.0];
        anim2.toValue = [NSNumber numberWithFloat:1.5];
        anim2.duration = 0.15;
        anim2.autoreverses = YES;
        [self.layer addAnimation:anim2 forKey:@"transformScale"];
    }
    else if( count > self.count ) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        anim.fromValue = [NSNumber numberWithFloat:1.0];
        anim.toValue = [NSNumber numberWithFloat:1.5];
        anim.duration = 0.15;
        anim.autoreverses = YES;
        [self.layer addAnimation:anim forKey:@"transformScale"];
        
        CABasicAnimation *anim2 = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        anim2.fromValue = [NSNumber numberWithFloat:0.0];
        anim2.toValue = [NSNumber numberWithFloat:1.0];
        anim2.duration = 0.3;
        anim2.autoreverses = YES;
        [self.layer addAnimation:anim2 forKey:@"shadowOpacity"];
    }
    
    _count = count;
    self.textLabel.text = [@(count) stringValue];
}

- (void) commonInit {
    _count = [LifeBank count];
    
    UIImage* lifeImage = [UIImage imageNamed: @"lives"];
    
    UIImageView* imageView =[[UIImageView alloc] initWithImage: [lifeImage imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate]];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UILabel* label = [[UILabel alloc] initWithFrame: CGRectZero];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = [@(_count) stringValue];
 
    
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont preferredFontForTextStyle: UIFontTextStyleFootnote];
    
    [self addSubview: imageView];
    [self addSubview: label];
    
    self.imageView = imageView;
    self.textLabel = label;
    
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[imageView][label]|"
                                                                  options: 0
                                                                  metrics: nil
                                                                    views: NSDictionaryOfVariableBindings(imageView, label)]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem: imageView
                                                      attribute: NSLayoutAttributeCenterX
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeCenterX
                                                     multiplier: 1.0
                                                       constant: 0.0]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem: label
                                                      attribute: NSLayoutAttributeWidth
                                                      relatedBy: NSLayoutRelationGreaterThanOrEqual
                                                         toItem: imageView
                                                      attribute: NSLayoutAttributeWidth
                                                     multiplier: 1.0
                                                       constant: 0.0]];
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[label]|"
                                                                  options: 0
                                                                  metrics: nil
                                                                    views: NSDictionaryOfVariableBindings(label)]];
    
    [self setContentHuggingPriority: UILayoutPriorityRequired forAxis: UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority: UILayoutPriorityRequired forAxis: UILayoutConstraintAxisVertical];
    
    self.layer.shadowColor = [[UIColor redColor] CGColor];
    self.layer.shadowRadius = 5.;
    self.layer.shadowOpacity = 0.;
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
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (CGSize) intrinsicContentSize {
    CGSize textSize = [self.textLabel intrinsicContentSize];
    CGSize imageSize = [self.textLabel intrinsicContentSize];
    
    return CGSizeMake(textSize.width, textSize.height + imageSize.height);
}

@end

//
//  GameViewController+Animations.m
//  JustNumber
//
//  Created by Paul de Lange on 4/06/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "GameViewController+Animations.h"

#import "UIImage+ImageEffects.h"

#import <objc/runtime.h>

@interface UIViewController (AnimationsInternal)

@property (copy, nonatomic) void (^completion)(BOOL finished);

@end

@implementation UIViewController (Animations)

- (void) animateMessage: (NSString*) message completion: (void (^)(BOOL finished)) completion {
    CGSize size = self.view.bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [self.view drawViewHierarchyInRect:(CGRect){.origin = CGPointZero, .size = size} afterScreenUpdates: NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
 
    UIImage* blurred = [image applyBlurWithRadius: 2.
                                        tintColor: [[UIColor whiteColor] colorWithAlphaComponent: 0.2]
                            saturationDeltaFactor: 1.8
                                        maskImage: nil];
    
    UIImageView* background = [[UIImageView alloc] initWithImage: blurred];
    background.contentMode = UIViewContentModeScaleAspectFit;
    background.alpha = 0.;
    background.userInteractionEnabled = YES;
    [self.view addSubview: background];
    
    UILabel* label = [[UILabel alloc] initWithFrame: CGRectZero];
    label.font = [UIFont fontWithName: @"Chalkduster" size: 32.];
    label.textColor = [UIColor greenColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(2, 2);
    label.text = message;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    [background addSubview: label];
    
    [background addConstraint: [NSLayoutConstraint constraintWithItem: label
                                                            attribute: NSLayoutAttributeCenterY
                                                            relatedBy: NSLayoutRelationEqual
                                                               toItem: background
                                                            attribute: NSLayoutAttributeCenterY
                                                           multiplier: 1.0
                                                             constant: 0.0]];
    [background addConstraint: [NSLayoutConstraint constraintWithItem: label
                                                       attribute: NSLayoutAttributeWidth
                                                       relatedBy: NSLayoutRelationLessThanOrEqual
                                                          toItem: background
                                                       attribute: NSLayoutAttributeWidth
                                                      multiplier: 1.0
                                                        constant: -40]];
    NSLayoutConstraint* x = [NSLayoutConstraint constraintWithItem: label
                                                         attribute: NSLayoutAttributeCenterX
                                                         relatedBy: NSLayoutRelationEqual
                                                            toItem: background
                                                         attribute: NSLayoutAttributeCenterX
                                                        multiplier: 1.0
                                                          constant: -CGRectGetWidth(self.view.frame)];
    [background addConstraint: x];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                          action: @selector(backgroundTapped:)];
    [background addGestureRecognizer: tap];
    
     self.completion = completion;
    
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations: ^{
                         background.alpha = 1.;
                     } completion: ^(BOOL finished) {
                         
                         x.constant = 0;
                         
                         [UIView animateWithDuration: 0.3
                                               delay: 0.0
                              usingSpringWithDamping: 0.9
                               initialSpringVelocity: 10
                                             options: UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              [label layoutIfNeeded];
                                          } completion:^(BOOL finished) {
                                              
                                          }];
                     }];
    
   
    [self performSelector: @selector(backgroundTapped:) withObject: tap afterDelay: 1.8];
}

- (IBAction) backgroundTapped:(UITapGestureRecognizer*)sender {
    
    UIView* background = sender.view;
    NSLayoutConstraint* x;
    for(NSLayoutConstraint* constraint in background.constraints) {
        if( constraint.firstAttribute == NSLayoutAttributeCenterX &&
           constraint.secondAttribute == NSLayoutAttributeCenterX ) {
            x = constraint;
            break;
        }
    }
    
    x.constant = CGRectGetWidth(self.view.bounds);
    [UIView animateWithDuration: 0.3
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         background.alpha = 0.;
                         [background layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         [background removeFromSuperview];
                         void (^comp)(BOOL) = self.completion;
                         self.completion = nil;
                         
                         if( comp ) {
                             comp(finished);
                         }
                     }];
    
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(backgroundTapped:) object: sender];
}

- (void) setCompletion:(void (^)(BOOL))completion {
    objc_setAssociatedObject(self, @selector(completion), completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)(BOOL)) completion {
    void (^obj)(BOOL) = objc_getAssociatedObject(self, @selector(completion));
    return obj;
}

@end

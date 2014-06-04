//
//  GameViewController+Animations.m
//  JustNumber
//
//  Created by Paul de Lange on 4/06/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "GameViewController+Animations.h"

#import "UIImage+ImageEffects.h"

@implementation GameViewController (Animations)

- (void) animateCorrectAnswer: (void (^)(BOOL finished)) completion {
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
    [self.view addSubview: background];
    
    UILabel* label = [[UILabel alloc] initWithFrame: CGRectZero];
    label.font = [UIFont fontWithName: @"Chalkduster" size: 32.];
    label.textColor = [UIColor redColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(2, 2);
    label.text = NSLocalizedString(@"That's\nRight!", @"");
    label.numberOfLines = 0;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    [background addSubview: label];
    
    [background addConstraint: [NSLayoutConstraint constraintWithItem: label
                                                            attribute: NSLayoutAttributeCenterY
                                                            relatedBy: NSLayoutRelationEqual
                                                               toItem: background
                                                            attribute: NSLayoutAttributeCenterY
                                                           multiplier: 1.0
                                                             constant: 0.0]];
    NSLayoutConstraint* x = [NSLayoutConstraint constraintWithItem: label
                                                         attribute: NSLayoutAttributeCenterX
                                                         relatedBy: NSLayoutRelationEqual
                                                            toItem: background
                                                         attribute: NSLayoutAttributeCenterX
                                                        multiplier: 1.0
                                                          constant: -CGRectGetWidth(self.view.frame)];
    [background addConstraint: x];
    
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
                                              x.constant = CGRectGetWidth(self.view.bounds);
                                              [UIView animateWithDuration: 0.3
                                                                    delay: 0.6
                                                                  options: UIViewAnimationOptionCurveEaseOut
                                                               animations:^{
                                                                   background.alpha = 0.;
                                                                   [label layoutIfNeeded];
                                                               } completion:^(BOOL finished) {
                                                                   [background removeFromSuperview];
                                                                   if( completion )
                                                                       completion(finished);
                                                               }];
                                          }];
                     }];
}

@end

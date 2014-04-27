//
//  GameViewController+Keyboard.m
//  JustNumber
//
//  Created by Paul de Lange on 27/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "GameViewController+Keyboard.h"

@interface GameViewController (KeyboardInternal) <UITextFieldDelegate>

@property (weak, nonatomic) NSLayoutConstraint* inputViewBottomLayoutConstraint;
@property (weak, nonatomic) UITextField* inputView;

@end

@implementation GameViewController (KeyboardInternal)

@dynamic inputViewBottomLayoutConstraint;
@dynamic inputView;

- (void) addKeyboardObserver:(NSObject *)observer options:(NSKeyValueObservingOptions)options context:(void *)context {
    
    if( options & NSKeyValueObservingOptionNew ) {
        [[NSNotificationCenter defaultCenter] addObserver: observer
                                                 selector: @selector(keyboardWillAppear:)
                                                     name: UIKeyboardWillShowNotification
                                                   object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: observer
                                                 selector: @selector(keyboardDidAppear:)
                                                     name: UIKeyboardDidShowNotification
                                                   object: nil];
    }
    
    if( options & NSKeyValueObservingOptionOld ) {
        [[NSNotificationCenter defaultCenter] addObserver: observer
                                                 selector: @selector(keyboardWillDisappear:)
                                                     name: UIKeyboardWillHideNotification
                                                   object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: observer
                                                 selector: @selector(keyboardDidDisappear:)
                                                     name: UIKeyboardDidHideNotification
                                                   object: nil];
    }
}

- (void) removeKeyboardObserver:(NSObject *)observer context:(void *)context {
    [[NSNotificationCenter defaultCenter] removeObserver: observer];
}

#pragma mark - Notifications
- (void) keyboardWillAppear: (NSNotification*) notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    NSTimeInterval animationInterval = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    CGRect finalKeyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    CGFloat height = isPortrait ? CGRectGetHeight(finalKeyboardFrame) : CGRectGetWidth(finalKeyboardFrame);
    
    self.inputViewBottomLayoutConstraint.constant = height + 10;// - CGRectGetHeight(self.tabBarController.tabBar.frame);
    
    /* NB: The following does not work because the animationCurve is undocumented on iOS7. It means it is
     impossible to convert between the UIViewAnimationCurve parameter returned by UIKeyboardAnimationCurveUserInfoKey
     and the UIViewAnimationOptions required below. It is possible to hack a solution using animationCurve << 16 but
     this is not future safe!! Instead, I returned to the old inline methods.
     
     http://stackoverflow.com/questions/7327249/ios-how-to-convert-uiviewanimationcurve-to-uiviewanimationoptions
     
     [UIView animateWithDuration: animationInterval
     delay: 0
     options: animationCurve << 16
     animations: ^{
     [self.view layoutIfNeeded];
     } completion: NULL]; */
    
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration: animationInterval];
    [UIView setAnimationCurve: animationCurve];
    
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
}

//Normally these three methods are not called. But when the keyboard size/language changes (Japanese), these can be called
- (void) keyboardDidAppear: (NSNotification*) notifciation {}
- (void) keyboardWillDisappear: (NSNotification*) notification {}
- (void) keyboardDidDisappear: (NSNotification*) notification {}

@end

//
//  GameViewController.m
//  JustNumber
//
//  Created by Paul de Lange on 27/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "GameViewController.h"
#import "GameViewController+Keyboard.h"

#import "UINumberField.h"

@interface GameViewController () <UINumberFieldDelegate>

@property (weak, nonatomic) IBOutlet UINumberField *inputView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewBottomLayoutConstraint;

@end

@implementation GameViewController

#pragma mark - NSObject
- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    
    if( self ) {
        [self addKeyboardObserver: self
                          options: NSKeyValueObservingOptionNew // | NSKeyValueObservingOptionOld
                          context: nil];
    }
    
    return self;
}

- (void) dealloc {
    [self removeKeyboardObserver: self context: nil];
}

#pragma mark - UIViewController
- (void) viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden: NO animated: YES];
    
    [self.inputView becomeFirstResponder];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    //For some reason becomeFirstResponder fails sometimes on viewWillAppear:
    // It looks better there, but catch here if things failed
    if( ![self.inputView isFirstResponder] )
        [self.inputView becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate

#pragma mark - UINumberFieldDelegate
- (void) numberField:(UINumberField *)numberField didChangeToValue:(NSInteger)integerValue {
    
}

@end

//
//  UINumberField.h
//  JustNumber
//
//  Created by Paul de Lange on 27/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UINumberField;

@protocol UINumberFieldDelegate <UITextFieldDelegate>
@optional
- (void)numberField:(UINumberField *)numberField didChangeToValue: (NSInteger) integerValue;

@end

@interface UINumberField : UITextField

@property (assign, nonatomic) BOOL automaticallyFormatsInput;

- (NSInteger) integerValue;

- (void) appendInteger: (NSInteger) integer;

@end

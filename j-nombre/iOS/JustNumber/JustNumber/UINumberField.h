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
- (void)numberField:(UINumberField *)numberField didChangeToValue: (NSUInteger) integerValue;

@end

@interface UINumberField : UITextField

@property (copy, nonatomic) NSString* unitString;
@property (assign, nonatomic) BOOL automaticallyFormatsInput;

- (double) integerValue;

- (void) appendInteger: (NSInteger) integer;

@end

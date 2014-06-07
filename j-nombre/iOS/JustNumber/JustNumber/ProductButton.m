//
//  ProductButton.m
//  JustNumber
//
//  Created by Paul de Lange on 7/06/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "ProductButton.h"

@interface ProductButton ()

@property (weak, nonatomic) UILabel* quantityLabel;
@property (weak, nonatomic) UILabel* priceLabel;

@end

@implementation ProductButton

- (void) setQuantity:(NSString *)quantity {
    _quantity = [quantity copy];
    self.quantityLabel.text = quantity;
    [self setNeedsLayout];
}

- (void) setPrice:(NSString *)price {
    _price = [price copy];
    self.priceLabel.text = price;
    [self setNeedsLayout];
}

#pragma mark - NSObject
- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    
    if( self ) {
        UILabel* qlabel = [[UILabel alloc] initWithFrame: CGRectZero];
        qlabel.translatesAutoresizingMaskIntoConstraints = NO;
        qlabel.textAlignment = NSTextAlignmentCenter;
        qlabel.textColor = [UIColor blackColor];
        qlabel.font = [UIFont systemFontOfSize: 15.];
        
        UILabel* plabel = [[UILabel alloc] initWithFrame: CGRectZero];
        plabel.translatesAutoresizingMaskIntoConstraints = NO;
        plabel.textAlignment = NSTextAlignmentCenter;
        plabel.textColor = [UIColor blackColor];
        plabel.font = [UIFont systemFontOfSize: 15.];
        
        [self addSubview: qlabel];
        [self addSubview: plabel];
        
        UIImageView* iview = self.imageView;
        [iview removeConstraints: iview.constraints];
        iview.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setTitle: @"" forState: UIControlStateNormal];
        
        [self setImage: [UIImage imageNamed: @"lives"]  forState: UIControlStateNormal];
        
        [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-[qlabel]-[iview]-[plabel]-|"
                                                                      options: 0
                                                                      metrics: nil
                                                                        views: NSDictionaryOfVariableBindings(qlabel, iview, plabel)]];
        [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[qlabel]|"
                                                                      options: 0
                                                                      metrics: nil
                                                                        views: NSDictionaryOfVariableBindings(qlabel)]];
        [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[plabel]|"
                                                                      options: 0
                                                                      metrics: nil
                                                                        views: NSDictionaryOfVariableBindings(plabel)]];
        [self addConstraint: [NSLayoutConstraint constraintWithItem: iview
                                                          attribute: NSLayoutAttributeCenterX
                                                          relatedBy: NSLayoutRelationEqual
                                                             toItem: self
                                                          attribute: NSLayoutAttributeCenterX
                                                         multiplier: 1.0
                                                           constant: 0.0]];
        self.quantityLabel = qlabel;
        self.priceLabel = plabel;
        
        self.backgroundColor = [UIColor orangeColor];
        self.layer.borderColor = [[UIColor blackColor] CGColor];
        self.layer.borderWidth = 2.;
        self.layer.cornerRadius = 5.;
    }
    
    return self;
}

#pragma mark - UIButton
- (void) setEnabled:(BOOL)enabled {
    [super setEnabled: enabled];
    
    if( enabled ) {
        self.quantityLabel.textColor = [UIColor blackColor];
        self.priceLabel.textColor = [UIColor blackColor];
        self.layer.borderColor = [[UIColor blackColor] CGColor];
    }
    else {
        self.quantityLabel.textColor = [UIColor grayColor];
        self.priceLabel.textColor = [UIColor grayColor];
        self.layer.borderColor = [[UIColor grayColor] CGColor];
    }
}

- (void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted: highlighted];
    
    UIColor* color = [UIColor blackColor];
    
    if( highlighted )
        color = [color colorWithAlphaComponent: 0.5];
    
    self.quantityLabel.textColor = color;
    self.priceLabel.textColor = color;
    
}

@end

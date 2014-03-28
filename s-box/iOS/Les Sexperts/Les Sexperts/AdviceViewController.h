//
//  AdviceViewController.h
//  Les Sexperts
//
//  Created by Paul De Lange on 28/02/14.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Advice;

@interface AdviceViewController : UIViewController

@property (strong, nonatomic) Advice* advice;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (IBAction)sharePushed:(id)sender;

@end

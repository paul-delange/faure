//
//  ResumeViewController.h
//  Les Sexperts
//
//  Created by Paul de Lange on 6/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kUserPreferenceCleared50Points;
extern NSString * const kUserPreferenceCleared45Points;
extern NSString * const kUserPreferenceCleared40Points;
extern NSString * const kUserPreferenceCleared35Points;
extern NSString * const kUserPreferenceCleared30Points;
extern NSString * const kUserPreferenceCleared25Points;
extern NSString * const kUserPreferenceCleared20Points;
extern NSString * const kUserPreferenceCleared15Points;
extern NSString * const kUserPreferenceCleared10Points;
extern NSString * const kUserPreferenceCleared5Points;

@interface ResumeViewController : UIViewController

@property (assign) NSUInteger score;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

- (IBAction)sharePushed:(id)sender;

+ (BOOL) hasDisplayedForScore: (NSUInteger) score;

@end

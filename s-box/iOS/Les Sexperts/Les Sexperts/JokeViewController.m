//
//  JokeViewController.m
//  Les Sexperts
//
//  Created by Paul de Lange on 4/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "JokeViewController.h"

#import "Joke.h"    
#import "UIImage+ImageEffects.h"

#import "ContentLock.h"

#define HTML_FORMAT @"<html><body bgcolor=\"#000000\" text=\"#FFFFFF\" face=\"American Typewriter\" size=\"5\">%@</body></html>"
#define HTML_STRING_FROM_TEXT( text ) [NSString stringWithFormat: HTML_FORMAT, text]

@interface JokeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView* maskImageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation JokeViewController

- (void) setBlocked:(BOOL)blocked {
    if( _blocked != blocked ) {
        _blocked = blocked;
        
        if( blocked ) {
            UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
            [self.view drawViewHierarchyInRect: self.view.frame afterScreenUpdates: YES];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            self.maskImageView.image = [image applyBlurWithRadius: 2.5
                                                        tintColor: [UIColor clearColor]
                                            saturationDeltaFactor: 1.8
                                                        maskImage: nil];
            self.maskImageView.hidden = NO;
        }
        else {
            self.maskImageView.hidden = YES;
        }
    }
}

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.textView.text = self.joke.text;
}

@end

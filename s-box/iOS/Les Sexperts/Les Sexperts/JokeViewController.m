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
            
            self.maskImageView.image = [image applyBlurWithRadius: 3.5
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

- (void) contentWasUnlocked: (NSNotification*) notification  {
    self.blocked = NO;
}

#pragma mark - NSObject
- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if( self ) {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(contentWasUnlocked:)
                                                     name: ContentLockWasRemovedNotification
                                                   object: nil];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.textView.text = self.joke.text;
    
    UIColor* topColor = [UIColor colorWithRed: 35/255. green: 40/255. blue: 43/255. alpha: 1.];
    UIColor* centerColor = [UIColor colorWithRed: 39/255. green: 56/255. blue: 66/255. alpha: 1.];
    UIColor* bottomColor = [UIColor colorWithRed: 23/255. green: 85/255. blue: 102/255. alpha: 1.];
    
    CAGradientLayer* gradient = [CAGradientLayer layer];
    gradient.colors = @[(id)topColor.CGColor, (id)centerColor.CGColor, (id)bottomColor.CGColor];
    gradient.startPoint = CGPointMake(0.5, 0.);
    gradient.endPoint = CGPointMake(0.5, 1.);
    gradient.locations = @[@(0.25), @(0.75)];
    gradient.bounds = self.view.bounds;
    gradient.anchorPoint = CGPointMake(CGRectGetMinX(gradient.bounds), 0);
    
    [self.view.layer insertSublayer: gradient atIndex: 0];

}

@end

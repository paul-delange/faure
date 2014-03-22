//
//  JokeViewController.h
//  Les Sexperts
//
//  Created by Paul de Lange on 4/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Joke;

@interface JokeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (strong, nonatomic) Joke* joke;
@property (assign, nonatomic) BOOL blocked;

@end

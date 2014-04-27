//
//  AppViewController.m
//  JustNumber
//
//  Created by Paul de Lange on 27/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "AppViewController.h"

@interface AppViewController ()

@end

@implementation AppViewController

#pragma mark - NSObject
- (void) awakeFromNib {
    [super awakeFromNib];
    
    UIViewController* left = [self.storyboard instantiateViewControllerWithIdentifier: @"MenuViewController"];
    UIViewController* center = [self.storyboard instantiateViewControllerWithIdentifier: @"HomeViewController"];
    
    [self setLeftPanel: left];
    [self setCenterPanel: center];
}

#pragma mark JASidePanelController
- (void) stylePanel:(UIView *)panel {
    //Don't round the corners!
}

- (void) showLeftPanelAnimated:(BOOL)animated {
    [self.leftPanel beginAppearanceTransition: YES animated: animated];
    
    [super showLeftPanelAnimated: animated];
    
    [self.leftPanel endAppearanceTransition];
}

- (void) showCenterPanelAnimated:(BOOL)animated {
    [self.leftPanel beginAppearanceTransition: NO animated: animated];
    
    [super showCenterPanelAnimated: animated];
    
    [self.leftPanel endAppearanceTransition];
}

@end

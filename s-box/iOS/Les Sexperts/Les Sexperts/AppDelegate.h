//
//  AppDelegate.h
//  Les Sexperts
//
//  Created by Paul De Lange on 28/02/14.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIApplication+Versioning.h"

@class CoreDataStack;

@interface AppDelegate : UIResponder <UIApplicationDelegateVersioning>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CoreDataStack* dataStack;

@end

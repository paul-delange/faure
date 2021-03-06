//
//  AppDelegate.h
//  JustNumber
//
//  Created by Paul de Lange on 22/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CoreDataStack;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

- (UILocalNotification*) rechargeNotification;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CoreDataStack* dataStore;

@end

//
//  UIApplication+Versioning.h
//  JustNumber
//
//  Created by Paul de Lange on 2/05/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIApplicationDelegateVersioning <UIApplicationDelegate>
@optional
- (void) application:(UIApplication *)application willUpdateToVersion: (NSString*) newVersion fromVersion: (NSString*) previousVersion;
- (void) application:(UIApplication *)application didUpdateToVersion: (NSString*) newVersion fromVersion: (NSString*) previousVersion;

@end

@interface UIApplication (Versioning)

@end

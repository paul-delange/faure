//
//  UIApplication+Versioning.h
//  e-Anatomy
//
//  Created by MacBook Pro on 21/09/12.
//  Copyright (c) 2012 IMAIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIApplicationDelegateVersioning <UIApplicationDelegate>
@optional
- (void) application:(UIApplication *)application willUpdateToVersion: (NSString*) newVersion fromVersion: (NSString*) previousVersion;
- (void) application:(UIApplication *)application didUpdateToVersion: (NSString*) newVersion fromVersion: (NSString*) previousVersion;

@end

@interface UIApplication (Versioning)

@end

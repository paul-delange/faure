//
//  UIApplication+Versioning.m
//  JustNumber
//
//  Created by Paul de Lange on 2/05/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "UIApplication+Versioning.h"

#import <objc/message.h>
#import <objc/runtime.h>

static NSString* UIApplicationVersionFileName = @"app.ver";

@implementation UIApplication (Versioning)

+ (void) load {
    Method original, swizzled;
    
    original = class_getInstanceMethod(self, @selector(setDelegate:));
    swizzled = class_getInstanceMethod(self, @selector(swizzled_setDelegate:));
    
    method_exchangeImplementations(original, swizzled);
}

- (void) swizzled_setDelegate: (id<UIApplicationDelegate>) delegate {
    
    IMP implementation = class_getMethodImplementation([self class], @selector(swizzled_application:didFinishLaunchingWithOptions:));
    class_addMethod([delegate class], @selector(swizzled_application:didFinishLaunchingWithOptions:), implementation, "B@:@@");
    
    Method original, swizzled;
    
    original = class_getInstanceMethod([delegate class], @selector(application:didFinishLaunchingWithOptions:));
    swizzled = class_getInstanceMethod([delegate class], @selector(swizzled_application:didFinishLaunchingWithOptions:));
    
    method_exchangeImplementations(original, swizzled);
    
    [self swizzled_setDelegate: delegate];
}

- (BOOL)swizzled_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Check for a version change
    NSError* error;
    NSArray* directories = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString* versionFilePath = [[directories objectAtIndex: 0] stringByAppendingPathComponent: UIApplicationVersionFileName];
    NSString* oldVersion = [NSString stringWithContentsOfFile: versionFilePath
                                                     encoding: NSUTF8StringEncoding
                                                        error: &error];
    NSString* currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleVersion"];
    
    if( error ) {
        switch (error.code) {
            case NSFileReadNoSuchFileError:
            {
                NSLog(@"Warning: first time to access version file -> Creating file");
                break;
            }
            default:
            {
                NSLog(@"Warning: An error '%@' occured will loading the application version file -> Recreating file", error);
                break;
            }
        }
    }
    
    id<UIApplicationDelegateVersioning> delegate = (id<UIApplicationDelegateVersioning>)[application delegate];
    
    if( ![oldVersion isEqualToString: currentVersion] ) {
        
        if ([delegate respondsToSelector: @selector(application:willUpdateToVersion:fromVersion:)]) {
            //objc_msgSend([application delegate], @selector(application:willUpdateToVersion:fromVersion:), currentVersion, oldVersion);
            [delegate application: application willUpdateToVersion: currentVersion fromVersion: oldVersion];
        }
        
        [currentVersion writeToFile: versionFilePath
                         atomically: YES
                           encoding: NSUTF8StringEncoding
                              error: &error];
        
        if ([delegate respondsToSelector: @selector(application:didUpdateToVersion:fromVersion:)]) {
            [delegate application: application didUpdateToVersion: currentVersion fromVersion: oldVersion];
        }
        
    }
    
    SEL realSelector =  @selector(swizzled_application:didFinishLaunchingWithOptions:);
    return (BOOL) objc_msgSend([application delegate], realSelector, application, launchOptions);
}

@end
//
//  main.m
//  JustNumber
//
//  Created by Paul de Lange on 22/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

NSString * const kAppName() {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey: (id)kCFBundleNameKey];
}

int main(int argc, char * argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

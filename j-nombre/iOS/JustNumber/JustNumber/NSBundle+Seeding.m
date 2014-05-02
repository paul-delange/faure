//
//  NSBundle+Seeding.m
//  94-percent
//
//  Created by Paul de Lange on 24/03/2014.
//  Copyright (c) 2014 Scimob. All rights reserved.
//

#import "NSBundle+Seeding.h"

//Directory name inside the "Resources" project folder where the app should search for seed data.
#define SEED_DATA_DIRECTORY_NAME    @"Seed Data"

@implementation NSBundle (Seeding)

+ (NSBundle*) seedBundle {
#if TARGET_OS_IPHONE
    NSString* path = [[NSBundle mainBundle] pathForResource: SEED_DATA_DIRECTORY_NAME ofType: @""];
    return [NSBundle bundleWithPath: path];
#else
    return [NSBundle mainBundle];
#endif
}

@end

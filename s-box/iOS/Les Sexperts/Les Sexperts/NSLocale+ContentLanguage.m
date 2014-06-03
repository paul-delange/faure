//
//  NSLocale+ContentLanguage.m
//  Les Sexperts
//
//  Created by Paul de Lange on 31/05/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "NSLocale+ContentLanguage.h"
#import "NSBundle+Seeding.h"

@implementation NSLocale (ContentLanguage)

+ (NSArray*) availableContentLanguages {
    NSArray* paths = [[NSBundle seedBundle] URLsForResourcesWithExtension: @"db" subdirectory: nil];
    NSMutableArray* contentLanguages = [NSMutableArray new];
    [paths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSURL* path = (NSURL*)obj;
        NSString* fileName = [[path lastPathComponent] stringByDeletingPathExtension];
        NSArray* components = [fileName componentsSeparatedByString: @"_"];
        if( [components count] == 2 ) {
            //NSString* baseName = components[0];
            NSString* langCode = components[1];
            
            if( [langCode length] == 2 ) {
                [contentLanguages addObject: langCode];
            }
        }
        else if( [components count] == 3 ) {
            NSString* langCode = components[1];
            NSString* regionCode = components[2];
            
            if( [langCode length] == 2 && [regionCode length] == 2) {
                [contentLanguages addObject: [NSString stringWithFormat: @"%@_%@", langCode, regionCode]];
            }
        }
    }];
    
    return contentLanguages;
}

+ (NSString*) contentLanguageNearestDeviceLanguage {
#if TARGET_OS_IPHONE
    NSArray* contentLanguages = [self availableContentLanguages];
    
    //Only search the top language!!
    NSArray* preferredLanguages = [[self preferredLanguages] subarrayWithRange: NSMakeRange(0, 1)];
    
    for(NSString* preferredLanguage in preferredLanguages) {
        //Try to find exact match....
        NSPredicate* likePredicate = [NSPredicate predicateWithFormat: @"SELF LIKE[cd] %@", preferredLanguage];
        NSArray* matchingContentLanguages = [contentLanguages filteredArrayUsingPredicate: likePredicate];
        if( [matchingContentLanguages count] )
            return matchingContentLanguages[0];
        
        //Then try for something similar....
        NSPredicate* containsPredicate = [NSPredicate predicateWithFormat: @"SELF CONTAINS[cd] %@", [NSString stringWithFormat: @"%@_", preferredLanguage]];
        matchingContentLanguages = [contentLanguages filteredArrayUsingPredicate: containsPredicate];
        if( [matchingContentLanguages count] )
            return matchingContentLanguages[0];
    }
#endif
    return @"fr";   //Default to english
}

@end

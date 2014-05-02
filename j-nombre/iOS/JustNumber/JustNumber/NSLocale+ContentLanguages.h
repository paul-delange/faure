//
//  NSLocale+ContentLanguages.h
//  94-percent
//
//  Created by Paul de Lange on 20/03/2014.
//  Copyright (c) 2014 Scimob. All rights reserved.
//

#import <Foundation/Foundation.h>

/** A category to deal with the app content languages */
@interface NSLocale (ContentLanguages)

/** @return An array of the available ISO content language identifiers that were bundled with the app at compile time */
+ (NSArray*) availableContentLanguages;


/** @return The language groups that were bundled with the app */
+ (NSArray*) availableLanguageGroups;

/** @return The language groups that were bundled with the app */
+ (NSArray*) availableContentCountriesInGroup: (NSString*) group;

/** @return An ISO language identifier for the content that is nearest to the current device language */
+ (NSString*) contentLanguageNearestDeviceLanguage;

@end

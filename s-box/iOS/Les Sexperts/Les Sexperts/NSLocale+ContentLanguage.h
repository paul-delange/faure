//
//  NSLocale+ContentLanguage.h
//  Les Sexperts
//
//  Created by Paul de Lange on 31/05/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSLocale (ContentLanguage)

/** @return An array of the available ISO content language identifiers that were bundled with the app at compile time */
+ (NSArray*) availableContentLanguages;

/** @return An ISO language identifier for the content that is nearest to the current device language */
+ (NSString*) contentLanguageNearestDeviceLanguage;

@end

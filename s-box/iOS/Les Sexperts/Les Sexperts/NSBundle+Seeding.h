//
//  NSBundle+Seeding.h
//
//  Created by Paul de Lange on 24/03/2014.
//

#import <Foundation/Foundation.h>

@interface NSBundle (Seeding)

/** @return A Bundle where seed databases can be found */
+ (NSBundle*) seedBundle;

@end

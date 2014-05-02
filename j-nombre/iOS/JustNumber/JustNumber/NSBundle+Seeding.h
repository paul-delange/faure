//
//  NSBundle+Seeding.h
//  94-percent
//
//  Created by Paul de Lange on 24/03/2014.
//  Copyright (c) 2014 Scimob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (Seeding)

/** @return A Bundle where seed databases can be found */
+ (NSBundle*) seedBundle;

@end

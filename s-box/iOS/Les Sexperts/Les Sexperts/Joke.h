#import "_Joke.h"

@class PFObject;

@interface Joke : _Joke {}

+ (instancetype) newWithPFObject: (PFObject*) payload;
+ (instancetype) copyWithAPSDictionary: (NSDictionary*) payload;

@end

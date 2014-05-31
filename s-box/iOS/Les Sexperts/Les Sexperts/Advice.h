#import "_Advice.h"

@class PFObject;

@interface Advice : _Advice {}

+ (instancetype) newWithPFObject: (PFObject*) payload;
+ (instancetype) copyWithAPSDictionary: (NSDictionary*) payload;

@end

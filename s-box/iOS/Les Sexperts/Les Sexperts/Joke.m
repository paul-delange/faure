#import "Joke.h"

#import <Parse/Parse.h>

@interface Joke ()

// Private interface goes here.

@end


@implementation Joke

+ (instancetype) newWithPFObject: (PFObject*) payload {
    NSManagedObjectContext* context = kMainManagedObjectContext();
    NSParameterAssert(context);
    
    Joke* joke = [Joke insertInManagedObjectContext: context];
    joke.free = @YES;
    joke.text = [payload valueForKey: @"text"];
    joke.remoteID = payload.objectId;
    joke.isNew = @YES;
    
    [context performBlockAndWait:^{
        NSError* error;
        [context save: &error];
        DLogError(error);
    }];
    
    return joke;
}

+ (instancetype) copyWithAPSDictionary: (NSDictionary*) payload {
    if( !payload[@"jid"] )
        return nil;
    
    NSManagedObjectContext* context = kMainManagedObjectContext();
    NSParameterAssert(context);
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName: @"Joke"];
    [request setFetchLimit: 1];
    [request setPredicate: [NSPredicate predicateWithFormat: @"remoteID = %@", payload[@"jid"]]];
    
    NSError* error;
    NSArray* results = [context executeFetchRequest: request error: &error];
    DLogError(error);
    
    return [results lastObject];
}

@end

#import "Advice.h"

#import "Theme.h"

#import <Parse/Parse.h>

@interface Advice ()

// Private interface goes here.

@end


@implementation Advice

+ (instancetype) newWithPFObject: (PFObject*) payload {
    NSManagedObjectContext* context = kMainManagedObjectContext();
    NSParameterAssert(context);
    
    Advice* advice = [Advice insertInManagedObjectContext: context];
    advice.free = @YES;
    advice.remoteID = payload.objectId;
    advice.text = [payload valueForKey: @"text"];
    advice.title = [payload valueForKey: @"title"];
    advice.isNew = @YES;
    
    NSString* themeName = [payload valueForKey: @"theme"];
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName: @"Theme"];
    [request setPredicate: [NSPredicate predicateWithFormat: @"name = %@", themeName]];
    [request setFetchLimit: 1];
    
    NSError* error;
    NSArray* results = [context executeFetchRequest: request error: &error];
    DLogError(error);
    
    if( [results count] ) {
        advice.theme = [results lastObject];
    }
    else {
        Theme* theme = [Theme insertInManagedObjectContext: context];
        theme.name = themeName;
        advice.theme = theme;
    }
    
    [context performBlockAndWait:^{
        NSError* error;
        [context save: &error];
        DLogError(error);
    }];
    
    return advice;
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

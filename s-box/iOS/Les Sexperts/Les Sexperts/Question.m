#import "Question.h"

#import "Answer.h"

@interface Question ()

// Private interface goes here.

@end


@implementation Question

+ (void) resetHistoryAndShuffle {
    NSManagedObjectContext* context = kMainManagedObjectContext();
    
    NSFetchRequest* fetch = [NSFetchRequest fetchRequestWithEntityName: @"Question"];
    NSMutableArray* results = [[context executeFetchRequest: fetch error: nil] mutableCopy];
    
    NSUInteger count = [results count];
    
    //Shuffle
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = arc4random_uniform((uint32_t)nElements) + i;
        [results exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    //Reset the history
    for(Question* q in results) {
        q.lastDisplayedTime = [NSDate date];
    }
    
    //Save
    while (context) {
        [context performBlockAndWait: ^{
            NSError* error;
            [context save: &error];
            DLogError(error);
        }];
        
        context = context.parentContext;
    }
}

+ (instancetype) leastUsedQuestion {
    NSFetchRequest* fetch = [NSFetchRequest fetchRequestWithEntityName: @"Question"];
    [fetch setSortDescriptors: @[[NSSortDescriptor sortDescriptorWithKey: @"lastDisplayedTime" ascending: NO]]];
    
    NSArray* results = [kMainManagedObjectContext() executeFetchRequest: fetch error: nil];
    return results.lastObject;
}

- (Answer*) correctAnswer {
    NSOrderedSet* correct = [self.answers filteredOrderedSetUsingPredicate: [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Answer* ans = (Answer*)evaluatedObject;
        return ans.isCorrectValue;
    }]];
    
    if( [correct count] != 1 ) {
        DLog(@"%@ has %zu correct answers", self, [correct count]);
    }
    
    return correct.lastObject;
}

@end

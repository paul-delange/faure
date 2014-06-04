#import "ScoreSheet.h"

#import "CoreDataStack.h"

#import "Score.h"
#import "Question.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@interface ScoreSheet ()

// Private interface goes here.

@end


@implementation ScoreSheet

+ (instancetype) currentScoreSheet {
    
    NSManagedObjectContext* ctx = NSManagedObjectContextGetMain();
    NSLocale* contextLocale = [ctx locale];
    NSString* localeIdentifier = [contextLocale localeIdentifier];
    
    NSPredicate* localePredicate = [NSPredicate predicateWithFormat: @"localeIdentifier = %@", localeIdentifier];
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName: @"ScoreSheet"];
    [request setPredicate: localePredicate];
    [request setFetchLimit: 1];
    
    NSError* error;
    NSArray* sheets = [ctx executeFetchRequest: request error: &error];
    DLogError(error);
    
    if( [sheets count] == 1 ) {
        return sheets.lastObject;
    }
    else {
        ScoreSheet* sc = [ScoreSheet insertInManagedObjectContext: ctx];
        sc.localeIdentifier = localeIdentifier;
        
        NSError* error;
        [ctx threadSafeSave: &error];
        DLogError(error);
        
        return sc;
    }
    
    return nil;
}

- (NSSet*) completedQuestionIdentifiers {
    NSPredicate* completedPredicate = [NSPredicate predicateWithFormat: @"timestamp != NULL"];
    NSArray* scores = [self.scores.allObjects filteredArrayUsingPredicate: completedPredicate];
    NSString* word_ids_keypath = [NSString stringWithFormat: @"@%@.%@", NSUnionOfObjectsKeyValueOperator, @"question_id"];
    NSArray* question_ids = [scores valueForKeyPath: word_ids_keypath];
    return [NSSet setWithArray: question_ids];
}

- (BOOL) crossOfQuestion:(Question *)question {
    NSManagedObjectContext* ctx = NSManagedObjectContextGetMain();
    
    NSUInteger tries = [self triesForQuestion: question];
    
    NSString* lang = [ctx.locale objectForKey: NSLocaleLanguageCode];
    [[[GAI sharedInstance] defaultTracker] send: [[GAIDictionaryBuilder createEventWithCategory: lang
                                                                                         action: @"CrossOff"
                                                                                          label: [question.identifier stringValue]
                                                                                          value: @(tries)] build]];
    
    Score* score = [Score scoreForQuestion: question];
    
    if( !score) {
        [Score insertInManagedObjectContext: ctx];
        score.question_id = question.identifier;
        score.sheet = self;
    }
    
    score.timestamp = [NSDate date];
    NSError* error;
    
    [ctx threadSafeSave: &error];
    
    if( error ) {
        DLogError(error);
        return NO;
    }
    
    return YES;
}

- (BOOL) failedAtQuestion: (Question*) question {
    NSManagedObjectContext* ctx = NSManagedObjectContextGetMain();
    
    Score* score = [Score scoreForQuestion: question];
    
    if( !score) {
        [Score insertInManagedObjectContext: ctx];
        score.question_id = question.identifier;
        score.sheet = self;
    }
    
    score.numberOfTriesValue++;
    
    NSError* error;
    
    [ctx threadSafeSave: &error];
    
    if( error ) {
        DLogError(error);
        return NO;
    }
    
    return YES;
}

- (NSUInteger) triesForQuestion: (Question*) question {
    
    
    Score* score = [Score scoreForQuestion: question];
    
    if( !score) {
        NSManagedObjectContext* ctx = NSManagedObjectContextGetMain();
        
        score = [Score insertInManagedObjectContext: ctx];
        score.question_id = question.identifier;
        score.sheet = self;
        
        NSError* error;
        [ctx threadSafeSave: &error];
        DLogError(error);
    }
    
    
    
    
    return score.numberOfTriesValue;
}

@end

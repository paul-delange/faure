#import "ScoreSheet.h"

#import "CoreDataStack.h"

#import "Score.h"
#import "Question.h"

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
    NSArray* scores = self.scores.allObjects;
    NSString* word_ids_keypath = [NSString stringWithFormat: @"@%@.%@", NSUnionOfObjectsKeyValueOperator, @"question_id"];
    NSArray* question_ids = [scores valueForKeyPath: word_ids_keypath];
    return [NSSet setWithArray: question_ids];
}

- (BOOL) crossOfQuestion:(Question *)question {
    NSManagedObjectContext* ctx = NSManagedObjectContextGetMain();
    
    Score* score = [Score insertInManagedObjectContext: ctx];
    score.question_id = question.identifier;
    score.timestamp = [NSDate date];
    score.sheet = self;
    
    NSError* error;
    
    [ctx threadSafeSave: &error];
    
    if( error ) {
        DLogError(error);
        return NO;
    }
    
    return YES;
}

@end

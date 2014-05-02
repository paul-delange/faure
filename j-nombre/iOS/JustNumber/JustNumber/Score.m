#import "Score.h"

#import "Question.h"

@interface Score ()

// Private interface goes here.

@end


@implementation Score

+ (instancetype) scoreForQuestion: (Question*) question {
    NSManagedObjectContext* context = NSManagedObjectContextGetMain();
    NSPredicate* predicate = [NSPredicate predicateWithFormat: @"question_id = %@", question.identifier];
    NSFetchRequest* request= [NSFetchRequest fetchRequestWithEntityName: @"Score"];
    [request setPredicate: predicate];
    [request setFetchLimit: 1];
    
    NSError* error;
    NSArray* results = [context executeFetchRequest: request error: &error];
    DLogError(error);
    
    return results.lastObject;
}

@end

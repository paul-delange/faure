#import "Level.h"

#import "ScoreSheet.h"

@interface Level ()

// Private interface goes here.

@end


@implementation Level

+ (instancetype) currentLevel {
    
    ScoreSheet* scoresheet = [ScoreSheet currentScoreSheet];
    NSManagedObjectContext* context = NSManagedObjectContextGetMain();
    
    NSSet* allCompletedQuestions = [scoresheet completedQuestionIdentifiers];
    NSPredicate* notCompletePredicate = [NSPredicate predicateWithFormat: @"NOT (ANY questions.identifier IN %@)", allCompletedQuestions];
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey: @"identifier" ascending: YES];
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName: @"Level"];
    [request setPredicate: notCompletePredicate];
    [request setSortDescriptors: @[sortDescriptor]];
    
    NSError* error;
    NSArray* incompleteLevels = [context executeFetchRequest: request error: &error];
    DLogError(error);
    
    return incompleteLevels.firstObject;
}

- (instancetype) nextLevel {
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey: @"identifier" ascending: NO];
    NSPredicate* predicate = [NSPredicate predicateWithFormat: @"identifier > %@", self.identifier];
    NSManagedObjectContext* context = NSManagedObjectContextGetMain();
    NSError* error;
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName: @"Level"];
    [request setPredicate: predicate];
    [request setSortDescriptors: @[sortDescriptor]];
    
    NSArray* results = [context executeFetchRequest: request error: &error];
    DLogError(error);
    
    return results.lastObject;
}

- (Question*) nextQuestion {
    ScoreSheet* scoresheet = [ScoreSheet currentScoreSheet];
    NSSet* allCompletedQuestions = [scoresheet completedQuestionIdentifiers];
    NSPredicate* predicate = [NSPredicate predicateWithFormat: @"NOT identifier IN %@", allCompletedQuestions];
    
    NSOrderedSet* notCompleted = [self.questions filteredOrderedSetUsingPredicate: predicate];
    return notCompleted.firstObject;
}

@end

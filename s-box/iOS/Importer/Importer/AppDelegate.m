//
//  AppDelegate.m
//  Importer
//
//  Created by Paul De Lange on 28/02/14.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "AppDelegate.h"

#import "CHCSVParser.h"
#import "CoreDataStack.h"

#import "Question.h"
#import "Answer.h"
#import "Advice.h"
#import "Theme.h"
#import "Joke.h"

@interface AppDelegate () {
    CoreDataStack*  _dataStack;
}

@end

@implementation AppDelegate

- (Question*) questionFromSource: (NSArray*) qsrc withAnswers: (NSArray*) answers inContext: (NSManagedObjectContext*) context {
    NSParameterAssert([qsrc count] == 3);
    Question* question = [NSEntityDescription insertNewObjectForEntityForName: @"Question" inManagedObjectContext: context];
    question.text = qsrc[2];
    //question.explanation = qsrc[3];
    
    //NSLog(@"Q: %@", question.text);
    
    for(NSArray* asrc in answers) {
        NSParameterAssert([asrc count] == 4);
        id correct = [[asrc[3] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @" \""]] lowercaseString];
        NSParameterAssert([correct isEqualToString: @"true"] || [correct isEqualToString: @"false"]);
        
        Answer* answer = [NSEntityDescription insertNewObjectForEntityForName: @"Answer" inManagedObjectContext: context];
        answer.text =  asrc[2];
        answer.isCorrect = ([correct isEqualToString: @"true"]) ? @YES : @NO;
        [question.answersSet addObject: answer];
    }
    
    
    NSOrderedSet* correctAnswers = [question.answers filteredOrderedSetUsingPredicate: [NSPredicate predicateWithFormat: @"isCorrect = YES"]];
    if( correctAnswers.count > 1 ) {
        DLog(@"Deleting %@ because it has true answers %@", question.text, [correctAnswers.array valueForKeyPath: @"@unionOfObjects.text"]);
        [context deleteObject: question];
    }
    
    return question;
}

- (Advice*) adviceFromSource: (NSArray*) asrc inTheme: (NSArray*) tsrc inContent: (NSManagedObjectContext*) context {
    Advice* advice = [NSEntityDescription insertNewObjectForEntityForName: @"Advice" inManagedObjectContext: context];
    advice.title = asrc[1];
    advice.text = asrc[2];
    advice.free = @(![asrc[4] integerValue]);
    //advice.targetGender = @([asrc[4] integerValue]);
    
    id tid = tsrc[1];
    NSPredicate* predicate = [NSPredicate predicateWithFormat: @"name = %@", tid];
    NSFetchRequest* themeFetch = [NSFetchRequest fetchRequestWithEntityName: @"Theme"];
    [themeFetch setPredicate: predicate];
    NSArray* results = [context executeFetchRequest: themeFetch error: nil];
    if( results.count == 1 ){
        advice.theme = [results lastObject];
    }
    else if( results.count == 0) {
        Theme* theme = [NSEntityDescription insertNewObjectForEntityForName: @"Theme" inManagedObjectContext: context];
        theme.name = tsrc[1];
        advice.theme = theme;
    }
    
    return advice;
}

- (Joke*) jokeFromSource: (NSArray*) jsrc inContext: (NSManagedObjectContext*) context {
    NSParameterAssert([jsrc count] >= 2);
    
    NSString* text = jsrc[1];
    if( [text length] <= 0 )
        return nil;
    
    Joke* joke = [NSEntityDescription insertNewObjectForEntityForName: @"Joke" inManagedObjectContext: context];
    joke.text = jsrc[1];
    joke.free = @(![jsrc[0] integerValue]);
    
    return joke;
}

#pragma mark - Actions
- (IBAction) generatorPushed:(id)sender {
    
    _dataStack = [CoreDataStack stackWithStoreFilename: @"Data"];
    
    [self.progressIndicator startAnimation: sender];
    
    
    NSArray* languages = [[NSBundle mainBundle] localizations];
    
    for(NSString* language in languages) {
        _dataStack.dataLanguage = language;
        
        self.statusLabel.stringValue = @"Reading question list...";
        
        NSString* questionsFilePath = [[NSBundle mainBundle] pathForResource: @"questions" ofType: @"csv"];
        NSArray* questions = [NSArray arrayWithContentsOfCSVFile: questionsFilePath];
        
        NSString* answersFilePath = [[NSBundle mainBundle] pathForResource: @"answers" ofType: @"csv"];
        NSArray* answers = [NSArray arrayWithContentsOfCSVFile: answersFilePath];
        
        NSManagedObjectContext* context = _dataStack.mainQueueManagedObjectContext;
        
        for(NSArray* qsrc in questions) {
            if( [qsrc count] != 3 )
                continue;
            
            id qid = qsrc[0];
            NSArray* asrc = [answers filteredArrayUsingPredicate: [NSPredicate predicateWithBlock: ^BOOL(id evaluatedObject, NSDictionary *bindings) {
                NSArray* answer = (NSArray*)evaluatedObject;
                
                if( [answer count] != 4 )
                    return NO;
                
                id aqid = answer[1];
                return [aqid isEqual: qid];
            }]];
            NSParameterAssert([asrc count]);
            
            [self questionFromSource: qsrc withAnswers: asrc inContext: context];
            self.statusLabel.stringValue = [NSString stringWithFormat: @"Added question %@/%lu", qid, (unsigned long)[questions count]];
        }
        
        self.statusLabel.stringValue = @"Reading advice list...";
        
        NSString* themesFilePath = [[NSBundle mainBundle] pathForResource: @"themes" ofType: @"csv"];
        NSArray* themes = [NSArray arrayWithContentsOfCSVFile:  themesFilePath];
        
        NSString* adviceFilePath = [[NSBundle mainBundle] pathForResource: @"conseils" ofType: @"csv"];
        NSArray* advices = [NSArray arrayWithContentsOfCSVFile: adviceFilePath];
        
        for(NSArray* asrc in advices) {
            if( [asrc count] < 5)
                continue;
            
            id tid = asrc[3];
            NSArray* tsrc = [themes filteredArrayUsingPredicate: [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                NSArray* theme = (NSArray*)evaluatedObject;
                
                id atid = theme[0];
                return [atid isEqual: tid];
            }]];
            NSParameterAssert([tsrc count] == 1);
            
            [self adviceFromSource: asrc inTheme: [tsrc lastObject] inContent: context];
        }
        
        self.statusLabel.stringValue = @"Reading joke list...";
        
        NSString* jokesFilePath = [[NSBundle mainBundle] pathForResource: @"blagues" ofType: @"csv"];
        NSArray* jokes = [NSArray arrayWithContentsOfCSVFile: jokesFilePath];
        
        jokes = [jokes subarrayWithRange: NSMakeRange(1, [jokes count]-1)];
        
        for(NSArray* jsrc in jokes) {
            [self jokeFromSource: jsrc inContext: context];
        }
        
        [_dataStack save];
        
        [self.progressIndicator stopAnimation: sender];
        self.statusLabel.stringValue = [NSString stringWithFormat: @"Database ready in %@", language];
    }
}

#pragma mark - UIApplicationDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
}

@end

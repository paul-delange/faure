//
//  JSONParser.m
//  Importer
//
//  Created by Paul de Lange on 28/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "JSONParser.h"
#import "CoreDataStack.h"

#import "Question.h"
#import "Level.h"

@interface JSONParser () {
    NSData* _spreadsheet;
    CoreDataStack* _stack;
}

@end

@implementation JSONParser

- (instancetype) initWithGoogleSpreadsheetData: (NSData*) spreadsheet {
    self = [super init];
    if( self ) {
        _spreadsheet = spreadsheet;
        _stack = [CoreDataStack stackWithStoreFilename: @"Data.sqlite"];
    }
    
    return self;
}

- (BOOL) startParsing: (__autoreleasing NSError**) error {
    id root = [NSJSONSerialization JSONObjectWithData: _spreadsheet options: 0 error: nil];
    id feed = root[@"feed"];
    id entries = feed[@"entry"];
    id cells = [entries valueForKeyPath: @"@unionOfObjects.gs$cell"];
    
    NSMutableDictionary* rows = [NSMutableDictionary new];
    [cells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber* row = obj[@"row"];
        
        if( [row integerValue] > 1 ) {
            NSMutableDictionary* rowDict = [rows objectForKey: row];
            if( !rowDict ) {
                rowDict = [NSMutableDictionary dictionary];
            }
            
            NSNumber* col = obj[@"col"];
            NSString* val = obj[@"$t"];
            
            switch ([col integerValue]) {
                case 2:
                {
                    rowDict[@"text"] = val;
                    break;
                }
                case 3:
                {
                    rowDict[@"value"] = val;
                    break;
                }
                case 4:
                {
                    rowDict[@"lvl"] = val;
                    break;
                }
                case 5:
                {
                    rowDict[@"unit"] = val;
                    break;
                }
                default:
                    break;
            }
            
            [rows setObject: rowDict forKey: row];
        }
    }];
    
    NSManagedObjectContext* context = _stack.mainQueueManagedObjectContext;
    for(NSDictionary* row in [rows allValues]) {
        Question* question = [Question insertInManagedObjectContext: context];
        question.text = row[@"text"];
        question.answer = @([row[@"value"] integerValue]);
        question.unit = row[@"unit"];
        
        NSFetchRequest* lvlRequest = [NSFetchRequest fetchRequestWithEntityName: @"Level"];
        [lvlRequest setPredicate: [NSPredicate predicateWithFormat: @"identifier = %@", row[@"lvl"]]];
        [lvlRequest setFetchLimit: 1];
        
        Level* lvl = [[context executeFetchRequest: lvlRequest error: nil] lastObject];
        if( !lvl ) {
            lvl = [Level insertInManagedObjectContext: context];
            lvl.identifier = @([row[@"lvl"] integerValue]);
        }
        
        question.level = lvl;
    }
    
    [_stack save];
    
    NSLog(@"Saved");
    
    return YES;
}

@end

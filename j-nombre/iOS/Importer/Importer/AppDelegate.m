//
//  AppDelegate.m
//  Importer
//
//  Created by Paul de Lange on 28/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "AppDelegate.h"

#import "JSONParser.h"

#import "Level.h"
#import "Question.h"
#import "CoreDataStack.h"

@implementation AppDelegate

- (BOOL) startParsing: (__autoreleasing NSError**) error spreadsheet: (NSData*) _spreadsheet stack: (CoreDataStack*) _stack {
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
                case 1:
                {
                    rowDict[@"id"] = row;
                    break;
                }
                case 2:
                {
                    rowDict[@"id"] = row;
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
                    rowDict[@"min"] = val;
                    break;
                }
                case 5:
                {
                    rowDict[@"max"] = val;
                    break;
                }
                case 6:
                {
                    rowDict[@"lvl"] = val;
                    break;
                }
                case 7:
                {
                    rowDict[@"unit"] = val;
                    break;
                }
                case 8:
                {
                    rowDict[@"format"] = val;
                    break;
                }
                default:
                    break;
            }
            
            [rows setObject: rowDict forKey: row];
        }
    }];
    
    NSManagedObjectContext* context = _stack.mainQueueManagedObjectContext;
    for(NSDictionary* row in [[rows allValues] reverseObjectEnumerator]) {
        Question* question = [Question insertInManagedObjectContext: context];
        question.text = row[@"text"];
        question.answer = @([row[@"value"] integerValue]);
        question.unit = row[@"unit"];
        question.identifier = @([row[@"id"] integerValue]);
        question.formats = @([row[@"format"] integerValue]);
        question.minValue = @([row[@"min"] integerValue]);
        question.maxValue = @([row[@"max"] integerValue]);
        
        NSFetchRequest* lvlRequest = [NSFetchRequest fetchRequestWithEntityName: @"Level"];
        [lvlRequest setPredicate: [NSPredicate predicateWithFormat: @"identifier = %d", [row[@"lvl"] integerValue]]];
        [lvlRequest setFetchLimit: 1];
        
        Level* lvl = [[context executeFetchRequest: lvlRequest error: nil] lastObject];
        if( !lvl ) {
            lvl = [Level insertInManagedObjectContext: context];
            lvl.identifier = @([row[@"lvl"] integerValue]);
            NSLog(@"Create lvl %@", lvl.identifier);
        }
        
        question.level = lvl;
        [_stack save];
    }
    
    [_stack save];
    
    NSLog(@"Saved");
    
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    NSURL* worksheetsURL = [NSURL URLWithString: @"http://spreadsheets.google.com/feeds/worksheets/1W23EYy-0L6dzXeHrmFch5ZEUsMH_-IZSlIF_Wxh3LkM/public/basic?alt=json"];
    NSData* worksheetsData = [NSData dataWithContentsOfURL: worksheetsURL];
    NSDictionary* worksheets = [NSJSONSerialization JSONObjectWithData: worksheetsData
                                                               options: 0
                                                                 error: nil];
    
    NSDictionary* worksheetFeed = worksheets[@"feed"];
    NSArray* worksheetEntries = worksheetFeed[@"entry"];
    
    CoreDataStack* stack = [CoreDataStack initAppDomain: nil userDomain: @"Data"];
    
    for(NSDictionary* entry in worksheetEntries) {
        NSDictionary* content = entry[@"content"];
        NSString* lang = content[@"$t"];
        
        if( [[NSLocale currentLocale] displayNameForKey: NSLocaleLanguageCode value: lang] ) {
            
            NSLog(@"Starting: %@", lang);
            NSArray* links = entry[@"link"];
            NSDictionary* cellsLink = links[1];
            
            NSString* cellsPath = [cellsLink[@"href"] stringByReplacingOccurrencesOfString: @"basic" withString: @"values"];
            
            NSString* cellsJSONPath = [cellsPath stringByAppendingString: @"?alt=json"];
            
            NSLog(@"URL: %@", cellsJSONPath);
            
            NSURL* cellsURL = [NSURL URLWithString: cellsJSONPath];
            
            NSData* cellData = [NSData dataWithContentsOfURL: cellsURL];
            
            stack.dataLanguage = lang;
            [self startParsing: nil spreadsheet: cellData stack: stack];
        }
    }
}

@end

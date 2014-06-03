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
        _stack = [CoreDataStack initAppDomain: nil userDomain: @"Data"];
    }
    
    return self;
}

@end

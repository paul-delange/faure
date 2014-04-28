//
//  JSONParser.h
//  Importer
//
//  Created by Paul de Lange on 28/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONParser : NSObject

- (instancetype) initWithGoogleSpreadsheetData: (NSData*) spreadsheet;

- (BOOL) startParsing: (__autoreleasing NSError**) error;

@end

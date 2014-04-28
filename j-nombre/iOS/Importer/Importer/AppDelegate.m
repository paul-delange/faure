//
//  AppDelegate.m
//  Importer
//
//  Created by Paul de Lange on 28/04/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "AppDelegate.h"

#import "JSONParser.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString* docPath = @"https://spreadsheets.google.com/feeds/cells/1W23EYy-0L6dzXeHrmFch5ZEUsMH_-IZSlIF_Wxh3LkM/od6/public/values?alt=json";
    NSURL* url = [NSURL URLWithString: docPath];
    NSURLRequest* request = [NSURLRequest requestWithURL: url];
    
    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if( connectionError ) {
                                   NSLog(@"Network: %@", connectionError);
                               }
                               else {
                                   JSONParser* parse = [[JSONParser alloc] initWithGoogleSpreadsheetData: data];
                                   NSError* parseError;
                                   
                                   if( [parse startParsing: &parseError] ) {
                                       
                                   }
                                   else {
                                       NSLog(@"Parse: %@", parseError);
                                   }
                               }
                           }];
}

@end

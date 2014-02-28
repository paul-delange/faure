//
//  AppDelegate.h
//  Importer
//
//  Created by Paul De Lange on 28/02/14.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

- (IBAction) generatorPushed:(id)sender;

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *statusLabel;
@property (weak) IBOutlet NSProgressIndicator*   progressIndicator;

@end

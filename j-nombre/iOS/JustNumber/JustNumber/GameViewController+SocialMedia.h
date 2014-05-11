//
//  GameViewController+SocialMedia.h
//  JustNumber
//
//  Created by Paul de Lange on 10/05/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

@import Social;

@class Question;

@interface UIViewController (SocialMedia)

- (void) shareAnswer: (Question*) question on: (NSString*) serviceType completion: (void (^)(NSError* error))completion;

- (void) shareQuestion: (Question*) question on: (NSString*) serviceType completion: (void (^)(NSError* error))completion;

- (void) followUsOn: (NSString*) serviceType completion: (void (^)(NSError* error))completion;

@end

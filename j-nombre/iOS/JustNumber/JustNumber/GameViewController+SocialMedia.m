//
//  GameViewController+SocialMedia.m
//  JustNumber
//
//  Created by Paul de Lange on 10/05/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "GameViewController+SocialMedia.h"

@implementation UIViewController (SocialMedia)

- (void) shareQuestion: (Question*) question on:(NSString *)serviceType completion:(void (^)(NSError *))completion {
    NSParameterAssert([serviceType isEqualToString: SLServiceTypeFacebook] || [serviceType isEqualToString: SLServiceTypeTwitter]);
    NSParameterAssert(completion);
    completion(nil);
}

- (void) shareAnswer: (Question*) question on:(NSString *)serviceType completion:(void (^)(NSError *))completion {
    NSParameterAssert([serviceType isEqualToString: SLServiceTypeFacebook] || [serviceType isEqualToString: SLServiceTypeTwitter]);
    NSParameterAssert(completion);
    completion(nil);
}

- (void) followUsOn:(NSString *)serviceType completion:(void (^)(NSError *))completion {
    NSParameterAssert([serviceType isEqualToString: SLServiceTypeFacebook] || [serviceType isEqualToString: SLServiceTypeTwitter]);
    NSParameterAssert(completion);
    
    completion(nil);
}

@end

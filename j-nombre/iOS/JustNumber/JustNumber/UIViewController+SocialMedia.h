//
//  UIViewController+SocialMedia.h
//  JustNumber
//
//  Created by Paul de Lange on 26/06/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Social/Social.h>

@interface UIViewController (SocialMedia)

- (void) followUsOn:(NSString *)serviceType completion:(void (^)(NSError *))completion;

@end

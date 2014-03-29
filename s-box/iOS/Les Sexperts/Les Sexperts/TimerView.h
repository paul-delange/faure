//
//  TimerView.h
//  Les Sexperts
//
//  Created by Paul de Lange on 30/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimerView : UIView

@property (assign, nonatomic) NSTimeInterval   timeRemaining;
@property (assign, nonatomic) NSTimeInterval   totalTime;

@end

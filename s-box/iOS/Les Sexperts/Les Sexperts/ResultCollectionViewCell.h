//
//  ResultCollectionViewCell.h
//  Les Sexperts
//
//  Created by Paul de Lange on 6/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailTextLabel;

@property (assign, nonatomic) BOOL isCorrect;

@end

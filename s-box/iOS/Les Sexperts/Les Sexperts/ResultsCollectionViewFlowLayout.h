//
//  ResultsCollectionViewFlowLayout.h
//  Les Sexperts
//
//  Created by Paul de Lange on 6/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, kResultCollectionViewCellPosition) {
    kResultCollectionViewCellPositionCenter = 0,
    kResultCollectionViewCellPositionRight
};

@interface ResultsCollectionViewFlowLayout : UICollectionViewFlowLayout

- (void) setPosition: (kResultCollectionViewCellPosition) position atIndexPath: (NSIndexPath*) indexPath animated: (BOOL) animated;

@end

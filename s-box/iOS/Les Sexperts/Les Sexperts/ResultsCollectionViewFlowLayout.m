//
//  ResultsCollectionViewFlowLayout.m
//  Les Sexperts
//
//  Created by Paul de Lange on 6/03/2014.
//  Copyright (c) 2014 Gilmert Bentley. All rights reserved.
//

#import "ResultsCollectionViewFlowLayout.h"

@interface ResultsCollectionViewFlowLayout ()

@property (copy) NSArray* positionsArray;

@end

@implementation ResultsCollectionViewFlowLayout

- (void) setPosition: (kResultCollectionViewCellPosition) position atIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    NSMutableArray* mutable = [self.positionsArray mutableCopy];
    [mutable replaceObjectAtIndex: indexPath.row withObject: @(position)];
    self.positionsArray = mutable;
    
   /// NSLog(@"Set %lu for index: %ld", position, (long)indexPath.item);
    
    if( animated ) {
        self.collectionView.viewForBaselineLayout.layer.speed = 0.5;
        
        [self.collectionView performBatchUpdates:^{
            [self invalidateLayout];
        } completion:^(BOOL finished) {
            //NSLog(@"Complete: %@", [self.collectionView cellForItemAtIndexPath: indexPath]);
        }];
    }
    else {
        [self invalidateLayout];
    }
}

#pragma mark - UICollectionViewFlowLayout
- (void) prepareLayout {
    if( !self.positionsArray ) {
        NSMutableArray* positions = [NSMutableArray new];
        for(NSUInteger i=0;i<[self.collectionView.dataSource collectionView: self.collectionView numberOfItemsInSection: 0];i++) {
            [positions addObject: @(kResultCollectionViewCellPositionRight)];
        }
        
        self.positionsArray = positions;
    }
}

- (NSArray*) layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray* attributes = [super layoutAttributesForElementsInRect: rect];
    for(UICollectionViewLayoutAttributes* attrib in attributes) {
        NSIndexPath* indexPath = attrib.indexPath;
        kResultCollectionViewCellPosition position = [self.positionsArray[indexPath.row] unsignedIntegerValue];
        
        switch (position) {
            case kResultCollectionViewCellPositionCenter:
                attrib.transform = CGAffineTransformIdentity;
                attrib.alpha = 1;
                break;
            case kResultCollectionViewCellPositionRight:
                attrib.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.collectionView.bounds)/2.f, 0);
                attrib.alpha = 0;
                break;
            default:
                break;
        }
    }
    
    //NSLog(@"%@ Attributes: %@", NSStringFromCGRect(rect), attributes);
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* attrib = [super layoutAttributesForItemAtIndexPath: indexPath];
    kResultCollectionViewCellPosition position = [self.positionsArray[indexPath.row] unsignedIntegerValue];
    
    switch (position) {
        case kResultCollectionViewCellPositionCenter:
            attrib.transform = CGAffineTransformIdentity;
            attrib.alpha = 1;
            break;
        case kResultCollectionViewCellPositionRight:
            attrib.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.collectionView.bounds)/2.f, 0);
            attrib.alpha = 0;
            break;
        default:
            break;
    }
    
    return attrib;
}

@end

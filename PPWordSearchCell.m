//
//  PPWordSearchCell.m
//  WordSearch
//
//  Created by Iain Frame on 02/06/2015.
//  Copyright (c) 2016 PointPixel Ltd. All rights reserved.
//

#import "PPWordSearchCell.h"

@implementation PPWordSearchCell

// MARK: Initialisation

- (instancetype) init {
    self.col = 0;
    self.row = 0;
    self.occupied = NO;
    self.character = @" ";
    self.prevChar = @"";
    return self;
}

// MARK: Helpers

- (CGPoint) indexPositionFor: (Orientation) direction {
    CGPoint indexPos;
    
    if (direction == Horizontal) {
        indexPos = CGPointMake(self.col, -1.0f);
    } else if (direction == Vertical) {
        indexPos = CGPointMake(1.0f, self.row);
    } else {
        indexPos = CGPointMake(self.col, self.row);
    }
    
    return indexPos;
}

@end

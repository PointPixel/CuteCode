//
//  PPWordSearchCell.h
//  WordSearch
//
//  Created by Iain Frame on 02/06/2015.
//  Copyright (c) 2015 PointPixel Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, Orientation) {
  Horizontal,
  Vertical,
  DiagonalRight,
  DiagonalLeft
};

@interface PPWordSearchCell : NSObject

@property (nonatomic) BOOL occupied;
@property (nonatomic) NSInteger row;
@property (nonatomic) NSInteger col;
@property (nonatomic) NSString* character;
@property (nonatomic) NSString* prevChar;

- (CGPoint) indexPositionFor: (Orientation) direction;

@end

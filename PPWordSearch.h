//
//  PPWordSearch.h
//  WordSearch
//
//  Created by Iain Frame on 02/06/2015.
//  Copyright (c) 2015 PointPixel Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPWordSearch : NSObject

@property (nonatomic) NSInteger max_rows;
@property (nonatomic) NSInteger max_cols;
@property (nonatomic) NSInteger randomCount;
@property (nonatomic, strong) NSMutableArray* placedWords;

- (instancetype) initWithRows:(NSInteger) rows andCols: (NSInteger) cols withRandomCount: (NSInteger) count maxAttempts:(NSInteger) maxTrys maximumWords:(NSInteger) maxWords;
- (NSArray*) generatePuzzleStringWithWords: (NSArray*) words;

@end

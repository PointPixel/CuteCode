//
//  PPWordSearch.m
//  WordSearch
//
//  Created by Iain Frame on 02/06/2015.
//  Copyright (c) 2015 PointPixel Ltd. All rights reserved.
//

#import "PPWordSearch.h"
#import "PPWordSearchCell.h"
#import "NSString+PPExtras.h"

@interface PPWordSearch ()

@property (nonatomic, strong) NSMutableArray* attemptedCells;
@property (nonatomic, strong) NSMutableArray* cellGrid;
@property (nonatomic) NSInteger maxPlacementAttempts;
@property (nonatomic, strong) NSMutableArray* scrambledWords;
@property (nonatomic) NSInteger maxWords;

@end

@implementation PPWordSearch

// MARK: Initialisation

- (instancetype) initWithRows:(NSInteger) rows andCols: (NSInteger) cols withRandomCount: (NSInteger) count maxAttempts:(NSInteger) maxTrys maximumWords:(NSInteger) maxWords  {
    self.max_cols = cols;
    self.max_rows = rows;
    self.randomCount = count;
    self.maxPlacementAttempts = maxTrys;
    self.maxWords = maxWords;
    self.attemptedCells = [[NSMutableArray alloc] init];
    self.scrambledWords = [[NSMutableArray alloc] init];
    self.placedWords = [[NSMutableArray alloc] init];
    self.cellGrid = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            PPWordSearchCell *cell = [[PPWordSearchCell alloc] init];
            cell.row = i + 1;
            cell.col = j + 1;
            [self.cellGrid addObject: cell];
        }
    }
    return self;
}

// MARK: API

/// Public api that creates the arrays of letters that make up the word search
- (NSArray*) generatePuzzleStringWithWords: (NSArray*) words {
    
    NSInteger charactersSoFar = 0;
    NSInteger count = 0;
    NSInteger wordCount = 0;
    Orientation direction = Horizontal;
    
    for (NSString* w in words) {
        if (wordCount > self.maxWords - 1) break;
        NSInteger maxLength = [self maxCharsFor:direction];
        
        if (w.length <= maxLength) {
            NSString *lw = [w lowercaseString];
            if (count % 2) {
                lw = [lw reverseString:lw];
            }
            count++;
            
            lw = [lw stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            PPWordSearchCell *placementCell = [self getPlacementCellFor:direction withWord:lw withinMaxLength:maxLength];
            
            if (charactersSoFar + self.randomCount >= (self.max_rows * self.max_cols)) {
                break;
            } else if (!placementCell) {
                continue;
            } else {
                
                NSInteger attemptedCount = 0;
                NSInteger i = 0;
                [self resetAttemptedCells:NO];
                
                while ((attemptedCount <= self.maxPlacementAttempts) && (i < lw.length)) {
                    
                    for (i = 0; i < lw.length; i++) {
                        NSRange rng = NSMakeRange(i, 1);
                        NSString *currentCharacter = [lw substringWithRange:rng];
                        
                        PPWordSearchCell *gridCell = [self getGridCell:placementCell];
                        
                        if (!gridCell.occupied) {
                            gridCell.character = currentCharacter;
                            gridCell.occupied = YES;
                            [self.attemptedCells addObject:gridCell];
                            placementCell = [self advanceCell:placementCell forDirection:direction];
                        } else {
                            if ([gridCell.character isEqualToString:currentCharacter]) {
                                gridCell.prevChar = gridCell.character;
                                gridCell.character = currentCharacter;
                                [self.attemptedCells addObject:gridCell];
                                placementCell = [self advanceCell:placementCell forDirection:direction];
                            } else {
                                //TODO : This is used to indicate that word cannpt be placed
                                //currently works on the premise that all words could be place
                                //now needs to handle it properly.
                                attemptedCount++;
                                [self resetAttemptedCells: YES];
                                direction = [self nextOrientationFrom:direction];
                                placementCell = [self getPlacementCellFor:direction withWord:lw withinMaxLength:maxLength];
                                if (!placementCell) {
                                    attemptedCount = self.maxPlacementAttempts + 1;
                                }
                                break;
                            }
                        }
                    }
                    if (i == lw.length) {
                        [self.placedWords addObject:[w lowercaseString]];
                        charactersSoFar += lw.length;
                        wordCount++;
                    }
                }
                direction = [self nextOrientationFrom:direction];
            }
        }
    }
    
    NSString *wordSearch = @"";
    for (int i = 0; i < self.max_rows; i++) {
        for (int j = 0; j < self.max_cols; j++) {
            
            PPWordSearchCell *testCell = self.cellGrid[ (i * self.max_cols) + j ];
            
            NSString *alphabet = @"abcdefghijklmnopqrstuvwxyz";
            NSInteger pos = rand() % 26;
            NSRange rng = NSMakeRange(pos, 1);
            NSString *rngChr = [alphabet substringWithRange:rng];
            if ([testCell.character isEqualToString:@" "]) testCell.character = rngChr;
            wordSearch = [wordSearch stringByAppendingString:testCell.character];
            if ((j + 1) == self.max_cols) {
                [self.scrambledWords addObject:wordSearch];
                wordSearch = @"";
            }
        }
    }
    return self.scrambledWords;
}

// MARK: Helper

/// Check if the word can be placed in any suite of cells
/// - Makes multiple attempts to place a word in a suite of cells
/// - After the max attempts returns nil
/// - If successful will return the start cell where the word should be placed from
- (PPWordSearchCell*) getPlacementCellFor: (Orientation) direction withWord:(NSString*)word withinMaxLength: (NSInteger) maxLength {
    BOOL wordWillFit = NO;
    PPWordSearchCell *placementCell;
    NSInteger attempts = 0;
    
    while (!wordWillFit && (attempts < self.maxPlacementAttempts)) {
        attempts++;
        placementCell = [self getCellForOrientation:direction];
        
        CGPoint placementIndex = [placementCell indexPositionFor:direction];
        switch (direction) {
            case Horizontal:
                wordWillFit = placementIndex.x + word.length - 1 <= maxLength;
                break;
            case Vertical:
                wordWillFit = placementIndex.y + word.length - 1 <= maxLength;
                break;
            case DiagonalRight:
                wordWillFit = MAX(placementIndex.x, placementIndex.y) + word.length <= maxLength;
                break;
            case DiagonalLeft: {
                
                wordWillFit = placementIndex.x - word.length > 0;
                
                if (wordWillFit)
                {
                    wordWillFit = (placementIndex.y + word.length - 1) <= maxLength ? YES : NO;
                    
                }
            }
                break;
            default:
                break;
        }
    }
    
    if (!wordWillFit) placementCell = nil;
    return placementCell;
}

/// Return the next orientation to try
/// - When a word is being placed, try placing it in different directions
/// - But use the following order to check
- (Orientation) nextOrientationFrom: (Orientation) direction {
    Orientation newDirection = Vertical;
    
    if (direction == Horizontal) {
        newDirection = Vertical;
    } else if (direction == Vertical) {
        newDirection = DiagonalRight;
    } else if (direction == DiagonalRight) {
        newDirection = DiagonalLeft;
    } else {
        newDirection = Horizontal;
    }
    
    return newDirection;
}

/// Returns the maximum letters in a particular direction
/// - For non square word searches
- (NSInteger) maxCharsFor: (Orientation) direction {
    NSInteger maxLength = 0;
    switch (direction) {
        case Horizontal:
            maxLength = self.max_cols;
            break;
        case Vertical:
            maxLength = self.max_rows;
            break;
        case DiagonalRight:
            maxLength = self.max_cols;
            break;
        case DiagonalLeft:
            maxLength = self.max_cols;
            break;
        default:
            break;
    }
    return maxLength;
}


/// Determine the next adjacent cell based on direction
-(PPWordSearchCell*) advanceCell: (PPWordSearchCell*)cell forDirection: (Orientation) direction {
    if (direction == Horizontal)
        cell.col++;
    else if (direction == Vertical)
        cell.row++;
    else if (direction == DiagonalRight){
        cell.row++;
        cell.col++;
    } else {
        cell.row++;
        cell.col--;
    }
    return cell;
}

/// On a new search clear out previous results
- (void) resetAttemptedCells:(BOOL) onGrid  {
    if (onGrid) {
        for (PPWordSearchCell *attemptedCell in self.attemptedCells) {
            PPWordSearchCell *gridCell = [self getGridCell:attemptedCell];
            if (gridCell.prevChar.length == 0) {
                gridCell.character = @" ";
                gridCell.occupied = NO;
            } else {
                gridCell.character = gridCell.prevChar;
                gridCell.prevChar = @"";
                gridCell.occupied = YES;
            }
        }
    }
    self.attemptedCells = nil;
    self.attemptedCells = [[NSMutableArray alloc] init];
}

/// Determine the cell grid position from its location in linked list
- (PPWordSearchCell*) getGridCell: (PPWordSearchCell*) placementCell {
  NSInteger absoluteCellPos = (((placementCell.row - 1) * self.max_cols) + placementCell.col) - 1;
  
  return self.cellGrid[absoluteCellPos];
}

/// Get a random cell to start word placement from
/// - This engine works by randomly picking a spot
/// - Probably not the most efficient way, but good enough for this app
- (PPWordSearchCell*) getCellForOrientation: (Orientation) orientation {
    NSInteger proposedCellPos = rand() % (((self.max_rows) * (self.max_cols)));

    CGPoint rowCol = [self calculateCellRowCol:proposedCellPos];

    PPWordSearchCell *cell = [[PPWordSearchCell alloc] init];

    cell.row = rowCol.y;
    cell.col = rowCol.x;
    cell.occupied = NO;
    return cell;
}

/// Based on the overall array index, determine the row/col equivalent
- (CGPoint) calculateCellRowCol: (NSInteger) pos {

    NSInteger col = pos % self.max_rows;

    col = col == 0 ? self.max_cols : col;

    NSInteger row = ((pos - 1) / self.max_rows) + 1;

    return CGPointMake(col, row);
}

@end

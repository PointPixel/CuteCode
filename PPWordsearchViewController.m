//
//  PPWordsearchContentViewController.m
//  WordSearch
//
//  Created by Iain Frame on 02/06/2015.
//  Copyright (c) 2016 PointPixel Ltd. All rights reserved.
//

#import "PPWordsearchViewController.h"
#import "PPWordSearch.h"
#import <AudioToolbox/AudioToolbox.h>

@interface PPWordsearchViewController ()
@property (nonatomic, weak) IBOutlet UIView *grid;
@property (nonatomic, weak) IBOutlet UITextView *words;
@property (nonatomic, weak) IBOutlet UISegmentedControl *difficultySelector;
@property (nonatomic, strong) NSMutableArray *wordList;
@property (nonatomic, strong) UIView *selector;
@property (nonatomic) CGPoint startCentre;
@property (nonatomic) NSInteger prevDifficulty;
@property (nonatomic) CGFloat cols;
@property (nonatomic) CGFloat rows;
@property (nonatomic) NSString *formedWord;
@property (nonatomic) NSInteger prevCellCount;
@property (nonatomic) NSMutableArray *foundWords;
@property (nonatomic) CGPoint snapOffset;
@property (nonatomic) CGPoint originalSelectorCentre;
@property (nonatomic) NSMutableArray *prevCells;
@property (nonatomic) CGFloat cellSize;

@property (nonatomic) SystemSoundID tickSystemSound;
@property (nonatomic) SystemSoundID popSystemSound;
@property (nonatomic) SystemSoundID pingSystemSound;

@property (nonatomic) NSDictionary *wordsDictionary;

@end

@implementation PPWordsearchViewController

// MARK: Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.foundWords = [[NSMutableArray alloc] init];

    self.prevDifficulty = -1;

    self.cols = 8;
    self.rows = 8;

    self.formedWord = @"";
    self.prevCellCount = -1;
    self.snapOffset = CGPointZero;
    self.cellSize = 28.0f;
    self.prevCells = [[NSMutableArray alloc] init];

    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"ping" ofType:@"mp3"];
    NSURL *soundUrl = [NSURL fileURLWithPath:soundPath];
    SystemSoundID pingSound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundUrl,&pingSound);
    self.pingSystemSound = pingSound;

    soundPath = [[NSBundle mainBundle] pathForResource:@"pop" ofType:@"mp3"];
    soundUrl = [NSURL fileURLWithPath:soundPath];
    SystemSoundID popSound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundUrl,&popSound);
    self.popSystemSound = popSound;

    soundPath = [[NSBundle mainBundle] pathForResource:@"tick" ofType:@"mp3"];
    soundUrl = [NSURL fileURLWithPath:soundPath];
    SystemSoundID tickSound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundUrl,&tickSound);
    self.tickSystemSound = tickSound;

    NSString *path = [NSBundle.mainBundle pathForResource:@"Words" ofType:@"plist"];
    self.wordsDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
}


- (void)viewDidAppear:(BOOL)animated {
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    recognizer.minimumPressDuration = 0;
    [self.grid addGestureRecognizer:recognizer];

    [self difficultyChanged: self.difficultySelector];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// MARK: API

/// Creat the word search
/// - Calling this method starts the sequence of activities that result in a word search
- (void) createWordSearch {
    UILabel *cell;

    self.cellSize = self.grid.bounds.size.width / self.cols;

    CGFloat fontSize = 22.0f;

    if (self.cols == 8) fontSize = 24.0f;

    UIFont *cellFont = [UIFont systemFontOfSize:fontSize];

    NSArray *puzzleWords = [self generatePuzzleForRows:self.rows andCols:self.cols];
    NSString* scrambledWord;

    NSInteger count = 0;

    for (int i = 0; i < self.rows; i++) {

        scrambledWord = puzzleWords[i];

        for (int j = 0; j < self.cols; j++) {
            CGRect f = CGRectMake(j * self.cellSize, i * self.cellSize, self.cellSize, self.cellSize);
            cell = [[UILabel alloc] initWithFrame:f];
            cell.userInteractionEnabled = YES;
            cell.font = cellFont;
            cell.textAlignment = NSTextAlignmentCenter;
            cell.tag = count++;
            NSString *cellChar = [scrambledWord substringWithRange:NSMakeRange(j, 1)];

            [cell setText:cellChar];

            [self.grid addSubview:cell];
          
        }
    }

    [self renderSearchWords];

}

/// Clears the word search
/// - Removes the cross word UI elements
/// - Clears out the data structures
- (void) clearWordSearch {
    for (UIView *v in self.grid.subviews) {
        if ([v isKindOfClass:[UILabel class]])
            [v removeFromSuperview];
        if (v.tag == -99)
            [v removeFromSuperview];
    }
    [self.foundWords removeAllObjects];
    self.words.text = @"";
}

/// Presents the words to be found
/// - Lists the words in text view
/// - Highlights the words when they've been found
- (void) renderSearchWords {
    NSMutableAttributedString *wordString = [[NSMutableAttributedString alloc] initWithString:@""];
    
    for (NSString *str in self.wordList) {
        
        NSMutableAttributedString *attrStr;
        NSString *tempStr = @"";
        BOOL foundWord = NO;
        
        for (NSString *s in self.foundWords) {
            NSString *parsedWord = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([s isEqualToString:parsedWord]) {
                tempStr = [str stringByAppendingString:@"\n"];
                attrStr = [[NSMutableAttributedString alloc] initWithString:tempStr
                                                                 attributes:@{NSStrikethroughStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleThick], NSForegroundColorAttributeName : [UIColor greenColor],
                                                                              NSFontAttributeName :[UIFont boldSystemFontOfSize:26]}];
                foundWord = YES;
                break;
            }
        }
        
        if (!foundWord) {
            tempStr = [str stringByAppendingString:@"\n"];
            attrStr = [[NSMutableAttributedString alloc] initWithString:tempStr
                                                             attributes:@{NSForegroundColorAttributeName : [UIColor brownColor],
                                                                          NSFontAttributeName :[UIFont boldSystemFontOfSize:26]}];
        }
        
        [wordString appendAttributedString:attrStr];
    }
    
    self.words.attributedText = [[NSAttributedString alloc] initWithString:@""];
    self.words.attributedText = wordString;
}

/// Generates the rows and columns
/// - Builds the rows of the puzzle
/// - Provides the words that were successfully placed in the grid
- (NSArray*) generatePuzzleForRows: (NSInteger) rows andCols: (NSInteger) cols {
    NSArray* arrayOfWords = [self.wordsDictionary objectForKey:@"Words"];

    self.wordList = [[NSMutableArray alloc] initWithArray: arrayOfWords[self.difficultySelector.selectedSegmentIndex]];

    PPWordSearch *puzzle = [[PPWordSearch alloc] initWithRows:rows andCols:cols withRandomCount:10 maxAttempts:8 maximumWords: 10];

    NSArray *puzzleRows = [puzzle generatePuzzleStringWithWords:self.wordList];

    self.wordList = puzzle.placedWords;

    return puzzleRows;
}

// MARK: Event handling

/// When the user updates the difficulty level
/// - Sent from the segmented control that persents
/// - Easy, intermediate and hard
- (IBAction)difficultyChanged:(id)sender {
    UISegmentedControl *difficulty = sender;
    
    if (self.prevDifficulty == difficulty.selectedSegmentIndex) return;
    
    NSInteger selectedSegment = difficulty.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        self.cols = 8;
        self.rows = 8;
    } else if (selectedSegment == 1){
        self.cols = 10;
        self.rows = 10;
    } else {
        self.cols = 12;
        self.rows = 12;
    }
    
    self.prevDifficulty = difficulty.selectedSegmentIndex;
    
    [self clearWordSearch];
    [self createWordSearch];
}

/// Handle long press gesture
/// - Handles the user swiping a selection on the word search
- (void)handleLongPress: (UIGestureRecognizer*) recognizer {
    //TODO: Refactor this monster method
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.startCentre = [recognizer locationInView:self.grid];
        
        for (UIView *v in self.grid.subviews) {
            if ([v isKindOfClass:[UILabel class]]) {
                if ((CGRectContainsPoint(v.frame, self.startCentre))) {
                    self.startCentre = v.center;
                }
            }
        }
        
        CGRect frame = CGRectMake(0, 0, 28.0f, 28.0f);
        self.selector = [[UIView alloc] initWithFrame:frame];
        self.selector.backgroundColor = [UIColor yellowColor];
        self.selector.layer.borderColor = [UIColor orangeColor].CGColor;
        self.selector.layer.borderWidth = 1.2f;
        self.selector.layer.cornerRadius = 16.0f;
        self.selector.layer.masksToBounds = YES;
        self.selector.alpha = 0.5f;
        self.selector.center =  self.startCentre;
        self.selector.tag = -99; //So that it can easily be removed when word search is cleared.
        [self.grid addSubview:self.selector];
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGFloat angled = 0.0f;
        CGPoint location = [recognizer locationInView:self.grid];
        
        if ((location.x >= 0.0f && location.x <= self.grid.bounds.size.width) &&
            (location.y >= 0.0f && location.y <= self.grid.bounds.size.height)) {
            
            CGFloat xDelta = location.x - self.startCentre.x;
            CGFloat yDelta = location.y - self.startCentre.y;
            
            CGFloat resolvedX = xDelta + self.startCentre.x;
            CGFloat resolvedY = yDelta + self.startCentre.y;
            
            if ((resolvedX >= 0.0f && resolvedX <= self.grid.bounds.size.width) &&
                (resolvedY >= 0.0f && resolvedY <= self.grid.bounds.size.height)) {
                
                CGFloat rotationAngle = atan2(yDelta, xDelta);
                
                NSInteger angle = rotationAngle * 57.2957795;
                
                NSInteger snappedAngle = 0;
                NSInteger maxCells = -1;
                
                CGFloat scaledAngle = labs(angle)/45.0f;
                
                if (scaledAngle < 0.5f) {
                    snappedAngle = 0;
                    angled = 1.0f;
                } else if (scaledAngle < 1.5f) {
                    snappedAngle = 45;
                    angled = 1.414f;
                } else if (scaledAngle < 2.5f) {
                    snappedAngle = 90;
                    angled = 1.0f;
                } else if (scaledAngle < 3.5f) {
                    snappedAngle = 135;
                    angled = 1.414f;
                } else {
                    snappedAngle = 180;
                    angled = 1.0f;
                }
                
                snappedAngle = angle < 0 ? -snappedAngle : snappedAngle;
                
                if (labs(snappedAngle) == 45 || labs(snappedAngle) == 135) {
                    maxCells = [self maximumCellsAt:self.startCentre forAngle:snappedAngle];
                }
                
                CGFloat hyp = sqrt(pow(xDelta, 2.0) + pow(yDelta, 2.0));
                NSInteger cellCount = (hyp / (self.cellSize * angled)) + angled;
                
                if (maxCells > 0) {
                    cellCount = cellCount > maxCells ? maxCells : cellCount;
                }
                
                self.selector.transform = CGAffineTransformIdentity;
                CGRect currentFrame = self.selector.frame;
                
                currentFrame.size.height = ((CGFloat)cellCount) * (self.cellSize * angled);
                
                self.selector.frame = currentFrame;
                self.selector.center = [self calculateSelectorCentre:snappedAngle forCellCount:cellCount withAngleFactor:angled];
                
                CGFloat controlledAngle = ((CGFloat)snappedAngle) * 0.0174532925f;
                self.selector.transform = CGAffineTransformMakeRotation(controlledAngle - M_PI_2);
                
                if (cellCount != self.prevCellCount) {
                    
                    self.formedWord = [self getWordStartingFromCell:self.startCentre forCellCount:cellCount inDirection:snappedAngle];
                    
                    self.prevCellCount = cellCount;
                    
                    if ([self checkFormedWord]) {
                        self.selector.backgroundColor = [UIColor orangeColor];
                        recognizer.enabled = NO;
                        AudioServicesPlaySystemSound(self.pingSystemSound);
                        if (self.foundWords.count == self.wordList.count) {
                            //TODO: Add alert to congratulate user
                        }
                    } else {
                        AudioServicesPlaySystemSound(self.tickSystemSound);
                    }
                }
            }
        }
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        if (self.selector.backgroundColor != [UIColor orangeColor]) {
            [self.selector removeFromSuperview];
            AudioServicesPlaySystemSound(self.popSystemSound);
        }
        [self.prevCells removeAllObjects];
        self.formedWord = @"";
        self.prevCellCount = -1;
        recognizer.enabled = YES;
    }

}

// MARK: Helpers

/// Find out where the current selector can't go past
/// - Determine how many cells are available from this location
/// - at the specified angle
- (NSInteger) maximumCellsAt: (CGPoint) location forAngle: (NSInteger) angle {
    CGFloat xDiff = 0.0f;
    CGFloat yDiff = 0.0f;
    
    switch (angle) {
        case 45:
            xDiff = self.grid.bounds.size.width - location.x;
            yDiff = self.grid.bounds.size.height - location.y;
            break;
        case 135:
            xDiff = location.x;
            yDiff = self.grid.bounds.size.height - location.y;
            break;
        case -45:
            xDiff = self.grid.bounds.size.width - location.x;
            yDiff = location.y;
            break;
        case -135:
            xDiff = location.x;
            yDiff = location.y;
            break;
        default:
            break;
    }
    
    NSInteger xCells = xDiff / self.cellSize;
    NSInteger yCells = yDiff / self.cellSize;
    
    return MIN(xCells, yCells) + 1;
}

/// Determine where the selector starts
/// - As part of the UI drawing routine find out where to start
/// - drawing the selection mechanism
- (CGPoint) calculateSelectorCentre: (NSInteger) angle forCellCount: (NSInteger) count withAngleFactor: (CGFloat) angleFactor {
    CGPoint newCentre = self.startCentre;
    CGFloat diagonalOffset = ((self.cellSize * angleFactor) / 7.0f) * (count - 1);
    CGFloat offset = (self.selector.bounds.size.height / 2.0f) - ((self.cellSize * angleFactor)/2.0f);
    switch (angle) {
        case 0:
            newCentre.x = newCentre.x + offset;
            break;
        case 45:
            newCentre.x = newCentre.x + offset - diagonalOffset;
            newCentre.y = newCentre.y + offset - diagonalOffset;
            break;
        case 90:
            newCentre.y = newCentre.y + offset;
            break;
        case 135:
            newCentre.x = newCentre.x - offset + diagonalOffset;
            newCentre.y = newCentre.y + offset - diagonalOffset;
            break;
        case 180:
            newCentre.x = newCentre.x - offset;
            break;
        case -45:
            newCentre.x = newCentre.x + offset - diagonalOffset;
            newCentre.y = newCentre.y - offset + diagonalOffset;
            break;
        case -90:
            newCentre.y = newCentre.y - offset;
            break;
        case -135:
            newCentre.x = newCentre.x - offset + diagonalOffset;
            newCentre.y = newCentre.y - offset + diagonalOffset;
            break;
        case -180:
            newCentre.x = newCentre.x - offset;
            break;
        default:
            break;
    }
    return newCentre;
}

/// Determine if the word has been found already
/// - If the word hasn't been found, check if its in the word list
- (BOOL) checkFormedWord {
    if ([self doesWord:self.formedWord existIn:self.wordList]) {
        
        if ([self.foundWords containsObject:self.formedWord]) {
            return NO;
        }
        
        self.selector.backgroundColor = [UIColor orangeColor];
        [self.foundWords addObject:self.formedWord];
        [self renderSearchWords];
        return YES;
    }
    return NO;
}

- (BOOL) doesWord: (NSString*) wordToCheck existIn: (NSMutableArray*) wordsArray {
    
    for (NSString *w in wordsArray) {
        NSString *parsedWord = [w stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([parsedWord isEqualToString:wordToCheck]) {
            return YES;
        }
    }
    return NO;
}

/// Calculate the accumulated letters from a users selection
/// - Append each letter and return the result
- (NSString*) getWordStartingFromCell: (CGPoint) startCell forCellCount: (NSInteger) cellCount inDirection: (NSInteger) angle {
    NSString *word = @"";
    
    CGFloat xDelta = 0.0f;
    CGFloat yDelta = 0.0f;
    
    switch (angle) {
        case 0:
            xDelta = self.cellSize;
            yDelta = 0.0f;
            break;
        case 45:
            xDelta = self.cellSize;
            yDelta = self.cellSize;
            break;
        case 90:
            xDelta = 0.0f;
            yDelta = self.cellSize;
            break;
        case 135:
            xDelta = -self.cellSize;
            yDelta = self.cellSize;
            break;
        case 180:
            xDelta = -self.cellSize;
            yDelta = 0.0f;
            break;
        case -45:
            xDelta = self.cellSize;
            yDelta = -self.cellSize;
            break;
        case -90:
            xDelta = 0.0f;
            yDelta = -self.cellSize;
            break;
        case -135:
            xDelta = -self.cellSize;
            yDelta = -self.cellSize;
            break;
        case -180:
            xDelta = -self.cellSize;
            yDelta = 0.0f;
            break;
        default:
            break;
  }
  
  word = [self characterInCell:startCell];
  for (NSInteger cell = 1; cell < cellCount; cell++){
    CGPoint checkCell = CGPointMake(startCell.x + (xDelta * cell), startCell.y + (yDelta * cell));
    NSString *charAtCell = [self characterInCell:checkCell];
    word = [word stringByAppendingString:charAtCell];
  }
  return word;
}

/// Gets the character from a cell user swiped over
/// - When the user swipes a selection is created that
/// - has the characters swiped over added to it
- (NSString*) characterInCell: (CGPoint) cellPoint {
    for (UIView *v in self.grid.subviews) {
        if ([v isKindOfClass:[UILabel class]] && v.tag != -99) {
            if (CGRectContainsPoint(v.frame, cellPoint)) {
                UILabel *cell = (UILabel*)v;
                return cell.text;
            }
        }
    }
    return @"";
}

@end

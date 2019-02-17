//
//  PPInfiniteScrollView.m
//  PPInfiniteScrollView
//
//  Created by Iain Frame on 18/04/2015.
//  Copyright (c) 2015 Point Pixel Ltd. All rights reserved.
//

#import "PPInfiniteScrollView.h"
#import "UIImage+Identifier.h"

@interface PPInfiniteScrollView ()

@property (nonatomic, strong) NSArray *originalItems;
@property (nonatomic, strong) NSMutableArray *itemImages;
@property (nonatomic) NSInteger prevOffsetX;
@property (nonatomic) NSInteger layoutSubviewCallcount;
@property (nonatomic) NSInteger currentItemIndex;

@end

@implementation PPInfiniteScrollView

- (id) initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  return self;
}

- (void) populateWithArrayOfImages: (NSArray*) items {
  self.itemImages = [items mutableCopy];
  self.originalItems = [items copy];
  [self.itemImages insertObject:[items lastObject] atIndex:0];
  self.contentSize = CGSizeMake([self calculateContentSize], self.bounds.size.height);
  self.contentOffset = CGPointMake((self.contentSize.width - self.bounds.size.width)/2.0f, 0.0f);
  [self setDefaultDisplay];
}

- (CGFloat) calculateContentSize {
  CGFloat contentWidth = 0.0f;
  for (UIImage *img in self.itemImages) {
    contentWidth += img.size.width;
  }
  return contentWidth;
}

- (void) setDefaultDisplay {
  self.prevOffsetX = 0;
  NSInteger middleIndex = self.itemImages.count / 2;
  self.centerItemName = ((UIImage*)[self.itemImages objectAtIndex:middleIndex]).identifyingName;
  self.prevItemName = ((UIImage*)[self.itemImages objectAtIndex:middleIndex - 1]).identifyingName;
  self.nextItemName = ((UIImage*)[self.itemImages objectAtIndex:middleIndex + 1]).identifyingName;
  self.currentItemIndex = middleIndex;
  [self displayItems];
}

- (NSString*) getNextItem: (NSString*) currentItem direction: (NSInteger) dir {
  NSString *nextItem;
  UIImage *img = nil;
  for (NSInteger i = 0; i < self.originalItems.count; i++) {
    img = [self.originalItems objectAtIndex:i];
    if ([img.identifyingName isEqualToString:currentItem]) {
      NSInteger nextItemIndex = i + dir;
      
      if (nextItemIndex >= (NSInteger)self.originalItems.count) {
        nextItemIndex = 0;
      }
      if (nextItemIndex < 0) {
        nextItemIndex = self.originalItems.count - 1;
      }
      
      nextItem = ((UIImage*)[self.originalItems objectAtIndex:nextItemIndex]).identifyingName;
    }
  }
  return nextItem;
}

-(NSMutableArray*) recalculateDisplayArray: (NSInteger) direction {
  
  NSMutableArray* newDisplay = [[NSMutableArray alloc] initWithCapacity:self.itemImages.count];
  UIImage *overlapImage;
  
  if (direction < 0) {
    overlapImage = [UIImage imageWithIdentifier: [self getNextItem: ((UIImage*)[self.itemImages lastObject]).identifyingName direction: direction] fromBundle:[NSBundle mainBundle]];
    [newDisplay addObject:overlapImage];
    for (int i = 0; i < self.itemImages.count - 1; i++) {
      UIImage *img = (UIImage*)[self.itemImages objectAtIndex:i];
      [newDisplay addObject:img];
    }
  } else {
    overlapImage = [UIImage imageWithIdentifier: [self getNextItem: ((UIImage*)[self.itemImages firstObject]).identifyingName direction: direction] fromBundle:[NSBundle mainBundle]];
    for (int i = 1; i < self.itemImages.count; i++) {
      UIImage *img = (UIImage*)[self.itemImages objectAtIndex:i];
      [newDisplay addObject:img];
    }
    [newDisplay addObject:overlapImage];
  }
  
  return newDisplay;
}

- (void) displayItems {
  NSInteger i = 0;
  for (UIImage* img in self.itemImages) {
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(i * img.size.width,
                                                                    0,
                                                                    img.size.width,
                                                                    img.size.height)];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    iv.image = img;
    [self addSubview:iv];
    i++;
  }
}

- (void) repositionItems {
  NSInteger i = 0;
  for (UIImage* img in self.itemImages) {
    UIImageView *iv = self.subviews[i];
    iv.image = img;
    i++;
  }
}

- (void) determineCentreItem: (NSInteger) direction {
  CGFloat contentWidth = [self contentSize].width;
  CGFloat centerOffsetX = (contentWidth - [self bounds].size.width) / 2.0;
  for (UIView *v in self.subviews) {
    UIImageView *iv = (UIImageView*)v;
    if ([((NSString*)iv.image.identifyingName) length] > 0) {
      NSInteger ivC = iv.frame.origin.x + (iv.frame.size.width/2.0);
      NSInteger svC = centerOffsetX + ([self bounds].size.width/2.0);
      if (ivC == svC) {
        self.centerItemName = iv.image.identifyingName;
        [self.infiniteScrollViewDelegate newCurrentItem:self.centerItemName];
      }
    }
  }
}

- (void) calculateNextItemAndOpacity: (NSInteger) direction {
  if (self.delegate) {
    CGFloat offsetCentreX = (self.contentSize.width - self.bounds.size.width)/2.0f;
    self.nextItemName = [self getNextItem:self.centerItemName direction:direction];
    [self.infiniteScrollViewDelegate nextItemsOpacity:self.nextItemName opacity:fabs(offsetCentreX - self.contentOffset.x)/(self.contentSize.width/self.itemImages.count)];
  }
}

- (void) calculatePrevItemAndOpacity: (NSInteger) direction {
  if (self.delegate) {
    CGFloat offsetCentreX = (self.contentSize.width - self.bounds.size.width)/2.0f;
    self.prevItemName = [self getNextItem:self.centerItemName direction:(direction * -1)];
    [self.infiniteScrollViewDelegate prevItemsOpacity:self.prevItemName opacity:fabs(offsetCentreX - self.contentOffset.x)/(self.contentSize.width/self.itemImages.count)];
  }
}

- (void) recenterIfNecessary {
  CGPoint currentOffset = [self contentOffset];
  NSInteger absoluteOffsetX = (NSInteger)currentOffset.x;
  if (labs(absoluteOffsetX - self.prevOffsetX) >= 1l) {
    CGFloat contentWidth = [self contentSize].width;
    CGFloat centerOffsetX = (contentWidth - [self bounds].size.width) / 2.0;
    CGFloat distanceFromCentre = currentOffset.x - centerOffsetX;
    NSInteger direction = distanceFromCentre < 0.0 ? -1 : 1;
    if (fabs(distanceFromCentre) > (contentWidth / self.itemImages.count)) {
      self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
      NSMutableArray *oldArray = self.itemImages;
      self.itemImages = [self recalculateDisplayArray: direction];
      [oldArray removeAllObjects];
      [self repositionItems];
      [self determineCentreItem:direction];
    }
    [self calculateNextItemAndOpacity:direction];
    [self calculatePrevItemAndOpacity:direction];
    self.prevOffsetX = absoluteOffsetX;
  }
}

- (void) layoutSubviews {
  [super layoutSubviews];
  [self recenterIfNecessary];
}

@end

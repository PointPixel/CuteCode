//
//  PPInfiniteScrollView.h
//  PPInfiniteScrollView
//
//  Created by Iain Frame on 18/04/2015.
//  Copyright (c) 2015 Point Pixel Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PPInfiniteScrollViewDelegate<NSObject>

- (void)newCurrentItem:(NSString*)currentItem;
- (void)nextItemsOpacity:(NSString*)nextItem opacity: (CGFloat) newOpacity;
- (void)prevItemsOpacity:(NSString*)prevItem opacity: (CGFloat) newOpacity;

@end

@interface PPInfiniteScrollView : UIScrollView

@property (nonatomic, strong) NSString *prevItemName;
@property (nonatomic, strong) NSString *centerItemName;
@property (nonatomic, strong) NSString *nextItemName;

@property(nonatomic,assign) id<PPInfiniteScrollViewDelegate> infiniteScrollViewDelegate;

- (void) populateWithArrayOfImages: (NSArray*) items;

@end



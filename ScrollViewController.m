//
//  ViewController.m
//  InfiniteScrollView
//
//  Created by Iain Frame on 22/04/2015.
//  Copyright (c) 2015 Point Pixel Ltd. All rights reserved.
//

#import "ScrollViewController.h"
#import "UIImage+Identifier.h"

@interface ScrollViewController ()
@property (nonatomic, weak) IBOutlet PPInfiniteScrollView* scroller;
@property (nonatomic, weak) IBOutlet UIView* scrollerOverlay;
@property (nonatomic, weak) IBOutlet UIImageView *scrollerBkImageView;
@property (nonatomic, weak) IBOutlet UIImageView *monthNote;
@property (nonatomic, weak) IBOutlet UIImageView *nextNote;
@property (nonatomic, weak) IBOutlet UIImageView *prevNote;
@end

@implementation ScrollViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSBundle *bundle = [NSBundle mainBundle];
    
    NSArray *months = @[
                        [UIImage imageWithIdentifier:@"Jan" fromBundle:bundle],
                        [UIImage imageWithIdentifier:@"Feb" fromBundle:bundle],
                        [UIImage imageWithIdentifier:@"Mar" fromBundle:bundle],
                        [UIImage imageWithIdentifier:@"Apr" fromBundle:bundle],
                        [UIImage imageWithIdentifier:@"May" fromBundle:bundle],
                        [UIImage imageWithIdentifier:@"Jun" fromBundle:bundle],
                        [UIImage imageWithIdentifier:@"Jul" fromBundle:bundle],
                        [UIImage imageWithIdentifier:@"Aug" fromBundle:bundle],
                        [UIImage imageWithIdentifier:@"Sep" fromBundle:bundle],
                        [UIImage imageWithIdentifier:@"Oct" fromBundle:bundle],
                        [UIImage imageWithIdentifier:@"Nov" fromBundle:bundle],
                        [UIImage imageWithIdentifier:@"Dec" fromBundle:bundle]
                        ];
    
    [self.scroller populateWithArrayOfImages:months];
    self.scroller.infiniteScrollViewDelegate = self;
    [self.scroller setShowsHorizontalScrollIndicator:NO];
}

- (void)newCurrentItem:(NSString*)currentItem {
  UIImage *monthNote = [UIImage imageWithIdentifier:[NSString stringWithFormat:@"%@_Note", currentItem] fromBundle:[NSBundle mainBundle]];
  self.monthNote.image = monthNote;
}

- (void)nextItemsOpacity:(NSString*)nextItem opacity: (CGFloat) newOpacity {
  UIImage *nextImg = [UIImage imageWithIdentifier:[NSString stringWithFormat:@"%@_Note", nextItem] fromBundle:[NSBundle mainBundle]];

  self.nextNote.layer.opacity = newOpacity;
  self.nextNote.image = nextImg;
}

- (void)prevItemsOpacity:(NSString*)prevItem opacity: (CGFloat) newOpacity {
  UIImage *prevImg = [UIImage imageWithIdentifier:[NSString stringWithFormat:@"%@_Note", prevItem] fromBundle:[NSBundle mainBundle]];

  self.prevNote.layer.opacity = newOpacity;
  self.prevNote.image = prevImg;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end

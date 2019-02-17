//
//  UIImage+Identifier.m
//  UIImage+Identifier
//
//  Created by Iain Frame on 18/04/2015.
//  Copyright (c) 2015 Point Pixel Ltd. All rights reserved.
//

#import "UIImage+Identifier.h"
#import <objc/runtime.h>

@implementation UIImage (Identifier)

@dynamic identifyingName;

+ (UIImage*) imageWithIdentifier:(NSString *)imageFileName fromBundle:(NSBundle*)bundle {
  
  UIImage *img = [UIImage imageNamed:imageFileName
                               inBundle:bundle
          compatibleWithTraitCollection:nil];
  
  if (img) {
    img.identifyingName = imageFileName;
  } else {
    NSLog(@"Unable to locate the image file : %@", imageFileName);
  }
  return img;
}

- (void)setIdentifyingName:(id)object {
  objc_setAssociatedObject(self, @selector(identifyingName), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)identifyingName {
  return objc_getAssociatedObject(self, @selector(identifyingName));
}

@end

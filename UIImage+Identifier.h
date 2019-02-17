//
//  UIImage+Identifier.h
//  UIImage+Identifier
//
//  Created by Iain Frame on 18/04/2015.
//  Copyright (c) 2015 Point Pixel Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Identifier)
@property (nonatomic, strong) id identifyingName;
+(UIImage*) imageWithIdentifier:(NSString *)imageFileName fromBundle:(NSBundle*)bundle;
@end

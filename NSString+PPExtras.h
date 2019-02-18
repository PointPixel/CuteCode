//
//  NSString+Additions.h
//  WordSearch
//
//  Created by Iain Frame on 02/06/2015.
//  Copyright (c) 2015 PointPixel Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (PPExtras)
-(NSString*) stringByRemovingDoubleQuotes;
-(NSString*) stringByCleaningSmartDoubleQuotes;
-(NSArray*) components;
-(NSDictionary*) keyValueComponents;
-(UIColor *) color;
-(NSString *)reverseString:(NSString *)input;
@end

NS_ASSUME_NONNULL_END

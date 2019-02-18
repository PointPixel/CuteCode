//
//  NSString+Additions.m
//  WordSearch
//
//  Created by Iain Frame on 02/06/2015.
//  Copyright (c) 2015 PointPixel Ltd. All rights reserved.
//

#import "NSString+PPExtras.h"

@implementation NSString (PPExtras)

-(NSString*) stringByRemovingDoubleQuotes {
    
    NSString *string = [self stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"“" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"”" withString:@""];
    
    return string;
}

-(NSString*) stringByCleaningSmartDoubleQuotes {
    
    NSString *string = [self stringByReplacingOccurrencesOfString:@"“" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"”" withString:@"\""];
    
    return string;
}

-(NSArray*) components {
    
    NSString *string = [self stringByCleaningSmartDoubleQuotes];
    
    string = [string stringByReplacingOccurrencesOfString:@"\" ,\"" withString:@"\",\""];
    string = [string stringByReplacingOccurrencesOfString:@"\", \"" withString:@"\",\""];
    
    NSArray *components = nil;
    if([string rangeOfString:@"\""].location == NSNotFound)
        components = [string componentsSeparatedByString:@","];
    else
        components = [string componentsSeparatedByString:@"\",\""];
    
    NSMutableArray *trimmedComponents = [NSMutableArray array];
    
    [components enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString *thisString = [obj stringByRemovingDoubleQuotes];
        [trimmedComponents addObject:[thisString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }];
    
    return trimmedComponents;
}

-(NSDictionary*) keyValueComponents {
    
    NSArray *array = [self components];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString *thisComponent = obj;
        NSArray *array = [thisComponent componentsSeparatedByString:@"="];
        dict[[array[0] stringByRemovingDoubleQuotes]] = [array[1] stringByRemovingDoubleQuotes];
    }];
    
    return [dict copy];
}

- (UIColor *) color {
    NSString *colorString = [[self stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", self];
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

- (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

- (NSString *)reverseString:(NSString *)input {
    NSInteger len = (NSInteger)[input length];
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:len];
    for (NSInteger i = len - 1; i >= 0; i--) {
        [result appendFormat:@"%c", [input characterAtIndex:i]];
    }
    return result;
}
@end

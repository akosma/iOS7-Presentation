//
//  UIColor+Presentation.m
//  Presentation
//
//  Created by Adrian on 19/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "UIColor+Presentation.h"

@implementation UIColor (Presentation)

+ (UIColor *)colorWithHexString:(NSString *)string
{
    return [self colorWithHexString:string alpha:1.0];
}

+ (UIColor *)colorWithHexString:(NSString *)string alpha:(CGFloat)alpha
{
    // Convert hex string to an integer
    unsigned int hexint = [self intFromHexString:string];
    
    // Create color object, specifying alpha as well
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:alpha];
    
    return color;
}

+ (unsigned int)intFromHexString:(NSString *)hexStr
{
    unsigned int hexInt = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    
    // Scan hex value
    [scanner scanHexInt:&hexInt];
    
    return hexInt;
}

@end

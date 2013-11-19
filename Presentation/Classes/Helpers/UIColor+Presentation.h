//
//  UIColor+Presentation.h
//  Presentation
//
//  Created by Adrian on 19/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Presentation)

+ (UIColor *)colorWithHexString:(NSString *)string;

+ (UIColor *)colorWithHexString:(NSString *)string alpha:(CGFloat)alpha;

@end

//
//  TRICircleView.m
//  Presentation
//
//  Created by Adrian on 20/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRICircleView.h"

@implementation TRICircleView

- (void)setColor:(UIColor *)color
{
    _color = color;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGContextFillEllipseInRect(context, rect);
}

@end

//
//  TRICrossView.m
//  Presentation
//
//  Created by Adrian on 16/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRICrossView.h"
#import "TRIHelpers.h"

@implementation TRICrossView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGRect bounds = CGRectInset(rect, 20, 20);
    UIBezierPath *path = [UIBezierPath customBezierPathOfPlusSymbolWithRect:bounds
                                                                      scale:1.0];
    [path fill];
}

@end

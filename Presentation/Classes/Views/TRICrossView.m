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
    [[UIColor redColor] setFill];
    UIBezierPath *path = [UIBezierPath customBezierPathOfPlusSymbolWithRect:self.bounds
                                                                      scale:1.0];
    [path fill];

}

@end

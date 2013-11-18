//
//  TRIEmptyScreen.m
//  Presentation
//
//  Created by Adrian on 14/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRIEmptyScreen.h"

@interface TRIEmptyScreen ()

@end

@implementation TRIEmptyScreen

+ (NSString *)xtype
{
    return @"empty";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delayForSnapshot = 0.3;
}

- (void)flashAndThen:(TRIBaseScreenControllerFlashCallback)callback
{
    callback();
}

@end

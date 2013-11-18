//
//  TRITextScreen.m
//  Presentation
//
//  Created by Adrian on 13/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRITextScreen.h"

@interface TRITextScreen ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation TRITextScreen

+ (NSString *)xtype
{
    return @"text";
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *text = self.definition[@"contents"];
    self.label.text = text;
}

@end

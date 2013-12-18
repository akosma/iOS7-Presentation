//
//  TRITextScreen.m
//  Presentation
//
//  Created by Adrian on 13/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRITextScreen.h"
#import "TRIHelpers.h"

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
    
    if (self.definition[@"code"])
    {
        self.label.font = [UIFont fontWithName:@"Menlo"
                                          size:30];
    }
    
    if (self.definition[@"list"])
    {
        NSArray *parts = [text componentsSeparatedByString:@"\n"];
        NSMutableString *string = [NSMutableString stringWithString:@"• "];
        [string appendString:[parts componentsJoinedByString:@"\n• "]];
        text = string;
        self.label.textAlignment = NSTextAlignmentLeft;
    }
    
    if (self.definition[@"textColor"])
    {
        NSString *string = self.definition[@"textColor"];
        self.label.textColor = [UIColor colorWithHexString:string];
    }

    self.label.text = text;
}

@end

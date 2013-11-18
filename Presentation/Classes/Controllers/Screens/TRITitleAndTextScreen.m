//
//  TRITitleAndTextScreen.m
//  Presentation
//
//  Created by Adrian on 14/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRITitleAndTextScreen.h"

@interface TRITitleAndTextScreen ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation TRITitleAndTextScreen

+ (NSString *)xtype
{
    return @"title";
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *title = self.definition[@"title"];
    NSString *text = self.definition[@"contents"];
    self.textLabel.text = text;
    self.titleLabel.text = title;
}

@end

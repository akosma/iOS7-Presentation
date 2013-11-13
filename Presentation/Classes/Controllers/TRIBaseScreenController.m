//
//  TRIBaseScreenController.m
//  Presentation
//
//  Created by Adrian on 13/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRIBaseScreenController.h"

@interface TRIBaseScreenController ()

@end

@implementation TRIBaseScreenController

- (instancetype)initWithDefinition:(NSDictionary *)definition
{
    if (self = [super init])
    {
        self.definition = definition;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.definition[@"title"];
}

@end

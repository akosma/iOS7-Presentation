//
//  TRIReadingListScreen.m
//  Presentation
//
//  Created by Adrian on 19/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

@import SafariServices;


#import "TRIReadingListScreen.h"


@implementation TRIReadingListScreen

+ (NSString *)xtype
{
    return @"readinglist";
}

- (IBAction)addToReadingList:(id)sender
{
    NSURL *URL = [NSURL URLWithString:@"http://trifork.com"];
    [[SSReadingList defaultReadingList] addReadingListItemWithURL:URL
                                                            title:@"Trifork"
                                                      previewText:@"..."
                                                            error:nil];
}

@end

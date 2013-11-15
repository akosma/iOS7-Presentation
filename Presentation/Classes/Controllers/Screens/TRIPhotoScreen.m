//
//  TRIPhotoScreen.m
//  Presentation
//
//  Created by Adrian on 13/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRIPhotoScreen.h"

@interface TRIPhotoScreen ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end


@implementation TRIPhotoScreen

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delayForSnapshot = 1.0;

    NSString *name = self.definition[@"contents"];
    UIImage *image = [UIImage imageNamed:name];
    
    if (self.definition[@"contentMode"])
    {
        self.imageView.contentMode = (UIViewContentMode)[self.definition[@"contentMode"] integerValue];
    }
    
    self.imageView.image = image;
}

@end

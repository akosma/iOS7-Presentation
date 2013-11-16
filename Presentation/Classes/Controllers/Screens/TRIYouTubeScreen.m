//
//  TRIYouTubeScreen.m
//  Presentation
//
//  Created by Adrian on 16/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRIYouTubeScreen.h"
#import "TRIHelpers.h"

@interface TRIYouTubeScreen ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation TRIYouTubeScreen

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.delayForSnapshot = 1.0;
    
    NSString *name = self.definition[@"placeholder"];
    UIImage *image = [UIImage imageNamed:name];
    self.imageView.image = image;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self play];
}

#pragma mark - UIGestureRecognizer methods

- (IBAction)showVideo:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateRecognized)
    {
        [self play];
    }
}

- (void)play
{
    NSString *videoId = self.definition[@"contents"];
    XCDYouTubeVideoPlayerViewController *player = nil;
    player = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:videoId];
    [self presentMoviePlayerViewControllerAnimated:player];
}

@end

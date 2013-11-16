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
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;

@end

@implementation TRIYouTubeScreen

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.delayForSnapshot = 1.0;
    
    NSString *name = self.definition[@"placeholder"];
    UIImage *image = [UIImage imageNamed:name];
    self.imageView.image = image;
    
    NSString *videoId = self.definition[@"contents"];
    NSString *url = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", videoId];
    self.urlLabel.text = url;
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

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
@property (weak, nonatomic) IBOutlet UIView *holderView;
@property (strong, nonatomic) XCDYouTubeVideoPlayerViewController *player;

@end

@implementation TRIYouTubeScreen

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *name = self.definition[@"placeholder"];
    UIImage *image = [UIImage imageNamed:name];
    self.imageView.image = image;
    
    NSString *videoId = self.definition[@"contents"];
    NSString *url = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", videoId];
    self.urlLabel.text = url;
}

- (void)performMainScreenAction
{
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
    self.player = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:videoId];
    self.player.view.frame = self.holderView.bounds;
    [self.holderView addSubview:self.player.view];
}

@end

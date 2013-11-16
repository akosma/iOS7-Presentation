//
//  TRIInteractiveTextScreen.m
//  Presentation
//
//  Created by Adrian on 16/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//
// This code is adapted from
// https://github.com/objcio/issue-5-textkit
//
// The custom path is courtesy of
// https://github.com/Kjuly/UIBezierPath-Symbol
//

#import "TRIInteractiveTextScreen.h"
#import "TRIViews.h"
#import "TRIHelpers.h"


@interface TRIInteractiveTextScreen ()

@property (nonatomic) CGPoint offset;
@property (weak, nonatomic) IBOutlet UIView *crossView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end


@implementation TRIInteractiveTextScreen

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Enable hyphenation
    self.textView.layoutManager.hyphenationFactor = 1.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateExclusionPaths];
}


#pragma mark - Exclusion

- (IBAction)pan:(UIPanGestureRecognizer *)pan
{
    if (pan.state == UIGestureRecognizerStateBegan)
    {
        self.offset = [pan locationInView:self.crossView];
    }
    else
    {
        CGPoint location = [pan locationInView:self.view];
        CGPoint circleCenter = self.crossView.center;
        
        CGFloat width = self.crossView.frame.size.width;
        circleCenter.x = location.x - self.offset.x + width / 2;
        circleCenter.y = location.y - self.offset.y + width / 2;
        self.crossView.center = circleCenter;
        
        [self updateExclusionPaths];
    }
}

- (void)updateExclusionPaths
{
    // Since text container does not know about the inset,
    // we must shift the frame to container coordinates
    CGRect frame = [self.textView convertRect:self.crossView.bounds
                                     fromView:self.crossView];
    
    frame.origin.x -= self.textView.textContainerInset.left;
    frame.origin.y -= self.textView.textContainerInset.top;
    
    // Set the exclusion path.
    UIBezierPath *path = [UIBezierPath customBezierPathOfPlusSymbolWithRect:frame
                                                                      scale:1.0];
    self.textView.textContainer.exclusionPaths = @[path];
}

@end

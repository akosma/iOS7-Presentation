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


@interface TRIInteractiveTextScreen () <UITextViewDelegate>

@property (nonatomic) CGPoint offset;
@property (weak, nonatomic) IBOutlet UIView *crossView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end


@implementation TRIInteractiveTextScreen

+ (NSString *)xtype
{
    return @"movetxt";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Enable hyphenation
    self.textView.layoutManager.hyphenationFactor = 1.0;
    [self updateExclusionPaths];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateExclusionPaths];
}

#pragma mark - Gesture recognizers

- (IBAction)pan:(UIPanGestureRecognizer *)pan
{
    if (pan.state == UIGestureRecognizerStateBegan)
    {
        self.offset = [pan locationInView:self.crossView];
    }
    else
    {
        CGPoint location = [pan locationInView:self.view];
        CGPoint center = self.crossView.center;
        
        CGFloat width = self.crossView.frame.size.width;
        center.x = location.x - self.offset.x + width / 2;
        center.y = location.y - self.offset.y + width / 2;
        self.crossView.center = center;
        
        [self updateExclusionPaths];
    }
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateExclusionPaths];
}

#pragma mark - Private methods

- (void)updateExclusionPaths
{
    __weak typeof(self) weakSelf = self;
    dispatch_queue_priority_t prio = DISPATCH_QUEUE_PRIORITY_HIGH;
    dispatch_queue_t queue = dispatch_get_global_queue(prio, 0);
    dispatch_async(queue, ^{
        // Since text container does not know about the inset,
        // we must shift the frame to container coordinates
        CGRect frame = [weakSelf.textView convertRect:weakSelf.crossView.bounds
                                             fromView:weakSelf.crossView];
        
        frame.origin.x -= weakSelf.textView.textContainerInset.left;
        frame.origin.y -= weakSelf.textView.textContainerInset.top;
        
        // Set the exclusion path.
        UIBezierPath *path = [UIBezierPath customBezierPathOfPlusSymbolWithRect:frame
                                                                          scale:1.0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.textView.textContainer.exclusionPaths = @[path];
        });
    });
}

@end

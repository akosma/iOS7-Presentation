//
//  TRIOpenInAppActivity.m
//  Presentation
//
//  Created by Adrian on 14/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//
//  Adapted from TTOpenInAppActivity
//  https://github.com/honkmaster/TTOpenInAppActivity
//
//  Created by Tobias Tiemerding on 12/25/12.
//  Copyright (c) 2012-2013 Tobias Tiemerding
//

#import "TRIOpenInAppActivity.h"

@interface TRIOpenInAppActivity () <UIActionSheetDelegate>

@property (nonatomic, strong) NSArray *fileURLs;
@property (atomic) CGRect rect;
@property (nonatomic, strong) UIBarButtonItem *barButtonItem;
@property (nonatomic, strong) UIView *superView;
@property (nonatomic, strong) UIDocumentInteractionController *docController;

@end



@implementation TRIOpenInAppActivity

- (id)initWithView:(UIView *)view andRect:(CGRect)rect
{
    if(self =[super init])
    {
        self.superView = view;
        self.rect = rect;
    }
    return self;
}

- (id)initWithView:(UIView *)view andBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if(self =[super init])
    {
        self.superView = view;
        self.barButtonItem = barButtonItem;
    }
    return self;
}

- (NSString *)activityType
{
	return NSStringFromClass([self class]);
}

- (NSString *)activityTitle
{
	return NSLocalizedString(@"Open in ...", @"Open in ...");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"TTOpenInAppActivity7"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    NSUInteger count = 0;
    
    for (id activityItem in activityItems)
    {
		if ([activityItem isKindOfClass:[NSURL class]]
            && [(NSURL *)activityItem isFileURL])
        {
			count++;
		}
	}
	
	return (count >= 1);
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    NSMutableArray *fileURLs = [NSMutableArray array];
    
	for (id activityItem in activityItems)
    {
		if ([activityItem isKindOfClass:[NSURL class]]
            && [(NSURL *)activityItem isFileURL])
        {
            [fileURLs addObject:activityItem];
		}
	}
    
    self.fileURLs = [fileURLs copy];
}

- (void)performActivity
{
    if(!self.superViewController)
    {
        [self activityDidFinish:YES];
        return;
    }
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self.superViewController dismissViewControllerAnimated:YES
                                                     completion:^{
                                                         if (self.fileURLs.count > 1)
                                                         {
                                                             [self openSelectFileActionSheet];
                                                         }
                                                         else {
                                                             // Open UIDocumentInteractionController
                                                             [self openDocumentInteractionControllerWithFileURL:self.fileURLs.lastObject];
                                                         }
                                                     }];
    }
    else
    {
        [self.superViewController dismissPopoverAnimated:YES];
        [((UIPopoverController *)self.superViewController).delegate popoverControllerDidDismissPopover:self.superViewController];
        if (self.fileURLs.count > 1)
        {
            [self openSelectFileActionSheet];
        }
        else
        {
            [self openDocumentInteractionControllerWithFileURL:self.fileURLs.lastObject];
        }
    }
}

#pragma mark - Helpers

- (NSString *)UTIForURL:(NSURL *)url
{
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)url.pathExtension, NULL);
    return (NSString *)CFBridgingRelease(UTI) ;
}

- (void)openDocumentInteractionControllerWithFileURL:(NSURL *)fileURL
{
    self.docController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    self.docController.delegate = self;
    self.docController.UTI = [self UTIForURL:fileURL];
    BOOL success;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        success = [self.docController presentOpenInMenuFromRect:CGRectZero inView:self.superView animated:YES];
    }
    else
    {
        if(self.barButtonItem)
        {
            success = [self.docController presentOpenInMenuFromBarButtonItem:self.barButtonItem animated:YES];
        }
        else
        {
            success = [self.docController presentOpenInMenuFromRect:self.rect inView:self.superView animated:YES];
        }
    }
    
    if(!success)
    {
        // There is no app to handle this file
        NSString *deviceType = [UIDevice currentDevice].localizedModel;
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Your %@ doesn't seem to have any other Apps installed that can open this document.",
                                                                         @"Your %@ doesn't seem to have any other Apps installed that can open this document."), deviceType];
        
        // Display alert
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No suitable Apps installed", @"No suitable App installed")
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil];
        [alert show];
        
        // Inform app that the activity has finished
        // Return NO because the service was canceled and did not finish because of an error.
        // http://developer.apple.com/library/ios/#documentation/uikit/reference/UIActivity_Class/Reference/Reference.html
        [self activityDidFinish:NO];
    }
}

- (void)dismissDocumentInteractionControllerAnimated:(BOOL)animated
{
    // Hide menu
    [self.docController dismissMenuAnimated:animated];
    
    // Inform app that the activity has finished
    [self activityDidFinish:NO];
}

- (void)openSelectFileActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select a file", @"Select a file")
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    for (NSURL *fileURL in self.fileURLs)
    {
        [actionSheet addButtonWithTitle:[fileURL lastPathComponent]];
    }
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel")];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [actionSheet showFromRect:CGRectZero inView:self.superView animated:YES];
    }
    else
    {
        if(self.barButtonItem)
        {
            [actionSheet showFromBarButtonItem:self.barButtonItem animated:YES];
        }
        else
        {
            [actionSheet showFromRect:self.rect inView:self.superView animated:YES];
        }
    }
}

#pragma mark - UIDocumentInteractionControllerDelegate methods

- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller
{
    if([self.delegate respondsToSelector:@selector(openInAppActivityWillPresentDocumentInteractionController:)])
    {
        [self.delegate openInAppActivityWillPresentDocumentInteractionController:self];
    }
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    if([self.delegate respondsToSelector:@selector(openInAppActivityDidDismissDocumentInteractionController:)])
    {
        [self.delegate openInAppActivityDidDismissDocumentInteractionController:self];
    }
    
    [self activityDidFinish:YES];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        [self openDocumentInteractionControllerWithFileURL:self.fileURLs[buttonIndex]];
    }
    else
    {
	    [self activityDidFinish:NO];
    }
}

@end

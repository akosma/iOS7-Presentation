//
//  TRISourceCodeController.m
//  Presentation
//
//  Created by Adrian on 13/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRISourceCodeController.h"

@interface TRISourceCodeController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@end

@implementation TRISourceCodeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self styleSourceCode];
    
    self.textView.attributedText = self.sourceCode;
    self.navItem.title = self.title;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.textView scrollRangeToVisible:NSMakeRange(0, 1)];
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - Private methods

- (void)styleSourceCode
{
    NSInteger index = 1; // If we use zero, the font will be Times New Roman :)
    
    // Get the string currently selected by the CSS
    UIFont *font = [self.sourceCode attribute:NSFontAttributeName
                                      atIndex:index
                               effectiveRange:NULL];
    
    // Use the same font, but with the size selected by the user
    // in the system preferences
    NSString *style = UIFontTextStyleBody;
    UIFontDescriptor *descriptor = nil;
    descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:style];
    font = [UIFont fontWithName:font.familyName
                           size:descriptor.pointSize];
    
    // Let's apply that font all over the attributed string
    NSInteger length = [self.sourceCode length];
    NSRange range = NSMakeRange(0, length);
    
    [self.sourceCode beginEditing];
    [self.sourceCode addAttribute:NSFontAttributeName
                            value:font
                            range:range];
    [self.sourceCode endEditing];
}

@end

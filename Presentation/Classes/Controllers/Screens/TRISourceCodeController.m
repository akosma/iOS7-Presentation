//
//  TRISourceCodeController.m
//  Presentation
//
//  Created by Adrian on 13/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRISourceCodeController.h"
#import "TRIHelpers.h"


@interface TRISourceCodeController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) NSMutableAttributedString *sourceCode;

@end


@implementation TRISourceCodeController

+ (NSString *)xtype
{
    return @"source";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *closeButton = nil;
    closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                target:self
                                                                action:@selector(close:)];
    self.navigationItem.rightBarButtonItem = closeButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.className == nil)
    {
        self.className = NSStringFromClass([self class]);
    }
    
    self.sourceCode = [self loadSourceCode];
    NSString *title = [NSString stringWithFormat:@"%@.m", self.className];
    self.title = title;

    self.textView.attributedText = self.sourceCode;
    [self styleSourceCode];
    [self.textView scrollRangeToVisible:NSMakeRange(0, 1)];
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - Private methods

- (NSMutableAttributedString *)loadSourceCode
{
    // Let's find out the path of the HTML file to show
    NSString *className = NSStringFromClass([self class]);
    NSString *filename = [NSString stringWithFormat:@"html/%@.m", className];
    NSString *path = [[NSBundle mainBundle] pathForResource:filename
                                                     ofType:@"html"];
    NSMutableAttributedString *string = nil;
    
    if (path)
    {
        NSURL *url = [NSURL fileURLWithPath:path];
        
        // Now we're going to load that HTML on a mutable string
        NSDictionary *options = @{
                                  NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType
                                  };
        NSError *error = nil;
        string = [[NSMutableAttributedString alloc] initWithFileURL:url
                                                            options:options
                                                 documentAttributes:nil
                                                              error:&error];
    }
    
    return string;
}

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

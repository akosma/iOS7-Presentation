//
//  TRISourceCodeScreen.m
//  Presentation
//
//  Created by Adrian on 13/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRISourceCodeScreen.h"
#import "TRIHelpers.h"


@interface TRISourceCodeScreen ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) NSMutableAttributedString *sourceCode;

@end


@implementation TRISourceCodeScreen

+ (NSString *)xtype
{
    return @"source";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *closeButton = nil;
    UIBarButtonSystemItem type = UIBarButtonSystemItemDone;
    SEL sel = @selector(close:);
    closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:type
                                                                target:self
                                                                action:sel];
    self.navigationItem.rightBarButtonItem = closeButton;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:UIContentSizeCategoryDidChangeNotification
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification) {
                        [self styleSourceCode];
                    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.className == nil)
    {
        self.className = NSStringFromClass([self class]);
    }
    else
    {
        NSString *title = [NSString stringWithFormat:@"%@.m", self.className];
        self.title = title;
    }
    
    self.sourceCode = [self loadSourceCode];
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
    NSString *filename = [NSString stringWithFormat:@"html/%@.m", self.className];
    NSString *path = [[NSBundle mainBundle] pathForResource:filename
                                                     ofType:@"html"];
    NSMutableAttributedString *string = nil;
    
    if (path)
    {
        NSURL *url = [NSURL fileURLWithPath:path];
        
        // Now we're going to load that HTML on a mutable string
        NSDictionary *options = nil;
        options = @{
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
    NSMutableAttributedString *string = nil;
    NSAttributedString *text = self.textView.attributedText;
    string = [[NSMutableAttributedString alloc] initWithAttributedString:text];
    NSRange range = NSMakeRange(0, string.length - 1);

    NSString *style = UIFontTextStyleBody;
    UIFontDescriptor *descriptor = nil;
    descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:style];

    UIFont *newFont = [UIFont fontWithName:@"Menlo"
                                      size:descriptor.pointSize];
    [string addAttribute:NSFontAttributeName
                   value:newFont
                   range:range];
    
    self.textView.attributedText = string;
}

@end

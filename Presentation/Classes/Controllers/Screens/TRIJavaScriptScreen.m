//
//  TRIJavaScriptScreen.m
//  Presentation
//
//  Created by Adrian on 17/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

@import JavaScriptCore;

#import "TRIJavaScriptScreen.h"


// This protocol states what is visible from the JS runtime

@protocol TRIJSExport <JSExport>

- (void)log:(NSString *)value;
- (void)clear;

@end


// Our console object redirects output to its associated text view

@interface TRIConsole : NSObject <TRIJSExport>

@property (nonatomic, weak) UITextView *textView;

- (instancetype)initWithTextView:(UITextView *)textView;

- (void)log:(NSString *)value;
- (void)clear;

@end



@implementation TRIConsole

- (instancetype)initWithTextView:(UITextView *)textView
{
    if (self = [super init])
    {
        self.textView = textView;
    }
    return self;
}

- (void)log:(NSString *)value
{
    NSMutableString *string = [NSMutableString stringWithString:self.textView.text];
    if ([string length] > 0)
    {
        [string appendString:@"\n"];
    }
    [string appendString:value];
    self.textView.text = string;
    
    NSUInteger location = [string length] - 2;
    NSRange range = NSMakeRange(location, 1);
    [self.textView scrollRangeToVisible:range];
}

- (void)clear
{
    self.textView.text = @"";
}

@end


// Finally, this is the screen itself

@interface TRIJavaScriptScreen ()

@property (weak, nonatomic) IBOutlet UITextView *editorTextView;
@property (weak, nonatomic) IBOutlet UITextView *consoleTextView;
@property (nonatomic, strong) JSContext *context;
@property (nonatomic, strong) TRIConsole *console;

@end


@implementation TRIJavaScriptScreen

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize the virtual machine
    JSVirtualMachine *machine = [[JSVirtualMachine alloc] init];
    self.context = [[JSContext alloc] initWithVirtualMachine:machine];
    
    // The context can hold lots of objects
    self.context[@"copyright"] = @"Copyright © 2013 Trifork – All Rights Reserved";
    self.context[@"author"] = @"Adrian Kosmaczewski";
    self.context[@"year"] = @2013;
    self.context[@"enabled"] = @YES;
    self.context[@"offices"] = @[ @"Århus", @"Zürich", @"Amsterdam", @"Eindhoven" ];

    // Adding a console object to the context
    self.console = [[TRIConsole alloc] initWithTextView:self.consoleTextView];
    self.context[@"console"] = self.console;
    
    // We can also store blocks, and this one is recursive!
    // Leak-free recursive blocks, as explained by
    // http://jeremywsherman.com/blog/2013/02/27/leak-free-recursive-blocks/
    unsigned int (^__block __weak weakFibonacci) (unsigned int n);
    unsigned int (^fibonacci) (unsigned int n);
    weakFibonacci = fibonacci = ^unsigned int(unsigned int n) {
        if (n == 0)
        {
            return 0;
        }
        if (n == 1)
        {
            return 1;
        }
        return weakFibonacci(n - 1) + weakFibonacci(n - 2);
    };
    self.context[@"fibonacci"] = fibonacci;
    
    // What would be a JavaScript runtime without "alert()"?
    self.context[@"alert"] = ^ (NSString *text) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"JS Alert"
                                                        message:text
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    };
}

- (void)performMainScreenAction
{
    [self executeJavaScript:nil];
}

#pragma mark - IBAction methods

- (IBAction)executeJavaScript:(id)sender
{
    [self.editorTextView resignFirstResponder];
    NSString *js = self.editorTextView.text;
    JSValue *value = [self.context evaluateScript:js];
    NSLog(@"JSValue: %@", value);
}

- (IBAction)clearConsole:(id)sender
{
    [self.console clear];
}

@end

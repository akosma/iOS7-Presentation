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

@end

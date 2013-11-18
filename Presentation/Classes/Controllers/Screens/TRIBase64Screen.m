//
//  TRIBase64Screen.m
//  Presentation
//
//  Created by Adrian on 18/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRIBase64Screen.h"

@interface TRIBase64Screen ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end


@implementation TRIBase64Screen

+ (NSString *)xtype
{
    return @"base64";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"base64"];
    NSData *data = UIImagePNGRepresentation(image);
    NSString *base64 = [data base64EncodedStringWithOptions:0];
    NSString *img = @"<p align=\"center\" style=\"margin: 50px\"><img src=\"data:image/png;base64,%@\" alt=\"base64 Test\"></p>";
    NSString *html = [NSString stringWithFormat:img, base64];
    [self.webView loadHTMLString:html
                         baseURL:nil];
}

@end

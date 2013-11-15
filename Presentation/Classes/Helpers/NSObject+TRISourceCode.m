//
//  NSObject+TRISourceCode.m
//  Presentation
//
//  Created by Adrian on 13/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "NSObject+TRISourceCode.h"

@implementation NSObject (TRISourceCode)

- (NSMutableAttributedString *)tri_sourceCode
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

@end

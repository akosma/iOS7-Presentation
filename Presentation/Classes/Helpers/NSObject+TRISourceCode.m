//
//  NSObject+TRISourceCode.m
//  Presentation
//
//  Created by Adrian on 13/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "NSObject+TRISourceCode.h"

@implementation NSObject (TRISourceCode)

- (NSAttributedString *)tri_sourceCode
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
        
        if (error == nil)
        {
            NSInteger index = 1; // If we use zero, the font will be Times New Roman :)
            
            // Get the string currently selected by the CSS
            UIFont *font = [string attribute:NSFontAttributeName
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
            NSInteger length = [string length];
            NSRange range = NSMakeRange(0, length);
            
            [string beginEditing];
            [string addAttribute:NSFontAttributeName
                           value:font
                           range:range];
            [string endEditing];
        }
    }
    
    return string;
}

@end

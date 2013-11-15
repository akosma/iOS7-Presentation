//
//  TRIPDFHelper.m
//  Presentation
//
//  Created by Adrian on 15/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRIPDFHelper.h"


@interface TRIPDFHelper ()

@property (nonatomic, copy) NSArray *files;
@property (nonatomic) CGRect bounds;
@property (nonatomic) UIInterfaceOrientation interfaceOrientation;

@end


@implementation TRIPDFHelper

- (instancetype)initWithFiles:(NSArray *)files
                       bounds:(CGRect)bounds
                  orientation:(UIInterfaceOrientation)orientation
{
    if (self = [super init])
    {
        self.files = files;
        self.bounds = bounds;
        self.interfaceOrientation = orientation;
    }
    return self;
}

#pragma mark - Public methods

- (void)generatePDFWithPath:(NSString *)path
{
    // Prepare a PDF context
    UIGraphicsBeginPDFContextToFile(path, CGRectZero, nil);
    
    for (NSString *filename in self.files)
    {
        if ([filename hasSuffix:@".png"])
        {
            // It's an image!
            NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
            
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            UIGraphicsBeginPDFPageWithInfo(self.bounds, nil);
            
            CGContextRef currentContext = UIGraphicsGetCurrentContext();
            
            // PDF contexts have an inverted coordinate system,
            // which means we have to make a transformation before drawing
            CGContextTranslateCTM(currentContext, 0, self.bounds.size.height);
            CGContextScaleCTM(currentContext, 1.0, -1.0);
            
            // Draw the image in the PDF file
            CGContextDrawImage(currentContext, self.bounds, image.CGImage);
        }
        else if ([filename hasSuffix:@".m"])
        {
            // It's source code in HTML format!
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
                    // We have an attributed string; let's draw it into the PDF
                    // adding as many pages as required
                    CFAttributedStringRef currentText = (__bridge CFAttributedStringRef)string;
                    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(currentText);
                    CFRange currentRange = CFRangeMake(0, 0);
                    NSInteger currentPage = 0;
                    BOOL done = NO;
                    do
                    {
                        UIGraphicsBeginPDFPageWithInfo(self.bounds, nil);
                        currentPage++;
                        
                        currentRange = [self renderPage:currentPage
                                          withTextRange:currentRange
                                         andFramesetter:framesetter];
                        if (currentRange.location == CFAttributedStringGetLength(currentText))
                        {
                            done = YES;
                        }
                    }
                    while (!done);
                    CFRelease(framesetter);
                }
            }
        }
    }
    
    UIGraphicsEndPDFContext();
}

#pragma mark - Private methods

- (CFRange)renderPage:(NSInteger)pageNum
        withTextRange:(CFRange)currentRange
       andFramesetter:(CTFramesetterRef)framesetter
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    CGRect bounds = CGRectInset(self.bounds, 50, 50);
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        CGContextTranslateCTM(currentContext, 0, 730);
    }
    else
    {
        CGContextTranslateCTM(currentContext, 0, 980);
    }
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, bounds);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, NULL);
    CGPathRelease(framePath);
    
    CTFrameDraw(frameRef, currentContext);
    currentRange = CTFrameGetVisibleStringRange(frameRef);
    currentRange.location += currentRange.length;
    currentRange.length = 0;
    CFRelease(frameRef);
    
    return currentRange;
}

@end

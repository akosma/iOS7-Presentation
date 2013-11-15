//
//  TRINavigationController.m
//  Presentation
//
//  Created by Adrian on 13/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRINavigationController.h"
#import "TRIBaseScreenController.h"
#import "TRISourceCodeController.h"
#import "TRIHelpers.h"


static NSString *CELL_REUSE_IDENTIFIER = @"CELL_REUSE_IDENTIFIER";
static NSString *PDF_FILENAME = @"slides.pdf";



@interface TRINavigationController () <UITableViewDataSource,
                                       UITableViewDelegate,
                                       UIAlertViewDelegate,
                                       TRIReceiverDelegate,
                                       TRIBroadcasterDelegate>

@property (nonatomic, strong) NSArray *definitions;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, strong) TRIBaseScreenController *currentScreen;
@property (nonatomic, strong) TRISourceCodeController *sourceCodeController;
@property (nonatomic, strong) UIPopoverController *screenPopover;
@property (nonatomic, strong) UIPopoverController *sharePopover;
@property (nonatomic, strong) NSDictionary *xtypes;
@property (nonatomic, strong) NSMutableArray *filenamesForPDF;
@property (nonatomic, strong) UIAlertView *generatingPDFAlert;
@property (nonatomic) BOOL continuePDFGeneration;

@property (nonatomic, strong) TRIBroadcaster *broadcaster;
@property (nonatomic, strong) TRIReceiver *receiver;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleButtonItem;
@property (weak, nonatomic) IBOutlet UIView *holderView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousScreenButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextScreenButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sourceCodeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *generatePDFButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@end



@implementation TRINavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];

    CBUUID *remoteControlChar = [CBUUID UUIDWithString:REMOTE_CONTROL_CHARACTERISTIC_UUID];
    CBUUID *remoteControlService = [CBUUID UUIDWithString:REMOTE_CONTROL_SERVICE_UUID];
    self.receiver = [[TRIReceiver alloc] initWithCharacteristic:remoteControlChar
                                                        service:remoteControlService];
    
    CBUUID *presenterChar = [CBUUID UUIDWithString:PRESENTER_CHARACTERISTIC_UUID];
    CBUUID *presenterService = [CBUUID UUIDWithString:PRESENTER_SERVICE_UUID];
    self.broadcaster = [[TRIBroadcaster alloc] initWithCharacteristic:presenterChar
                                                              service:presenterService];
    
    self.receiver.delegate = self;
    [self.broadcaster startAdvertising];
    
    // Load the order of the screens
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ScreenDefinitions"
                                                     ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    self.definitions = dict[@"screens"];
    
    // The aliases used by the definitions file are stored here
    self.xtypes = @{
                    @"title":    @"TRITitleAndTextScreen",
                    @"text":     @"TRITextScreen",
                    @"photo":    @"TRIPhotoScreen",
                    @"speech":   @"TRISpeechScreen",
                    @"geodesic": @"TRIGeodesicScreen",
                    @"download": @"TRIURLSessionScreen",
                    @"empty":    @"TRIEmptyScreen",
                    };
    
    // We have to start somewhere
    self.currentIndex = 0;

    // Enable and disable toolbar buttons depending on the number of screens
    [self enableButtons];

    [self showCurrentScreen];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self resizeCurrentScreen];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self resizeCurrentScreen];
    self.holderView.hidden = NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation
                                   duration:duration];
    self.holderView.hidden = YES;
}

#pragma mark - IBAction methods

- (IBAction)showMenu:(id)sender
{
    [self.sharePopover dismissPopoverAnimated:YES];
    UITableViewController *contents = nil;
    if (self.screenPopover == nil)
    {
        contents = [[UITableViewController alloc] init];
        contents.tableView.delegate = self;
        contents.tableView.dataSource = self;
        [contents.tableView registerClass:[UITableViewCell class]
                   forCellReuseIdentifier:CELL_REUSE_IDENTIFIER];
        UIPopoverController *popover = nil;
        popover = [[UIPopoverController alloc] initWithContentViewController:contents];
        self.screenPopover = popover;
    }
    else
    {
        contents = (UITableViewController *)self.screenPopover.contentViewController;
    }
    
    if (self.screenPopover.isPopoverVisible)
    {
        [self.screenPopover dismissPopoverAnimated:YES];
    }
    else
    {
        // Present the menu
        [self.screenPopover presentPopoverFromBarButtonItem:self.titleButtonItem
                                   permittedArrowDirections:UIPopoverArrowDirectionAny
                                                   animated:YES];
        
        // Select the current screen on the menu
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentIndex
                                                    inSection:0];
        [contents.tableView selectRowAtIndexPath:indexPath
                                        animated:NO
                                  scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (IBAction)goBack:(id)sender
{
    [self.screenPopover dismissPopoverAnimated:YES];
    [self.sharePopover dismissPopoverAnimated:YES];
    if (self.currentIndex > 0)
    {
        self.currentIndex -= 1;
        [self showCurrentScreen];
        [self resizeCurrentScreen];
        [self enableButtons];
    }
}

- (IBAction)sharePDFFile:(id)sender
{
    [self.screenPopover dismissPopoverAnimated:YES];
    if (self.sharePopover.popoverVisible)
    {
        [self.sharePopover dismissPopoverAnimated:YES];
    }
    else
    {
        [self sharePDF];
    }
}

- (IBAction)showSourceCode:(id)sender
{
    [self.screenPopover dismissPopoverAnimated:YES];
    [self.sharePopover dismissPopoverAnimated:YES];
    
    if (self.currentScreen.enableSourceCodeButton)
    {
        NSAttributedString *sourceCode = [[self currentScreen] tri_sourceCode];
        if (sourceCode)
        {
            self.sourceCodeController = [[TRISourceCodeController alloc] init];
            self.sourceCodeController.sourceCode = sourceCode;
            
            NSString *className = NSStringFromClass([self.currentScreen class]);
            NSString *title = [NSString stringWithFormat:@"%@.m", className];
            self.sourceCodeController.title = title;

            [self presentViewController:self.sourceCodeController
                               animated:YES
                             completion:nil];
        }
    }
}

- (IBAction)goForward:(id)sender
{
    [self.screenPopover dismissPopoverAnimated:YES];
    [self.sharePopover dismissPopoverAnimated:YES];
    if (self.currentIndex < ([self.definitions count] - 1))
    {
        self.currentIndex += 1;
        [self showCurrentScreen];
        [self resizeCurrentScreen];
        [self enableButtons];
    }
}

- (IBAction)generatePDFSnapshot:(id)sender
{
    [self.screenPopover dismissPopoverAnimated:YES];
    [self.sharePopover dismissPopoverAnimated:YES];
    NSString *path = [self PDFFilePath];
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if (exists)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Generate PDF again?"
                                                        message:@"The PDF file already exists. Would you like to re-generate it?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        [alert show];
    }
    else
    {
        [self startGeneratingPDF];
    }
}

#pragma mark - Gesture recognizer code

- (IBAction)swipeLeft:(id)sender
{
    [self goForward:nil];
}

- (IBAction)swipeRight:(id)sender
{
    [self goBack:nil];
}


#pragma mark - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.definitions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:CELL_REUSE_IDENTIFIER
                                           forIndexPath:indexPath];
    NSDictionary *definition = self.definitions[indexPath.row];
    NSInteger index = indexPath.row + 1;
    NSString *title = (definition[@"title"]) ? definition[@"title"] : @"";
    NSString *text = [NSString stringWithFormat:@"%ld. %@", (long)index, title];
    cell.textLabel.text = text;
    return cell;
}

-       (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.screenPopover dismissPopoverAnimated:YES];
    self.currentIndex = indexPath.row;
    [self showCurrentScreen];
    [self resizeCurrentScreen];
    [self enableButtons];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.generatingPDFAlert)
    {
        // This alert allows the user to cancel the PDF generation
        if (buttonIndex == 0)
        {
            self.continuePDFGeneration = NO;
        }
    }
    else
    {
        // This is the "re-generate PDF?" alert shown
        // when the file already exists
        if (buttonIndex != 0)
        {
            [self startGeneratingPDF];
        }
    }
}

#pragma mark - TRIReceiverDelegate methods

- (void)receiver:(TRIReceiver *)receiver didReceiveMessage:(NSString *)message
{
    if ([message isEqualToString:MESSAGE_NEXT])
    {
        [self goForward:nil];
    }
    else if ([message isEqualToString:MESSAGE_PREVIOUS])
    {
        [self goBack:nil];
    }
    else if ([message isEqualToString:MESSAGE_RESET])
    {
        self.currentIndex = 0;
        [self showCurrentScreen];
        [self resizeCurrentScreen];
        [self enableButtons];
    }
    else if ([message isEqualToString:MESSAGE_SHOW_SOURCE])
    {
        [self showSourceCode:nil];
    }
    else if ([message isEqualToString:MESSAGE_HIDE_SOURCE])
    {
        [self.sourceCodeController dismissViewControllerAnimated:YES
                                                      completion:NO];
    }
    else if ([message isEqualToString:MESSAGE_TOGGLE_MENU])
    {
        [self showMenu:nil];
    }
    [self.broadcaster send:[NSString stringWithFormat:@"echo: %@", message]];
}

#pragma mark - TRIBroadcasterDelegate methods

- (void)broadcasterIsReady:(TRIBroadcaster *)broadcaster
{
    [self.broadcaster send:@"BOOM"];
}

#pragma mark - Private methods

- (void)showCurrentScreen
{
    if (self.currentScreen != nil)
    {
        [self.currentScreen.view removeFromSuperview];
        self.currentScreen = nil;
    }

    NSDictionary *definition = self.definitions[self.currentIndex];
    NSString *className = self.xtypes[definition[@"xtype"]];
    Class klass = NSClassFromString(className);
    if (klass)
    {
        self.currentScreen = [[klass alloc] initWithDefinition:definition];
        [self.holderView addSubview:self.currentScreen.view];
        
        self.titleButtonItem.title = self.currentScreen.title;
    }
    else
    {
        self.titleButtonItem.title = @"Invalid screen";
    }
}

- (void)resizeCurrentScreen
{
    self.currentScreen.view.frame = self.holderView.bounds;
}

- (void)enableButtons
{
    self.previousScreenButton.enabled = self.currentIndex > 0;
    self.nextScreenButton.enabled = self.currentIndex < ([self.definitions count] - 1);
    self.sourceCodeButton.enabled = self.currentScreen.enableSourceCodeButton;

    NSString *path = [self PDFFilePath];
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    self.shareButton.enabled = exists;
}

#pragma mark - PDF-related methods

- (void)startGeneratingPDF
{
    // This method launches an asynchronous processing, that will
    // cycle through every screen and take a snapshot image of each.
    // Then a PDF will be created with the result of the operation, and users
    // will be able to share that PDF with other apps.
    self.continuePDFGeneration = YES;
    self.generatingPDFAlert = [[UIAlertView alloc] initWithTitle:@"Processing"
                                                         message:@"The PDF is being composed…"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:nil];
    [self.generatingPDFAlert show];
    [self.screenPopover dismissPopoverAnimated:YES];
    self.filenamesForPDF = [NSMutableArray array];
    self.currentIndex = 0;
    [self showCurrentScreen];
    [self resizeCurrentScreen];
    [self enableButtons];
    [self takeSnapshotOfCurrentScreen];
}

- (void)takeSnapshotOfCurrentScreen
{
    // We flash the screen and then create an image out of it
    if (self.continuePDFGeneration)
    {
        [self.currentScreen flashAndThen:^{
            CGRect bounds = self.currentScreen.view.bounds;
            
            // Get the current image of the current drawing
            UIGraphicsBeginImageContext(bounds.size);
            
            [self.currentScreen.view.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
            NSData *data = UIImagePNGRepresentation(viewImage);
            NSString *filename = [NSString stringWithFormat:@"image_%ld.png", (long)self.currentIndex];
            [self.filenamesForPDF addObject:filename];
            NSString *path = [[self tempDirectory] stringByAppendingPathComponent:filename];
            [data writeToFile:path
                   atomically:NO];
            UIGraphicsEndImageContext();
            
            if (self.currentScreen.enableSourceCodeButton)
            {
                // The current screen has source code to show. Let's
                // add that to the PDF too!
                NSString *className = NSStringFromClass([self.currentScreen class]);
                NSString *htmlFilename = [NSString stringWithFormat:@"html/%@.m", className];
                [self.filenamesForPDF addObject:htmlFilename];
            }
            
            BOOL moreScreensLeft = self.currentIndex < ([self.definitions count] - 1);
            if (moreScreensLeft && self.continuePDFGeneration)
            {
                self.currentIndex += 1;
                [self showCurrentScreen];
                [self resizeCurrentScreen];
                [self enableButtons];
                [self performSelector:@selector(takeSnapshotOfCurrentScreen)
                           withObject:nil
                           afterDelay:self.currentScreen.delayForSnapshot];
            }
            else
            {
                [self mergeSnapshotsInPDF];
            }
        }];
    }
}

- (void)mergeSnapshotsInPDF
{
    // Prepare a PDF context
    CGRect bounds = self.currentScreen.view.bounds;
    NSString *path = [self PDFFilePath];
    UIGraphicsBeginPDFContextToFile(path, CGRectZero, nil);
    
    for (NSString *filename in self.filenamesForPDF)
    {
        if ([filename hasSuffix:@".png"])
        {
            // It's an image!
            NSString *path = [[self tempDirectory] stringByAppendingPathComponent:filename];
            
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            UIGraphicsBeginPDFPageWithInfo(bounds, nil);
            
            CGContextRef currentContext = UIGraphicsGetCurrentContext();
            
            // PDF contexts have an inverted coordinate system,
            // which means we have to make a transformation before drawing
            CGContextTranslateCTM(currentContext, 0, bounds.size.height);
            CGContextScaleCTM(currentContext, 1.0, -1.0);
            
            // Draw the image in the PDF file
            CGContextDrawImage(currentContext, bounds, image.CGImage);
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
                        UIGraphicsBeginPDFPageWithInfo(bounds, nil);
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
    
    self.continuePDFGeneration = NO;
    [self.generatingPDFAlert dismissWithClickedButtonIndex:0
                                                  animated:YES];
    
    [self enableButtons];
    [self sharePDF];
}

- (CFRange)renderPage:(NSInteger)pageNum
        withTextRange:(CFRange)currentRange
       andFramesetter:(CTFramesetterRef)framesetter
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    CGRect bounds = CGRectInset(self.currentScreen.view.bounds, 50, 50);
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

- (void)sharePDF
{
    if (self.sharePopover == nil)
    {
        NSURL *url = [NSURL fileURLWithPath:[self PDFFilePath]];
        NSArray *objs = @[ url ];
        
        TRIOpenInAppActivity *activity = [[TRIOpenInAppActivity alloc] initWithView:self.view
                                                                   andBarButtonItem:self.shareButton];
        NSArray *activities = @[ activity ];
        
        UIActivityViewController *controller = nil;
        controller = [[UIActivityViewController alloc] initWithActivityItems:objs
                                                       applicationActivities:activities];
        NSArray *excludedActivities = @[
                                        UIActivityTypePostToTwitter,
                                        UIActivityTypePostToFacebook,
                                        UIActivityTypePostToWeibo,
                                        UIActivityTypeCopyToPasteboard,
                                        UIActivityTypeSaveToCameraRoll,
                                        UIActivityTypeAddToReadingList,
                                        UIActivityTypePostToFlickr,
                                        UIActivityTypePostToVimeo,
                                        UIActivityTypePostToTencentWeibo,
                                        ];
        controller.excludedActivityTypes = excludedActivities;
        
        self.sharePopover = [[UIPopoverController alloc] initWithContentViewController:controller];
        
        activity.superViewController = self.sharePopover;
    }
    [self.sharePopover presentPopoverFromBarButtonItem:self.shareButton
                              permittedArrowDirections:UIPopoverArrowDirectionAny
                                              animated:YES];
}

- (NSString *)tempDirectory
{
    return NSTemporaryDirectory();
}

- (NSString *)documentsDirectory
{
    static NSString *documentsPath;
    if (documentsPath == nil)
    {
        NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,
                                                             YES);
        documentsPath = [array lastObject];
    }
    return documentsPath;
}

- (NSString *)PDFFilePath
{
    NSString *path = [self.documentsDirectory stringByAppendingPathComponent:PDF_FILENAME];
    return path;
}

@end

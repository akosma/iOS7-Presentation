//
//  TRINavigationController.m
//  Presentation
//
//  Created by Adrian on 13/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "NSObject+TRISourceCode.h"
#import "TRINavigationController.h"
#import "TRIBaseScreenController.h"
#import "TRISourceCodeController.h"


static NSString *CELL_REUSE_IDENTIFIER = @"CELL_REUSE_IDENTIFIER";



@interface TRINavigationController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *definitions;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, strong) TRIBaseScreenController *currentScreen;
@property (nonatomic, strong) UIPopoverController *screenPopover;
@property (nonatomic, strong) NSDictionary *xtypes;
@property (nonatomic, strong) NSMutableArray *filenamesForPDF;
@property (nonatomic, strong) UIAlertView *generatingPDFAlert;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleButtonItem;
@property (weak, nonatomic) IBOutlet UIView *holderView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousScreenButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextScreenButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sourceCodeButton;

@end



@implementation TRINavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    // Present the menu
    [self.screenPopover presentPopoverFromBarButtonItem:sender
                               permittedArrowDirections:UIPopoverArrowDirectionAny
                                               animated:YES];
    
    // Select the current screen on the menu
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentIndex
                                                inSection:0];
    [contents.tableView selectRowAtIndexPath:indexPath
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionMiddle];
}

- (IBAction)goBack:(id)sender
{
    [self.screenPopover dismissPopoverAnimated:YES];
    if (self.currentIndex > 0)
    {
        self.currentIndex -= 1;
        [self showCurrentScreen];
        [self resizeCurrentScreen];
        [self enableButtons];
    }
}

- (IBAction)goHome:(id)sender
{
    [self.screenPopover dismissPopoverAnimated:YES];
}

- (IBAction)showSourceCode:(id)sender
{
    [self.screenPopover dismissPopoverAnimated:YES];
    NSAttributedString *sourceCode = [[self currentScreen] tri_sourceCode];
    if (sourceCode)
    {
        TRISourceCodeController *controller = nil;
        controller = [[TRISourceCodeController alloc] init];
        controller.sourceCode = sourceCode;
        
        NSString *className = NSStringFromClass([self.currentScreen class]);
        NSString *title = [NSString stringWithFormat:@"%@.m", className];
        controller.title = title;

        [self presentViewController:controller
                           animated:YES
                         completion:nil];
    }
}

- (IBAction)goForward:(id)sender
{
    [self.screenPopover dismissPopoverAnimated:YES];
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
    self.generatingPDFAlert = [[UIAlertView alloc] initWithTitle:@"Processing"
                                                         message:@"The PDF is being composed…"
                                                        delegate:nil
                                               cancelButtonTitle:nil
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
    NSString *title = definition[@"title"];
    NSString *text = [NSString stringWithFormat:@"%d. %@", index, title];
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

#pragma mark - Private methods

- (void)showCurrentScreen
{
    if (self.currentScreen != nil)
    {
        [self.currentScreen viewWillDisappear:NO];
        [self.currentScreen.view removeFromSuperview];
        [self.currentScreen viewDidDisappear:NO];
        self.currentScreen = nil;
    }

    NSDictionary *definition = self.definitions[self.currentIndex];
    NSString *className = self.xtypes[definition[@"xtype"]];
    Class klass = NSClassFromString(className);
    if (klass)
    {
        self.currentScreen = [[klass alloc] initWithDefinition:definition];
        [self.currentScreen viewWillAppear:NO];
        [self.holderView addSubview:self.currentScreen.view];
        [self.currentScreen viewDidAppear:NO];
        
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

- (void)takeSnapshotOfCurrentScreen
{
    [self.currentScreen flashAndThen:^{
        CGRect bounds = self.currentScreen.view.bounds;
        
        // Get the current image of the current drawing
        UIGraphicsBeginImageContext(bounds.size);
        
        [self.currentScreen.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        NSData *data = UIImagePNGRepresentation(viewImage);
        NSString *filename = [NSString stringWithFormat:@"image_%d.png", self.currentIndex];
        [self.filenamesForPDF addObject:filename];
        NSString *path = [self.documentsDirectory stringByAppendingPathComponent:filename];
        [data writeToFile:path
               atomically:NO];
        UIGraphicsEndImageContext();
        
        BOOL moreScreensLeft = self.currentIndex < ([self.definitions count] - 1);
        if (moreScreensLeft)
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

- (void)mergeSnapshotsInPDF
{
    // Prepare a PDF context
    CGRect bounds = self.currentScreen.view.bounds;
    NSString *path = [self.documentsDirectory stringByAppendingPathComponent:@"slides.pdf"];
    UIGraphicsBeginPDFContextToFile(path, CGRectZero, nil);
    
    for (NSString *filename in self.filenamesForPDF)
    {
        NSString *path = [self.documentsDirectory stringByAppendingPathComponent:filename];
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
    
    UIGraphicsEndPDFContext();
    
    [self.generatingPDFAlert dismissWithClickedButtonIndex:0
                                                  animated:YES];
}

@end

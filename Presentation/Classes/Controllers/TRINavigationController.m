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

@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleButtonItem;
@property (weak, nonatomic) IBOutlet UIView *holderView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousScreenButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextScreenButton;

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
    
    // We have to start somewhere
    self.currentIndex = 0;

    // Enable and disable toolbar buttons depending on the number of screens
    [self enableButtons];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showCurrentScreen];
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
}

- (IBAction)showSourceCode:(id)sender
{
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
    if (self.currentIndex < ([self.definitions count] - 1))
    {
        self.currentIndex += 1;
        [self showCurrentScreen];
        [self resizeCurrentScreen];
        [self enableButtons];
    }
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
    NSString *className = definition[@"class"];
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
}

@end

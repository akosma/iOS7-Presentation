//
//  TRIRemoteViewController.m
//  Presentation
//
//  Created by Adrian on 14/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRIRemoteViewController.h"
#import "TRIMenuController.h"
#import "TRIMenuControllerDelegate.h"
#import "TRIHelpers.h"

@interface TRIRemoteViewController () <TRIReceiverDelegate,
                                       TRIMenuControllerDelegate,
                                       UIActionSheetDelegate>

@property (nonatomic, strong) TRIBroadcaster *broadcaster;
@property (nonatomic, strong) TRIReceiver *receiver;
@property (nonatomic, strong) UINavigationController *menu;
@property (nonatomic, strong) NSArray *definitions;
@property (nonatomic, getter = isReady) BOOL ready;
@property (nonatomic) NSInteger currentIndex;

@property (weak, nonatomic) IBOutlet UILabel *nextSlideLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentSlideLabel;
@property (weak, nonatomic) IBOutlet UIView *nextSlideView;
@property (weak, nonatomic) IBOutlet UIView *currentSlideView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *optionsButton;

@end

@implementation TRIRemoteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.ready = NO;
    self.nextSlideLabel.text = @"";
    self.currentSlideLabel.text = @"";
    self.nextSlideView.hidden = YES;
    self.currentSlideView.hidden = YES;
    self.optionsButton.enabled = NO;

    CBUUID *remoteControlChar = [CBUUID UUIDWithString:REMOTE_CONTROL_CHARACTERISTIC_UUID];
    CBUUID *remoteControlService = [CBUUID UUIDWithString:REMOTE_CONTROL_SERVICE_UUID];
    self.broadcaster = [[TRIBroadcaster alloc] initWithCharacteristic:remoteControlChar
                                                              service:remoteControlService];
    
    CBUUID *presenterChar = [CBUUID UUIDWithString:PRESENTER_CHARACTERISTIC_UUID];
    CBUUID *presenterService = [CBUUID UUIDWithString:PRESENTER_SERVICE_UUID];
    self.receiver = [[TRIReceiver alloc] initWithCharacteristic:presenterChar
                                                        service:presenterService];
    
    self.receiver.delegate = self;
    
    [self addObserver:self
           forKeyPath:@"currentIndex"
              options:0
              context:NULL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.broadcaster startAdvertising];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    self.currentSlideLabel.text = self.definitions[self.currentIndex][@"title"];
    
    if (self.currentIndex < ([self.definitions count] - 1))
    {
        NSInteger nextIndex = (self.currentIndex + 1);
        self.nextSlideLabel.text = self.definitions[nextIndex][@"title"];
    }
    else
    {
        self.nextSlideLabel.text = @"(end of presentation)";
    }
}

#pragma mark - IBActions

- (IBAction)showOptions:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:@"Reset Presentation"
                                              otherButtonTitles:@"Show menu", @"Show Source Code", @"Hide Source Code", nil];
    [sheet showInView:self.view];
}

- (IBAction)next:(id)sender
{
    if (self.currentIndex < ([self.definitions count] - 1))
    {
        self.currentIndex += 1;
        [self.broadcaster sendText:MESSAGE_NEXT];
    }
}

- (IBAction)previous:(id)sender
{
    if (self.currentIndex > 0)
    {
        self.currentIndex -= 1;
        [self.broadcaster sendText:MESSAGE_PREVIOUS];
    }
}

- (void)closeLocalMenu:(id)sender
{
    [self.menu dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Gesture recognizer methods

- (IBAction)doubleTap:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateRecognized)
    {
        [self.broadcaster sendText:MESSAGE_EXECUTE];
    }
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
        {
            self.currentIndex = 0;
            [self.broadcaster sendText:MESSAGE_RESET];
            break;
        }
            
        case 1:
        {
            [self presentViewController:self.menu
                               animated:YES
                             completion:nil];
            break;
        }

        case 2:
        {
            [self.broadcaster sendText:MESSAGE_SHOW_SOURCE];
            break;
        }
            
        case 3:
        {
            [self.broadcaster sendText:MESSAGE_HIDE_SOURCE];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - TRIMenuControllerDelegate methods

- (void)menuController:(TRIMenuController *)menuController didSelectItemAtIndex:(NSInteger)index
{
    self.currentIndex = index;
    [self.broadcaster sendText:[@(index) description]];
}

#pragma mark - TRIReceiverDelegate methods

- (void)receiver:(TRIReceiver *)receiver didReceiveData:(NSData *)data
{
    // As soon as it is connected, the receiver gets the list of the screens
    // that will be shown by the presenter
    
    NSPropertyListFormat format = NSPropertyListXMLFormat_v1_0;
    
    NSError *error = nil;
    
    self.definitions = [NSPropertyListSerialization propertyListWithData:data
                                                                 options:0
                                                                  format:&format
                                                                   error:&error];
    
    if (error == nil)
    {
        // We just need to execute this once
        receiver.delegate = nil;

        
        TRIMenuController *menu = [[TRIMenuController alloc] initWithDefinitions:self.definitions];
        menu.title = @"Presentation Screens";
        menu.delegate = self;
        
        self.menu = [[UINavigationController alloc] initWithRootViewController:menu];
        
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                     target:self
                                                                                     action:@selector(closeLocalMenu:)];
        menu.navigationItem.rightBarButtonItem = closeButton;
        
        // Prepare the UI
        self.currentSlideView.hidden = NO;
        self.nextSlideView.hidden = NO;
        self.optionsButton.enabled = YES;
        self.currentIndex = 0;
    }
}

@end

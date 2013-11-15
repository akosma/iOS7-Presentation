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
                                       TRIMenuControllerDelegate>

@property (nonatomic, strong) TRIBroadcaster *broadcaster;
@property (nonatomic, strong) TRIReceiver *receiver;
@property (nonatomic, strong) UINavigationController *menu;
@property (nonatomic, strong) NSArray *definitions;

@end

@implementation TRIRemoteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    CBUUID *remoteControlChar = [CBUUID UUIDWithString:REMOTE_CONTROL_CHARACTERISTIC_UUID];
    CBUUID *remoteControlService = [CBUUID UUIDWithString:REMOTE_CONTROL_SERVICE_UUID];
    self.broadcaster = [[TRIBroadcaster alloc] initWithCharacteristic:remoteControlChar
                                                              service:remoteControlService];
    
    CBUUID *presenterChar = [CBUUID UUIDWithString:PRESENTER_CHARACTERISTIC_UUID];
    CBUUID *presenterService = [CBUUID UUIDWithString:PRESENTER_SERVICE_UUID];
    self.receiver = [[TRIReceiver alloc] initWithCharacteristic:presenterChar
                                                        service:presenterService];
    
    self.receiver.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.broadcaster startAdvertising];
}

#pragma mark - IBActions

- (IBAction)reset:(id)sender
{
    [self.broadcaster sendText:MESSAGE_RESET];
}

- (IBAction)next:(id)sender
{
    [self.broadcaster sendText:MESSAGE_NEXT];
}

- (IBAction)previous:(id)sender
{
    [self.broadcaster sendText:MESSAGE_PREVIOUS];
}

- (IBAction)showSource:(id)sender
{
    [self.broadcaster sendText:MESSAGE_SHOW_SOURCE];
}

- (IBAction)hideSource:(id)sender
{
    [self.broadcaster sendText:MESSAGE_HIDE_SOURCE];
}

- (IBAction)toggleMenu:(id)sender
{
    [self.broadcaster sendText:MESSAGE_TOGGLE_MENU];
}

- (IBAction)showLocalMenu:(id)sender
{
    if (self.menu != nil)
    {
        [self presentViewController:self.menu
                           animated:YES
                         completion:nil];
    }
}

- (IBAction)closeLocalMenu:(id)sender
{
    [self.menu dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TRIMenuControllerDelegate methods

- (void)menuController:(TRIMenuController *)menuController didSelectItemAtIndex:(NSInteger)index
{
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
    }
}

@end

//
//  TRIRemoteViewController.m
//  Presentation
//
//  Created by Adrian on 14/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRIRemoteViewController.h"
#import "TRIHelpers.h"

@interface TRIRemoteViewController () <TRIReceiverDelegate>

@property (nonatomic, strong) TRIBroadcaster *broadcaster;
@property (nonatomic, strong) TRIReceiver *receiver;

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
    [self.broadcaster send:MESSAGE_RESET];
}

- (IBAction)next:(id)sender
{
    [self.broadcaster send:MESSAGE_NEXT];
}

- (IBAction)previous:(id)sender
{
    [self.broadcaster send:MESSAGE_PREVIOUS];
}

- (IBAction)showSource:(id)sender
{
    [self.broadcaster send:MESSAGE_SHOW_SOURCE];
}

- (IBAction)hideSource:(id)sender
{
    [self.broadcaster send:MESSAGE_HIDE_SOURCE];
}

- (IBAction)toggleMenu:(id)sender
{
    [self.broadcaster send:MESSAGE_TOGGLE_MENU];
}

#pragma mark - TRIReceiverDelegate methods

- (void)receiver:(TRIReceiver *)receiver didReceiveMessage:(NSString *)message
{
    NSLog(@"received in iPhone: %@", message);
}

@end

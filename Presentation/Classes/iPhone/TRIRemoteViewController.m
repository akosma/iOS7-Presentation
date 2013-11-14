//
//  TRIRemoteViewController.m
//  Presentation
//
//  Created by Adrian on 14/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRIRemoteViewController.h"
#import "TRIBroadcaster.h"

@interface TRIRemoteViewController ()

@end

@implementation TRIRemoteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[TRIBroadcaster broadcaster] startAdvertising];
}

#pragma mark - IBActions

- (IBAction)reset:(id)sender
{
    [[TRIBroadcaster broadcaster] sendReset];
}

- (IBAction)next:(id)sender
{
    [[TRIBroadcaster broadcaster] sendNext];
}

- (IBAction)previous:(id)sender
{
    [[TRIBroadcaster broadcaster] sendPrevious];
}

- (IBAction)showSource:(id)sender
{
    [[TRIBroadcaster broadcaster] sendShowSource];
}

- (IBAction)hideSource:(id)sender
{
    [[TRIBroadcaster broadcaster] sendHideSource];
}

- (IBAction)toggleMenu:(id)sender
{
    [[TRIBroadcaster broadcaster] sendToggleMenu];
}

@end

//
//  TRIAppDelegate.m
//  Presentation
//
//  Created by Adrian on 13/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRIAppDelegate.h"
#import "TRIPresentationController.h"
#import "TRIRemoteViewController.h"

@interface TRIAppDelegate ()

@property (nonatomic, strong) UIViewController *rootController;

@end


@implementation TRIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // This apps prevent the devices from going to sleep
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.rootController = [[TRIPresentationController alloc] init];
    }
    else
    {
        self.rootController = [[TRIRemoteViewController alloc] init];
    }
    
    self.window.rootViewController = self.rootController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end

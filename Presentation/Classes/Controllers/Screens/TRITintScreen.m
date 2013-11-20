//
//  TRITintScreen.m
//  Presentation
//
//  Created by Adrian on 20/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRITintScreen.h"

@interface TRITintScreen ()

@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (weak, nonatomic) IBOutlet UITabBarItem *contactsItem;
@property (weak, nonatomic) IBOutlet UISegmentedControl *colorSwitch;

@end

@implementation TRITintScreen

+ (NSString *)xtype
{
    return @"tint";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tabBar.selectedItem = self.contactsItem;
}

- (void)performMainScreenAction
{
    self.colorSwitch.selectedSegmentIndex = 0;
}

- (IBAction)changeTint:(id)sender
{
    NSInteger index = [sender selectedSegmentIndex];
    switch (index)
    {
        case 0:
            self.view.tintColor = [UIColor purpleColor];
            break;
            
        case 1:
            self.view.tintColor = [UIColor blackColor];
            break;
            
        case 2:
            self.view.tintColor = [UIColor orangeColor];
            break;
            
        case 3:
            self.view.tintColor = [UIColor greenColor];
            break;
            
        default:
            break;
    }
}

@end

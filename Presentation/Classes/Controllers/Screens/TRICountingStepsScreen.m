//
//  TRICountingStepsScreen.m
//  Presentation
//
//  Created by Adrian on 19/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

@import CoreMotion;


#import "TRICountingStepsScreen.h"



@interface TRICountingStepsScreen ()

@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property (strong, nonatomic) CMStepCounter *stepCounter;
@property (nonatomic) NSOperationQueue *queue;

@end



@implementation TRICountingStepsScreen

+ (NSString *)xtype
{
    return @"steps";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([CMStepCounter isStepCountingAvailable])
    {
        self.stepCounter = [[CMStepCounter alloc] init];
        
        self.queue = [NSOperationQueue mainQueue];
    }
    else
    {
        self.stepsLabel.text = @"Step counting not available in this device";
    }
}

- (IBAction)startCountingSteps:(id)sender
{
    CMStepUpdateHandler handler = ^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
        self.stepsLabel.text = [NSString stringWithFormat:@"Steps: %ld", (long)numberOfSteps];
    };
    self.stepsLabel.text = @"";
    [self.stepCounter startStepCountingUpdatesToQueue:self.queue
                                             updateOn:1
                                          withHandler:handler];
}

- (IBAction)stopCountingSteps:(id)sender
{
    [self.stepCounter stopStepCountingUpdates];
}

@end

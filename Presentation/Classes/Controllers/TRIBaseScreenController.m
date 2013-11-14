//
//  TRIBaseScreenController.m
//  Presentation
//
//  Created by Adrian on 13/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRIBaseScreenController.h"

@interface TRIBaseScreenController ()

@property (nonatomic, strong) UIView *snapshotFlashView;

@end


@implementation TRIBaseScreenController

- (instancetype)initWithDefinition:(NSDictionary *)definition
{
    if (self = [super init])
    {
        self.definition = definition;
        self.enableSourceCodeButton = NO;
        self.delayForSnapshot = 0.75;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.definition[@"title"];
}

#pragma mark - Public methods

- (void)flashAndThen:(TRIBaseScreenControllerFlashCallback)callback
{
    self.snapshotFlashView.alpha = 1.0;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.6
                     animations:^{
                         weakSelf.snapshotFlashView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         if (finished)
                         {
                             callback();
                         }
                     }];
}

#pragma mark - Lazy getter

- (UIView *)snapshotFlashView
{
    if (_snapshotFlashView == nil)
    {
        _snapshotFlashView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 1024)];
        _snapshotFlashView.backgroundColor = [UIColor whiteColor];
        _snapshotFlashView.center = self.view.center;
        _snapshotFlashView.alpha = 0.0;
        [self.view addSubview:self.snapshotFlashView];
    }
    return _snapshotFlashView;
}

@end

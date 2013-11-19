//
//  TRIBaseScreenController.m
//  Presentation
//
//  Created by Adrian on 13/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRIBaseScreenController.h"
#import "TRIHelpers.h"


@interface TRIBaseScreenController ()

@property (nonatomic, strong) UIView *snapshotFlashView;

@end


@implementation TRIBaseScreenController

+ (NSString *)xtype
{
    // Subclasses must override this method, returning a specific
    // xtype used in the JSON screen definition file, read at
    // application startup by the presentation controller.
    return @"invalid";
}

- (instancetype)initWithDefinition:(NSDictionary *)definition
{
    if (self = [super init])
    {
        self.definition = definition;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *title = self.definition[@"title"];
    self.title = (title) ? title : @"";

    NSNumber *enableDemo = self.definition[@"demo"];
    self.enableSourceCodeButton = [enableDemo boolValue];

    NSNumber *delay = self.definition[@"delay"];
    self.delayForSnapshot = (delay) ? [delay floatValue] : 0.75;

    if (self.definition[@"backgroundColor"])
    {
        NSString *string = self.definition[@"backgroundColor"];
        UIColor *color = [UIColor colorWithHexString:string];
        self.view.backgroundColor = color;
    }
}

#pragma mark - Public methods

- (void)performMainScreenAction
{
    // Subclasses implement this to allow the remote control to
    // trigger any animation or demo as required
}

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

- (void)saveTempSnapshotWithFilename:(NSString *)filename
{
    // Get the current image of the current drawing
    CGRect bounds = self.view.bounds;
    UIGraphicsBeginImageContext(bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // Save the file on the temporary folder
    NSData *data = UIImagePNGRepresentation(viewImage);
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    [data writeToFile:path
           atomically:NO];
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

//
//  TRIQRCodeScreen.m
//  Presentation
//
//  Created by Adrian on 18/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRIQRCodeScreen.h"

@import AVFoundation;


@interface TRIQRCodeScreen () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end


@implementation TRIQRCodeScreen

+ (NSString *)xtype
{
    return @"qrcode";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Adapted from
    // http://www.renaudpradenc.com/?p=453
    self.session = [[AVCaptureSession alloc] init];
    AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
    if(videoInput)
    {
        [self.session addInput:videoInput];
    }
    else
    {
        NSLog(@"Error: %@", error);
    }
    
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.session addOutput:metadataOutput];
    [metadataOutput setMetadataObjectsDelegate:self
                                         queue:dispatch_get_main_queue()];
    [metadataOutput setMetadataObjectTypes:@[ AVMetadataObjectTypeQRCode ]];
    
    AVCaptureVideoPreviewLayer *preview = nil;
    preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    preview.frame = self.previewView.bounds;
    [self.previewView.layer addSublayer:preview];
    
    [self.session startRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

-    (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
          fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataObject *metadata in metadataObjects)
    {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode])
        {
            NSString *code = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            self.textView.text = code;
            break;
        }
    }
    
}

@end

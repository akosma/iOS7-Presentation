//
//  TRISmileScreen.m
//  Presentation
//
//  Created by Adrian on 19/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRISmileScreen.h"


@import AVFoundation;
@import CoreImage;



@interface TRISmileScreen () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureVideoDataOutput *output;
@property (nonatomic, strong) CIDetector *detector;
@property (nonatomic) dispatch_queue_t queue;

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation TRISmileScreen

+ (NSString *)xtype
{
    return @"smile";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Adapted from
    // http://www.renaudpradenc.com/?p=453
    self.session = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [self cameraWithPosition:AVCaptureDevicePositionFront];
    
    if(device != nil)
    {
        // Set the input object
        NSError *error = nil;
        AVCaptureDeviceInput *input = nil;
        input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                      error:&error];
        
        if (error == nil)
        {
            if ([self.session canAddInput:input])
            {
                [self.session addInput:input];
            }
            
            // Create a detector object
            NSDictionary *options = @{
                                      CIDetectorTracking: @YES,
                                      CIDetectorAccuracy: CIDetectorAccuracyLow
                                      };
            self.detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                               context:nil
                                               options:options];
            
            // Create an output object
            self.output = [[AVCaptureVideoDataOutput alloc] init];
            
            self.queue = dispatch_queue_create("VideoDataOutputQueue", NULL);
            [self.output setSampleBufferDelegate:self
                                           queue:self.queue];
            
            if ([self.session canAddOutput:self.output])
            {
                [self.session addOutput:self.output];
            }
            
            // Create a preview layer
            self.previewLayer = nil;
            self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
            self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            self.previewLayer.frame = self.previewView.bounds;
            [self.previewView.layer addSublayer:self.previewLayer];
            [self setPreviewOrientation];

            // Get those codes!
            [self.session startRunning];
        }
        else
        {
            NSLog(@"Error: %@", error);
        }
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self setPreviewOrientation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.output setSampleBufferDelegate:nil queue:nil];
    self.output = nil;
    [self.session stopRunning];
    self.session = nil;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    CVPixelBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *image = [[CIImage alloc] initWithCVPixelBuffer:buffer];

    NSArray *features = [self.detector featuresInImage:image
                                               options:@{ CIDetectorSmile: @YES }];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        BOOL detected = NO;
        NSString *text = @"";
        for (CIFeature *feature in features)
        {
            if ([feature isKindOfClass:[CIFaceFeature class]])
            {
                CIFaceFeature *faceFeature = (CIFaceFeature *)feature;
                if (faceFeature.hasSmile)
                {
                    detected = YES;
                    text = @"Smiling! :)";
                    break;
                }
            }
        }
        
        if (detected)
        {
            self.textView.text = text;
            self.textView.backgroundColor = [UIColor greenColor];
        }
        else
        {
            self.textView.text = @"Not smiling :(";
            self.textView.backgroundColor = [UIColor redColor];
        }
    });
}

#pragma mark - Private methods

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if (device.position == position)
        {
            return device;
        }
    }
    return nil;
}

- (void)setPreviewOrientation
{
    AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationPortrait;
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        orientation = AVCaptureVideoOrientationLandscapeLeft;
    }
    else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        orientation = AVCaptureVideoOrientationLandscapeRight;
    }
    else if (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        orientation = AVCaptureVideoOrientationPortraitUpsideDown;
    }
    self.previewLayer.connection.videoOrientation = orientation;
}

@end

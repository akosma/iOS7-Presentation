//
//  TRIURLSessionScreen.m
//  Presentation
//
//  Created by Adrian on 14/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

#import "TRIURLSessionScreen.h"

static NSString *HUGE_WIKIPEDIA_IMAGE = @"http://upload.wikimedia.org/wikipedia/commons/9/9e/Paul_Gabri%C3%ABl_-_Landscape_with_a_train_-_Google_Art_Project.jpg";


@interface TRIURLSessionScreen () <NSURLSessionDownloadDelegate>

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *completedLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (nonatomic) int64_t total;
@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic, strong) NSProgress *progress;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation TRIURLSessionScreen

+ (NSString *)xtype
{
    return @"download";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.total = 0;
    self.progressView.progress = 0.0;
    self.totalLabel.text = @"";
    self.completedLabel.text = @"";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self launchDownload:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.session invalidateAndCancel];
}

- (void)performMainScreenAction
{
    [self.session invalidateAndCancel];
    [self launchDownload:nil];
}

#pragma mark - IBAction methods

- (IBAction)launchDownload:(id)sender
{
    // Session configuration
    NSString *name = @"com.trifork.BackgroundDownloadSession";
    NSURLSessionConfiguration *conf = nil;
    conf = [NSURLSessionConfiguration backgroundSessionConfiguration:name];
    self.session = [NSURLSession sessionWithConfiguration:conf
                                                 delegate:self
                                            delegateQueue:nil];

    // Download task
    NSURL *url = [NSURL URLWithString:HUGE_WIKIPEDIA_IMAGE];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.task = [self.session downloadTaskWithRequest:request];
    [self.task resume];
    
    // Progress object
    self.progress = [NSProgress progressWithTotalUnitCount:100];
    [self.progress addObserver:self
                    forKeyPath:@"completedUnitCount"
                       options:0
                       context:NULL];

    // Prepare the UI
    self.total = 0;
    self.progressView.progress = 0.0;
    self.totalLabel.text = @"";
    self.completedLabel.text = @"";
}

- (IBAction)cancel:(id)sender
{
    [self.session invalidateAndCancel];
}

- (IBAction)resume:(id)sender
{
    [self.task resume];
}

- (IBAction)suspend:(id)sender
{
    [self.task suspend];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.progress
        && [keyPath isEqualToString:@"completedUnitCount"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            int64_t count = self.progress.completedUnitCount;
            self.progressView.progress = (float)count / 100.0f;
            self.totalLabel.text = [NSString stringWithFormat:@"%lld MB", self.total / 1024 / 1024];
            self.completedLabel.text = [NSString stringWithFormat:@"%lld %%", count];
        });
    }
}

#pragma mark - NSURLSessionDownloadDelegate methods

-        (void)URLSession:(NSURLSession *)session
             downloadTask:(NSURLSessionDownloadTask *)downloadTask
             didWriteData:(int64_t)bytesWritten
        totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if (self.total == 0)
    {
        self.total = totalBytesExpectedToWrite;
    }
    self.progress.completedUnitCount = totalBytesWritten * 100 / totalBytesExpectedToWrite;
}



-        (void)URLSession:(NSURLSession *)session
             downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
}



- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
}


@end

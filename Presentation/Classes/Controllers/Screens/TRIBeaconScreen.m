//
//  TRIBeaconScreen.m
//  Presentation
//
//  Created by Adrian on 16/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

@import CoreLocation;

#import "TRIBeaconScreen.h"


static NSString *RASPBERRY_PI_UUID = @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0";


@interface TRIBeaconScreen () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, strong) CLBeaconRegion *region;

@property (weak, nonatomic) IBOutlet UILabel *foundLabel;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *majorLabel;
@property (weak, nonatomic) IBOutlet UILabel *minorLabel;
@property (weak, nonatomic) IBOutlet UILabel *accuracyLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinningWheel;

@end

@implementation TRIBeaconScreen

+ (NSString *)xtype
{
    return @"ibeacon";
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.manager = [[CLLocationManager alloc] init];
    self.manager.delegate = self;

    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:RASPBERRY_PI_UUID];
    self.region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                     identifier:@"com.trifork.raspberrypi"];
    [self.manager startMonitoringForRegion:self.region];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region
{
    [self.manager startRangingBeaconsInRegion:self.region];
}

-(void)locationManager:(CLLocationManager *)manager
         didExitRegion:(CLRegion *)region
{
    [self.manager stopRangingBeaconsInRegion:self.region];
    self.foundLabel.text = @"No";
}

-(void)locationManager:(CLLocationManager *)manager
       didRangeBeacons:(NSArray *)beacons
              inRegion:(CLBeaconRegion *)region
{
    // "firstObject" is another iOS 7 goodie!
    CLBeacon *beacon = [beacons firstObject];
    
    [self.spinningWheel stopAnimating];
    self.foundLabel.text = @"Yes";
    self.uuidLabel.text = beacon.proximityUUID.UUIDString;
    self.majorLabel.text = [beacon.major description];
    self.minorLabel.text = [beacon.minor description];
    self.accuracyLabel.text = [NSString stringWithFormat:@"%1.2f", beacon.accuracy];
    if (beacon.proximity == CLProximityUnknown)
    {
        self.distanceLabel.text = @"Unknown";
    }
    else if (beacon.proximity == CLProximityImmediate)
    {
        self.distanceLabel.text = @"Immediate";
    }
    else if (beacon.proximity == CLProximityNear)
    {
        self.distanceLabel.text = @"Near";
    }
    else if (beacon.proximity == CLProximityFar)
    {
        self.distanceLabel.text = @"Far";
    }
    self.rssiLabel.text = [NSString stringWithFormat:@"%li", (long)beacon.rssi];
}

@end

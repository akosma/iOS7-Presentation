//
//  TRIGeodesicScreen.m
//  Presentation
//
//  Created by Adrian on 13/11/13.
//  Copyright (c) 2013 Trifork GmbH. All rights reserved.
//

@import CoreLocation;
@import MapKit;


#import "TRIGeodesicScreen.h"


static CLLocationDegrees SF_LATITUDE = 37.775056;
static CLLocationDegrees SF_LONGITUDE = -122.419321;
static NSString *REUSE_ID = @"REUSE_ID";


@interface TRIGeodesicScreen () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, strong) NSMutableArray *locations;

@end



@implementation TRIGeodesicScreen

- (void)viewDidLoad
{
    [super viewDidLoad];

    // We initialize the locations array with San Francisco
    self.locations = [NSMutableArray array];
    
    CLLocation *sf = nil;
    sf = [[CLLocation alloc] initWithLatitude:SF_LATITUDE
                                    longitude:SF_LONGITUDE];
    [self.locations addObject:sf];
    
    // We start the location manager for a short while
    self.manager = [[CLLocationManager alloc] init];
    self.manager.delegate = self;
    [self.manager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    if ([locations count] > 0)
    {
        // We get a second location and we draw a line
        // from here to SF.
        CLLocation *location = locations[0];
        [self.locations addObject:location];
        MKGeodesicPolyline *line = [self geodesicLineFrom:location];
        [self.map addOverlay:line];

        // This will zoom the map to show all the locations
        // passed as parameter
        [self.map showAnnotations:self.locations
                         animated:YES];
        
        // And we stop the location manager
        [self.manager stopUpdatingLocation];
        
        [self showDistanceToSF];
    }
}

- (MKGeodesicPolyline *)geodesicLineFrom:(CLLocation *)start
{
    // This is a c-array of MKMapPoint instances
    // required by the MKPolyline constructor below
    NSInteger count = 2;
    CLLocationCoordinate2D *coordinates = NULL;
    coordinates = malloc(sizeof(CLLocationCoordinate2D) * count);
    
    for (NSInteger index = 0; index < count; ++index)
    {
        CLLocation *loc = self.locations[index];
        coordinates[index] = loc.coordinate;
    }
    
    MKGeodesicPolyline *line = nil;
    line = [MKGeodesicPolyline polylineWithCoordinates:coordinates
                                                 count:count];
    free(coordinates);

    return line;
}

#pragma mark - MKMapViewDelegate methods

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        // The MKOverlayRenderer completely replaces the
        // old MKOverlayView class of yesteryear
        MKPolylineRenderer *renderer = nil;
        renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.lineWidth = 5;
        renderer.fillColor = [UIColor blueColor];
        renderer.strokeColor = [UIColor blueColor];
        return renderer;
    }
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
	if (annotation == mapView.userLocation)
    {
		return nil;
	}
    
    MKAnnotationView *annotationView = nil;
    annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:REUSE_ID];
    if (annotationView == nil)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                         reuseIdentifier:REUSE_ID];
    }
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.rightCalloutAccessoryView = rightButton;

	return annotationView;
}

#pragma mark - Private methods

- (void)showDistanceToSF
{
    // Show the distance using the new MKDistanceFormatter
    CLLocation *sf = self.locations[0];
    CLLocation *here = self.locations[1];
    CLLocationDistance distance = [sf distanceFromLocation:here];
    
    MKDistanceFormatter *formatter = [[MKDistanceFormatter alloc] init];
    formatter.units = MKDistanceFormatterUnitsMetric;
    NSString *km = [formatter stringFromDistance:distance];
    
    formatter.units = MKDistanceFormatterUnitsImperial;
    NSString *miles = [formatter stringFromDistance:distance];
    
    NSString *template = @"The distance from here to SF is %@ (%@)";
    NSString *message = [NSString stringWithFormat:template, km, miles];
    
    self.distanceLabel.hidden = NO;
    self.distanceLabel.text = message;
    
}

@end

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


static CLLocationDegrees SAN_FRANCISCO_LATITUDE = 37.775056;
static CLLocationDegrees SAN_FRANCISCO_LONGITUDE = -122.419321;
static NSString *REUSE_ID = @"REUSE_ID";


@interface TRIGeodesicScreen () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, strong) NSMutableArray *locations;

@end



@implementation TRIGeodesicScreen

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locations = [NSMutableArray array];
    
    CLLocation *sf = nil;
    sf = [[CLLocation alloc] initWithLatitude:SAN_FRANCISCO_LATITUDE
                                    longitude:SAN_FRANCISCO_LONGITUDE];
    [self.locations addObject:sf];
    
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
        CLLocation *location = locations[0];
        [self.locations addObject:location];
        MKGeodesicPolyline *line = [self geodesicLineFrom:location];
        [self.map addOverlay:line];

        [self.map showAnnotations:self.locations
                         animated:YES];
        
        [self.manager stopUpdatingLocation];
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
    
    // Here we see how to customize annotation views. Very simple!
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.rightCalloutAccessoryView = rightButton;

	return annotationView;
}

@end

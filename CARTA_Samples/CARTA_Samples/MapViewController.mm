#import "MapViewController.h"

@implementation MapViewController

@synthesize mapView;

//When an annotation (map pin) is clicked, this is the function that is called to style its annotation.
- (MKAnnotationView *)mapView:(MKMapView *)myMapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKAnnotationView *aView = [[MKPinAnnotationView alloc] initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:@"foo"];

    aView = [[MKPinAnnotationView alloc] initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:@"point1"];
    aView.canShowCallout = YES;
    aView.annotation = annotation;
    return aView;
}

//This function is called when you click the "more" button on a map pin's callout.
-(void)mapView:(MKMapView *)sender annotationView:(MKAnnotationView *)aView calloutAccessoryControlTapped:(UIControl *)control
{
    ;
}

//When the back button is hit, release the controller.
-(IBAction)exitMap
{ 
    [mapView removeFromSuperview];
    mapView = nil;
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    if([API_KEY isEqualToString:@"YOUR_API_KEY_HERE"])
    {
        NSException* myException = [NSException
                                    exceptionWithName:@"MissingAPIKeyException"
                                    reason:@"Please enter your API key in the CARTA_Samples-Prefix.pch file."
                                    userInfo:nil];
        @throw myException;
    }
    
    if(!mapView) mapView = [[MKMapView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    //These three aren't strictly necessary, but...
    [mapView setMapType:MKMapTypeStandard];
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
    
    //Coordinates for our pins:
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(35.025,-85.234226);

    MKCoordinateSpan span = MKCoordinateSpanMake(0.2, 0.2);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [mapView setRegion:region animated:TRUE];
    
    
    //self.mapView.bounds = self.view.bounds; //This doesn't work if we have a navigation bar.
    self.mapView.bounds = [[UIScreen mainScreen] bounds]; //Somehow this isn't quite right, either...
    
    [self.view addSubview:self.mapView];
    self.mapView.delegate = self;
    
    //Show the user's location
    mapView.showsUserLocation = YES;
    
    
    //Create the location parser, and pass the map view so it can add pins later.
    self.locationParser = [[LocationParser alloc] init];
    self.locationParser.mapView = mapView;
    
    //Create the route parser, and pass the location parser.
    self.routeParser = [[RouteParser alloc] init];
    self.routeParser.locationParser = self.locationParser;
    
    //Call a looping function that updates the map.
    [self performSelector:@selector(updateMap)];
}

-(void)updateMap
{
    //Start the routeParser. When it's done, it'll call the locationParser, which will update the map.
    //This URL gets all routes. Enter your API_KEY in the "CARTA_Samples-Prefix.pch" file.
    [self.routeParser parseXMLFileAtURL:[[NSString alloc] initWithFormat:@"http://bustracker.gocarta.org/bustime/api/v1/getroutes?key=%@", API_KEY]];
    //Call this function in 5 seconds. NOTE that this isn't really recursive, because "performSelector" runs outside of this loop.
    [self performSelector:@selector(updateMap) withObject:nil afterDelay:5];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
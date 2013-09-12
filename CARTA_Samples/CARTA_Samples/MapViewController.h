#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MyAnnotation.h"
#import "RouteParser.h"
#import "LocationParser.h"

@interface MapViewController : UIViewController <MKMapViewDelegate>
{
    IBOutlet MKMapView *mapView;
    //Variables for XML parsing:
    NSXMLParser *rssParser;
    NSMutableArray *elements;
    NSMutableDictionary *subElements;
    NSString *currentElement;
    NSMutableString *ElementValue;
    BOOL errorParsing;
    //XML data we need to save:
    NSMutableArray *busRoutes;
    NSMutableArray *busLocations;
}
//Map properties:
@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) MyAnnotation *annotation1;
//XML parsers:
@property (nonatomic, retain) RouteParser *routeParser;
@property (nonatomic, retain) LocationParser *locationParser;
//"Back" button:
-(IBAction)exitMap;
//Function for parsing XML:
- (void)parseXMLFileAtURL:(NSString *)URL;

@end
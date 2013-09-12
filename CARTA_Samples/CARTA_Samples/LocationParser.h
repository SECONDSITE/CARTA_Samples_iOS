#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LocationParser : NSObject <NSXMLParserDelegate>
{
    //Variables for XML parsing:
    NSXMLParser *rssParser;
    NSMutableArray *elements;
    NSMutableDictionary *subElements;
    NSString *currentElement;
    NSMutableString *ElementValue;
    BOOL errorParsing;
    //XML data we need to save:
    NSMutableArray *busLocations;
    //Data we'll be passed from elsewhere:
    NSMutableArray *busRoutes;
    MKMapView *mapView; //Comes from MapViewController
    int routeNum; //Iterate through the routes
}

@property (retain, nonatomic) MKMapView *mapView;
@property (retain, nonatomic) NSMutableArray *busRoutes;
@property (retain, nonatomic) NSMutableArray *busLocations;
- (void)parseXMLFileAtURL:(NSString *)URL;
-(void)startProcessingRoutes;
@end
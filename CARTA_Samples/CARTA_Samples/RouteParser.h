#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LocationParser.h"

@interface RouteParser : NSObject <NSXMLParserDelegate>
{
    //Variables for XML parsing:
    NSXMLParser *rssParser;
    NSMutableArray *elements;
    NSMutableDictionary *subElements;
    NSString *currentElement;
    NSMutableString *ElementValue;
    BOOL errorParsing;
    //XML data we need to save:
    NSMutableArray *busRoutes;
    //Data we'll be passed from elsewhere:
    LocationParser *locationParser;
}

@property (retain, nonatomic) LocationParser *locationParser;
- (void)parseXMLFileAtURL:(NSString *)URL;

@end
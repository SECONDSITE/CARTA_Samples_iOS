#import "MyAnnotation.h"

@implementation MyAnnotation

@synthesize coordinate, title, subtitle, rightCalloutAccessoryView;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord
{
    coordinate = coord;
    return self;
}
@end
/* 
 
 Example input
 =============================
 
 URL: 
    http://bustracker.gocarta.org/bustime/api/v1/getvehicles?rt=1&key=[YOUR API KEY]
    "rt" is route number.
    Change API_KEY in CARTA_Samples-prefix.pch to match your API key.
    Documentation: Page 9 of http://bustracker.gocarta.org/bustime/apidoc/DeveloperAPIGuide.pdf
 
 RESPONSE:
    <bustime-response>
        <vehicle>
            <vid>115</vid>
            <tmstmp>20130912 14:53</tmstmp>
            <lat>35.03622906024639</lat>
            <lon>-85.30742586576022</lon>
            <hdg>179</hdg>
            <pid>480</pid>
            <rt>1</rt>
            <des>ALTON PARK</des>
            <pdist>6183</pdist>
            <spd>13</spd>
            <tablockid>11543</tablockid>
            <tatripid>91795</tatripid>
        </vehicle>
        <vehicle>
            <vid>109</vid>
            <tmstmp>20130912 14:53</tmstmp>
            <lat>34.99012619018554</lat>
            <lon>-85.30929260253906</lon>
            <hdg>228</hdg>
            <pid>481</pid>
            <rt>1</rt>
            <des>DOWNTOWN</des>
            <pdist>2304</pdist>
            <spd>15</spd>
            <tablockid>1157</tablockid>
            <tatripid>91816</tatripid>
        </vehicle>
    </bustime-response>
 */


#import "LocationParser.h"
#import "MyAnnotation.h"

@implementation LocationParser

#pragma mark - Map functions

-(void)updateMap
{
    //First, remove all annotations from the map.
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    NSDictionary *vehicle;
    NSString *vehicleDestination;
    NSString *vehicleID;
    float lat;
    float lon;
    for(int i=0; i<self.busLocations.count; i++)
    {
        vehicle = self.busLocations[i];
        vehicleDestination = [vehicle objectForKey:@"des"];
        vehicleID = [vehicle objectForKey:@"vid"];
        lat = [[vehicle objectForKey:@"lat"] floatValue];
        lon = [[vehicle objectForKey:@"lon"] floatValue];
        
        CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(lat,lon);
        
        MyAnnotation *annotation1 = [[MyAnnotation alloc] initWithCoordinate:loc];
        annotation1.title = [[NSString alloc] initWithFormat:@"Vehicle #%@", vehicleID];
        annotation1.subtitle = [[NSString alloc] initWithFormat:@"Destination: %@", vehicleDestination];
        
        //You can do fancier things with the callouts, but we won't.
        //_annotation1.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        //annotation1.canShowCallout = YES;
        
        [self.mapView addAnnotation:annotation1];
    }
}

#pragma mark - XML Parsing Functions
-(void)startProcessingRoutes
{
    //Cycle through the routes (contained in busRoutes) and get bus locations.
    self.busLocations = [[NSMutableArray alloc] init];
    routeNum = 0;
    [self processRoute:routeNum];
}

-(void)processRoute:(NSInteger)num
{
    NSDictionary *thisRoute;
    NSString *rtString;
    thisRoute = self.busRoutes[num];
    rtString = [thisRoute objectForKey:@"rt"];

    //This URL gets all bus locations on this route. Enter your API_KEY in the "CARTA_Samples-Prefix.pch" file.
    NSString *urlString = [[NSString alloc] initWithFormat:@"http://bustracker.gocarta.org/bustime/api/v1/getvehicles?key=%@&rt=%@", API_KEY, rtString];
    [self parseXMLFileAtURL:urlString];
}

- (void)parseXMLFileAtURL:(NSString *)URL
{
    //Tell the remote server that we're a Mac running Safari. This makes sure we don't get a mobile-ready
    //  version of the data (not necessary for CARTA, but a good idea).
    NSString *agentString = @"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_6; en-us) AppleWebKit/525.27.1 (KHTML, like Gecko) Version/3.2.1 Safari/525.27.1";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:URL]];
    [request setValue:agentString forHTTPHeaderField:@"User-Agent"];
    NSData *xmlFile = [ NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil ];
    
    elements = [[NSMutableArray alloc] init];
    errorParsing=NO;
    
    rssParser = [[NSXMLParser alloc] initWithData:xmlFile];
    [rssParser setDelegate:self];
    
    // In other cases, you may need to turn some of these on, depending on the type of XML file you are parsing
    [rssParser setShouldProcessNamespaces:NO];
    [rssParser setShouldReportNamespacePrefixes:NO];
    [rssParser setShouldResolveExternalEntities:NO];
    
    [rssParser parse];
}

//Error handling
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {

    NSString *errorString = [NSString stringWithFormat:@"Error code %i", [parseError code]];
    NSLog(@"Error parsing XML: %@", errorString);
    
    errorParsing=YES;
}

//This function runs when we START an element. Notice that we allocate the "ElementValue" and allocate a new NSMutableDictionary, but we have their values yet.
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    currentElement = [elementName copy];
    ElementValue = [[NSMutableString alloc] init];
    //If this is the beginning of a vehicle...
    if ([elementName isEqualToString:@"vehicle"]) {
        subElements = [[NSMutableDictionary alloc] init];
    }
    
}

//This function is called in the MIDDLE of an element. For each character we find, add it to "ElementValue."
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if(string!=nil)
        [ElementValue appendString:string];
}

//This function is called at the END of an element.
//If we've reached the start of the next <subElements>, add this whole <subElements>...</subElements> to "elements" array
//Otherwise, add this whole <???>...</???> to the "subElements" dictionary
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"vehicle"]) {
        [elements addObject:[subElements copy]];
    } else {
        [subElements setObject:ElementValue forKey:elementName];
    }
}

//This function is called at the END of the DOCUMENT. This function is also called when there's an error parsing the data.
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
    if (errorParsing == NO)
    {
        routeNum++;
        if(routeNum < self.busRoutes.count)
        {
           [self.busLocations addObjectsFromArray:[elements copy]];
           [self processRoute:routeNum];
        }
        else
            [self updateMap];
    }
    else
    {
        NSLog(@"Error occurred during XML processing");
    }
    
}
@end
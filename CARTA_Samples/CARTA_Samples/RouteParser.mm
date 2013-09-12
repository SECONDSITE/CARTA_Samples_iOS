/*
 
 Example input
 =============================
 
 URL:
    http://bustracker.gocarta.org/bustime/api/v1/getroutes?key=[YOUR API KEY]
    Change API_KEY in CARTA_Samples-prefix.pch to match your API key.
    Documentation: Page 12 of http://bustracker.gocarta.org/bustime/apidoc/DeveloperAPIGuide.pdf
 
 RESPONSE:
     <bustime-response>
        <route>
            <rt>1</rt>
            <rtnm>1 ALTON PARK</rtnm>
        </route>
        <route>
            <rt>2</rt>
            <rtnm>2 NORTH CHATTANOOGA</rtnm>
        </route>
        <route>
            <rt>4</rt>
            <rtnm>4 EASTGATE/HAMILTON PL</rtnm>
        </route>
        <route>
            <rt>5</rt>
            <rtnm>5 NORTH BRAINERD</rtnm>
        </route>
        <route>
            <rt>6</rt>
            <rtnm>6 EAST BRAINERD</rtnm>
        </route>
        <route>
            <rt>7</rt>
            <rtnm>7 CHATTANOOGA HOUSING AUTHORITY</rtnm>
        </route>
        <route>
            <rt>8</rt>
            <rtnm>8 EASTDALE</rtnm>
        </route>
        <route>
            <rt>9</rt>
            <rtnm>9 EAST LAKE</rtnm>
        </route>
        <route>
            <rt>10A</rt>
            <rtnm>10A AVONDALE</rtnm>
        </route>
        <route>
            <rt>10C</rt>
            <rtnm>10C CAMPBELL</rtnm>
        </route>
        <route>
            <rt>10G</rt>
            <rtnm>10G GLENWOOD</rtnm>
        </route>
        <route>
            <rt>13</rt>
            <rtnm>13 ROSSVILLE</rtnm>
        </route>
        <route>
            <rt>14</rt>
            <rtnm>14 MOCS EXPRESS</rtnm>
        </route>
        <route>
            <rt>15</rt>
            <rtnm>15 ST. ELMO</rtnm>
        </route>
        <route>
            <rt>16</rt>
            <rtnm>16 NORTHGATE</rtnm>
        </route>
        <route>
            <rt>19</rt>
            <rtnm>19 CROMWELL ROAD</rtnm>
        </route>
        <route>
            <rt>21</rt>
            <rtnm>21 GOLDEN GATEWAY</rtnm>
        </route>
        <route>
            <rt>28</rt>
            <rtnm>28 AMNICOLA HWY CHATT STATE</rtnm>
        </route>
        <route>
            <rt>33</rt>
            <rtnm>33 DOWNTOWN SHUTTLE</rtnm>
        </route>
        <route>
            <rt>34</rt>
            <rtnm>34 NORTH SHORE SHUTTLE</rtnm>
        </route>
    </bustime-response>
 
 */

#import "RouteParser.h"

@implementation RouteParser

#pragma mark - XML Parsing Functions

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
    
    //If this is the beginning of a route (for the first)
    if ([elementName isEqualToString:@"route"]) {
        subElements = [[NSMutableDictionary alloc] init];
    }
    
}

//This function is called in the MIDDLE of an element. For each character we find, add it to "ElementValue."
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    [ElementValue appendString:string];
}

//This function is called at the END of an element.
//If we've reached the start of the next <subElements>, add this whole <subElements>...</subElements> to "elements" array
//Otherwise, add this whole <???>...</???> to the "subElements" dictionary
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"route"]) {
        [elements addObject:[subElements copy]];
    } else {
        //Trim whitespace. Why? Strange whitespace insertion if we don't, which will mess us UP later.
        [subElements setObject:[ElementValue stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] forKey:elementName];
    }
}

//This function is called at the END of the DOCUMENT. This function is also called when there's an error parsing the data.
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
    if (errorParsing == NO)
    {
        //Great. We have all the routes now, so let's pass these to LocationParser and start the next bit of processing.
        self.locationParser.busRoutes = elements;
        [self.locationParser startProcessingRoutes];
    } else {
        NSLog(@"Error occurred during XML processing");
    }
    
}
@end
/**
 * For copyright & license, see LICENSE.
 */

#import "L4JSONLayout.h"
#import "L4LoggingEvent.h"

@implementation L4JSONLayout

- (NSString *) format:(L4LoggingEvent *) event {
    /*
     {\n
     \t     \"level\":\"%@\"\n
     \t     \"time\":\"%ldms\"\n
     \t     \"file\":\"%@:%@\"\n
     \t     \"method\":\"%@\"\n
     \t     \"message\":\"%@\"\n
     }\n
     */
    return [NSString stringWithFormat:@"{\n\t\"level\":\"%@\",\n\t\"time\":\"%ldms\",\n\t\"file\":\"%@:%@\",\n\t\"method\":\"%@\",\n\t\"message\":\"%@\"\n}\n",
            [[event level] stringValue], 
            [event millisSinceStart],
            [event fileName],
            [[event lineNumber] stringValue],
            [event methodName],
            [event renderedMessage]];
}

- (NSString *) contentType {
    return @"application/json";
}


@end

/**
 * For copyright & license, see LICENSE.
 */

#import "L4JSONLayout.h"
#import "L4LogEvent.h"

@implementation L4JSONLayout

+ (L4JSONLayout *) JSONLayout {
    return [[[L4JSONLayout alloc] init] autorelease];
}

- (NSString *) format:(L4LogEvent *) event {
    /*
     {\n
     \t     \"logger\":\"%@\"\n
     \t     \"level\":\"%@\"\n
     \t     \"time\":\"%ldms\"\n
     \t     \"file\":\"%@:%@\"\n
     \t     \"method\":\"%@\"\n
     \t     \"message\":\"%@\"\n
     }\n
     */
    return [NSString stringWithFormat:@"{\n\t\"logger\":\"%@\"\n\t\"level\":\"%@\",\n\t\"time\":\"%ldms\",\n\t\"file\":\"%@:%@\",\n\t\"method\":\"%@\",\n\t\"message\":\"%@\"\n}\n",
            [[event logger] name],
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

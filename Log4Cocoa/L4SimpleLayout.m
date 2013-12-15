/**
 * For copyright & license, see LICENSE.
 */

#import "L4SimpleLayout.h"
#import "L4LogEvent.h"
#import "L4Level.h"

@implementation L4SimpleLayout

- (NSString *)format:(L4LogEvent *)event
{
    return [NSString stringWithFormat:@"%@ - %ldms (%@:%@) %@ - %@",
            event.level.stringValue,
            event.millisSinceStart,
            event.fileName,
            event.lineNumber,
            event.methodName,
            event.renderedMessage];
}

@end

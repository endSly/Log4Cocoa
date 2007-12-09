/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4SimpleLayout.h"
#import "L4LoggingEvent.h"

@implementation L4SimpleLayout

- (NSString *) format: (L4LoggingEvent *) anEvent
{
	return [NSString stringWithFormat:@"%@ - %ldms (%@:%@) %@ - %@",
				[[anEvent level] stringValue], 
				[anEvent millisSinceStart],
				[anEvent fileName],
				[[anEvent lineNumber] stringValue],
				[anEvent methodName],
				[anEvent renderedMessage]];
}

@end

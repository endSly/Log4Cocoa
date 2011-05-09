/**
 * For copyright & license, see LICENSE.
 */

#import "L4SimpleLayout.h"
#import "L4LogEvent.h"

@implementation L4SimpleLayout

- (NSString *) format: (L4LogEvent *) anEvent
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

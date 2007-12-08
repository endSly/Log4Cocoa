/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4Filter.h"
#import "L4LoggingEvent.h"


@implementation L4Filter

- (int) decide: (L4LoggingEvent *) event
{
	return FILTER_NEUTRAL;
}

- (L4Filter *) next
{
	return next;
}

- (void) setNext: (L4Filter *) newNext
{
	if( next != newNext ) {
		[next autorelease];
		next = [newNext retain];
	}
}

@end

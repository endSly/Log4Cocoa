/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4Filter.h"
#import "L4LogEvent.h"


@implementation L4Filter

- (id) initWithProperties:(L4Properties *) initProperties
{
	return [super init];
}

- (void)dealloc
{
    [next release];
    [super dealloc];
}

- (L4FilterResult) decide:(L4LogEvent *) event
{
	return L4FilterNeutral;
}

- (L4Filter *) next
{
	return next;
}

- (void) setNext:(L4Filter *) newNext
{
    @synchronized(self) {
        if( next != newNext ) {
            [next autorelease];
            next = [newNext retain];
        }
    }
}

@end

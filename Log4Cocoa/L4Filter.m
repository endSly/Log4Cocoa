/**
 * For copyright & license, see LICENSE.
 */

#import "L4Filter.h"
#import "L4LogEvent.h"


@implementation L4Filter

@synthesize next;

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

@end

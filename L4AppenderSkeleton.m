/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4AppenderSkeleton.h"
#import "L4Filter.h"
#import "L4Level.h"
#import "L4LoggingEvent.h"
#import "L4LogLog.h"

@implementation L4AppenderSkeleton

- (void) dealloc
{
	[name release];
	[layout release];
	[threshold release];
	[headFilter release];
	[tailFilter release];
	[super dealloc];
}

- (void) append: (L4LoggingEvent *) anEvent
{
}

- (BOOL) isAsSevereAsThreshold: (L4Level *) aLevel
{
	return ((threshold == nil) || ([aLevel isGreaterOrEqual: threshold]));
}

- (L4Level *) threshold
{
	return threshold;
}

- (void) setThreshold: (L4Level *) aLevel
{
	if( threshold != aLevel ) {
		[threshold autorelease];
		threshold = [aLevel retain];
	}
}

/* ********************************************************************* */
#pragma mark L4AppenderCategory methods
/* ********************************************************************* */
// calls [self append: anEvent] after doing threshold checks
- (void) doAppend: (L4LoggingEvent *) anEvent
{
	L4Filter *aFilter = [self headFilter];
	BOOL breakLoop = NO;
	
	if( closed ) {
		[L4LogLog error: [@"Attempted to append to closed appender named: " stringByAppendingString: name]];
		return;
	}
	
	if(![self isAsSevereAsThreshold: [anEvent level]]) {
		return;
	}
	
	while((aFilter != nil) && !breakLoop) {
		switch([aFilter decide: anEvent]) {
			case FILTER_DENY:
				return;
			case FILTER_ACCEPT:
				breakLoop = YES;
				break;
			case FILTER_NEUTRAL:
			default:
				aFilter = [aFilter next];
				break;
		}
	}
	[self append: anEvent]; // passed all threshold checks, append event.
}

- (void) addFilter: (L4Filter *) newFilter
{
	if( headFilter == nil ) {
		headFilter = [newFilter retain];
		tailFilter = newFilter; // don't retain at the tail, just the head.
	} else {
		[tailFilter setNext: newFilter];
		tailFilter = newFilter;
	}
	
}

- (L4Filter *) headFilter
{
	return headFilter;
}

- (void) clearFilters
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	id aFilter = [headFilter next];
	[headFilter autorelease];
	for( aFilter = headFilter; aFilter != nil; aFilter = [headFilter next] ) {
		[aFilter setNext: nil];
	}
	headFilter = nil;
	tailFilter = nil;
	
	[pool release];
}

- (void) close
{
}

- (BOOL) requiresLayout
{
	return NO;
}

- (NSString *) name
{
	return name;
}

- (void) setName: (NSString *) aName
{
	if( name != aName ) {
		[name autorelease];
		name = [aName retain];
	}
}

- (L4Layout *) layout
{
	return layout;
}

- (void) setLayout: (L4Layout *) aLayout
{
	if( layout != aLayout ) {
		[layout autorelease];
		layout = [aLayout retain];
	}
}

- (id <L4ErrorHandler>) errorHandler
{
	return errorHandler;
}

- (void) setErrorHandler: (id <L4ErrorHandler>) anErrorHandler
{
	if( anErrorHandler == nil ) {
		[L4LogLog warn: @"You have tried to set a null error-handler."];
	} else if( errorHandler != (id) anErrorHandler ) {
		[errorHandler autorelease];
		errorHandler = [anErrorHandler retain];
	}
}
@end

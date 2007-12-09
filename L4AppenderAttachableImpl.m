/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4AppenderAttachableImpl.h"


@implementation L4AppenderAttachableImpl

- (int) appendLoopOnAppenders: (L4LoggingEvent *) event
{
	int size = 0;

	if( appenderList != nil ) {
		int i;
		size = [appenderList count];
		for( i = 0; i < size; i++ ) {
			[[appenderList objectAtIndex: i] doAppend: event];
		}
	}
	return size;
}

/* ********************************************************************* */
#pragma mark L4AppenderAttachableMethods protocol methods
/* ********************************************************************* */
- (void) addAppender: (id <L4Appender>) newAppender
{
	if( newAppender == nil ) {
		return; // sanity check
	}
	
	if( appenderList == nil ) {
		// only place appenderList array is recreated if its nil.
		appenderList = [[NSMutableArray alloc] init];
	}
	
	if(![appenderList containsObject: newAppender]) {
		[appenderList addObject: newAppender];
		[[NSNotificationCenter defaultCenter] postNotificationName: APPENDER_ADDED_EVENT object: newAppender];
	}
}

- (NSArray *) allAppenders
{
	return appenderList;
}

- (id <L4Appender>) appenderWithName: (NSString *) aName
{
	NSEnumerator *enumerator = [appenderList objectEnumerator];
	id <L4Appender> anAppender;
	
	while ((anAppender = (id <L4Appender>)[enumerator nextObject])) {
		if( [[anAppender name] isEqualToString: aName ]) {
			return anAppender;
		}
	}
	return nil;
}

- (BOOL) isAttached: (id <L4Appender>) appender
{
	if((appender == nil) || (appenderList == nil)) {
		return NO; // short circuit the test
	}
	return [appenderList containsObject: appender]; 
}

- (void) removeAppenderWithName: (NSString *) aName
{
	[self removeAppender: [self appenderWithName: aName]];
}

- (void) removeAppender: (id <L4Appender>) appender
{
	[appenderList removeObject: appender];
	[[NSNotificationCenter defaultCenter] postNotificationName: APPENDER_REMOVED_EVENT object: appender];
}

- (void) removeAllAppenders
{
	NSEnumerator *enumerator = [appenderList objectEnumerator];
	id <L4Appender> anAppender;
	
	while ((anAppender = (id <L4Appender>)[enumerator nextObject]))
	{
		// why only call close in removeAllAppenders & not removeAppender: ????
		// just doing it like they did it in Log4J ... will figure out later.
		//
		[anAppender close];
		[[NSNotificationCenter defaultCenter] postNotificationName: APPENDER_REMOVED_EVENT object: anAppender];
	}
	[appenderList removeAllObjects];
	[appenderList release];
	appenderList = nil;
}

@end

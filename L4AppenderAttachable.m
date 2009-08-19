/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4AppenderAttachable.h"


@implementation L4AppenderAttachable

- (NSUInteger) appendLoopOnAppenders:(L4LoggingEvent *) event
{
	NSUInteger size = 0;

    @synchronized(self) {
        if( appenderList != nil ) {
            int i;
            size = [appenderList count];
            for( i = 0; i < size; i++ ) {
                [[appenderList objectAtIndex:i] doAppend:event];
            }
        }
    }
	return size;
}

- (void) dealloc
{
	[appenderList release];
	appenderList = nil;
	[super dealloc];
}

/* ********************************************************************* */
#pragma mark L4AppenderAttachableMethods protocol methods
/* ********************************************************************* */
- (void) addAppender:(id <L4Appender>) newAppender
{
	if( newAppender == nil ) {
		return; // sanity check
	}
	
    @synchronized(self) {
        if( appenderList == nil ) {
            // only place appenderList array is recreated if its nil.
            appenderList = [[NSMutableArray alloc] init];
        }
        
        if(![appenderList containsObject:newAppender]) {
            [appenderList addObject:newAppender];
            [[NSNotificationCenter defaultCenter] postNotificationName:APPENDER_ADDED_EVENT object:newAppender];
        }
    }
}

- (NSArray *) allAppenders
{
	return appenderList;
}

- (id <L4Appender>) appenderWithName:(NSString *) aName
{
	id <L4Appender> anAppender = nil;
    @synchronized(self) {
        NSEnumerator *enumerator = [appenderList objectEnumerator];
        
        while ((anAppender = (id <L4Appender>)[enumerator nextObject])) {
            if( [[anAppender name] isEqualToString:aName ]) {
                break;
            }
        }
    }
	return anAppender;
}

- (BOOL) isAttached:(id <L4Appender>) appender
{
	if((appender == nil) || (appenderList == nil)) {
		return NO; // short circuit the test
	}
	return [appenderList containsObject:appender]; 
}

- (void) removeAppenderWithName:(NSString *) aName
{
	[self removeAppender:[self appenderWithName:aName]];
}

- (void) removeAppender:(id <L4Appender>) appender
{
	[appenderList removeObject:appender];
	[[NSNotificationCenter defaultCenter] postNotificationName:APPENDER_REMOVED_EVENT object:appender];
}

- (void) removeAllAppenders
{
    @synchronized(self) {
        NSEnumerator *enumerator = [appenderList objectEnumerator];
        id <L4Appender> anAppender;
        
        while ((anAppender = (id <L4Appender>)[enumerator nextObject]))
        {
            // why only call close in removeAllAppenders & not removeAppender:????
            // just doing it like they did it in Log4J ... will figure out later.
            //
            [anAppender close];
            [[NSNotificationCenter defaultCenter] postNotificationName:APPENDER_REMOVED_EVENT object:anAppender];
        }
        [appenderList removeAllObjects];
        [appenderList release];
        appenderList = nil;
    }
}

@end

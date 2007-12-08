/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import <Foundation/Foundation.h>
#import "L4AppenderProtocols.h"

#define APPENDER_ADDED_EVENT   @"AppenderAddedEvent"
#define APPENDER_REMOVED_EVENT @"AppenderRemovedEvent"


@interface L4AppenderAttachableImpl : NSObject  {
	NSMutableArray *appenderList;
}

- (int) appendLoopOnAppenders: (L4LoggingEvent *) event;

@end

@interface L4AppenderAttachableImpl (L4AppenderAttachableMethods) <L4AppenderAttachable>

- (void) addAppender: (id <L4Appender>) newAppender;

- (NSEnumerator *) allAppenders;
- (NSArray *) allAppendersArray;

- (id <L4Appender>) appenderWithName: (NSString *) aName;
- (BOOL) isAttached: (id <L4Appender>) appender;

- (void) removeAppenderWithName: (NSString *) aName;
- (void) removeAppender: (id <L4Appender>) appender;
- (void) removeAllAppenders;

@end
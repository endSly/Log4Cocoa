#import <Foundation/Foundation.h>
#import "L4AppenderProtocols.h"

#define APPENDER_ADDED_EVENT   @"AppenderAddedEvent"
#define APPENDER_REMOVED_EVENT @"AppenderRemovedEvent"

/**
 * This (poorly named) class servers as the basis for the L4AppenderAttachable protocol.
 */
@interface L4AppenderAttachable : NSObject <L4AppenderAttachable> {
	NSMutableArray *appenderList; /**< The collection of log appenders.*/
}
/**
 * Appends event to appenders.
 * This message sends a doAppend: message to every appender in the appnderList attribute.
 * @param event the event to be appended.
 * @return the number of appenders the event was appended to.
 */
- (NSUInteger) appendLoopOnAppenders:(L4LoggingEvent *) event;

@end
// For copyright & license, see COPYRIGHT.txt.

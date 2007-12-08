/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import <Foundation/Foundation.h>

@class L4Logger, L4Filter, L4Layout, L4LoggingEvent;

@protocol L4ErrorHandler
- (void) error: (NSString *) message;

- (void) error: (NSString *) message exception: (NSException *) e errorCode: (int) errorCode;

- (void) error: (NSString *) message exception: (NSException *) e errorCode: (int) errorCode event: (L4LoggingEvent *) event;

- (id)retain;

- (void) setLogger: (L4Logger *) aLogger;

- (void) setAppender: (id) appender; // can't forward declare protocols, so check to see if the object responds
- (void) setBackupAppender: (id) appender;

@end


@protocol L4Appender <NSObject>
/**
 * Appender log this event.
 * @param the event to append.
 */
- (void) doAppend: (L4LoggingEvent *) anEvent;

/**
 * Adds to the end of list.
 * @param the filter to add.
 */
- (void) addFilter: (L4Filter *) newFilter;

/**
 * @return first filter or nil of there are none.
 */
- (L4Filter *) headFilter;

/**
 * removes all filters from list.
 */
- (void) clearFilters;

/**
 * it is a programing error to append to a close appender.
 */
- (void) close;

- (BOOL) requiresLayout;

/**
 * unique name of this appender.
 */
- (NSString *) name;
- (void) setName: (NSString *) aName;

- (L4Layout *) layout;
- (void) setLayout: (L4Layout *) aLayout;

- (id <L4ErrorHandler>) errorHandler;
- (void) setErrorHandler: (id <L4ErrorHandler>) anErrorHandler;

@end


@protocol L4AppenderAttachable <NSObject>

- (void) addAppender: (id <L4Appender>) newAppender;

- (NSEnumerator *) allAppenders;
- (NSArray *) allAppendersArray;

- (id <L4Appender>) appenderWithName: (NSString *) aName;
- (BOOL) isAttached: (id <L4Appender>) appender;

- (void) removeAllAppenders;
- (void) removeAppender: (id <L4Appender>) appender;
- (void) removeAppenderWithName: (NSString *) aName;

@end

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

/**
 * Appenders are responsible for adding a log message to log.
 * This formal protocol defines the messages a class used for appending needs to support.
 */
@protocol L4Appender <NSObject>
/**
 * Appender log this event.
 * @param anEvent the event to append.
 */
- (void) doAppend: (L4LoggingEvent *) anEvent;

/**
 * Adds to the end of list.
 * @param newFilter the filter to add.
 */
- (void) addFilter: (L4Filter *) newFilter;

/**
 * Accessor for the head filter (the first in the list).
 * @return first filter or nil if there are none.
 */
- (L4Filter *) headFilter;

/**
 * Removes all filters from list.
 */
- (void) clearFilters;

/**
 * it is a programing error to append to a close appender.
 */
- (void) close;

- (BOOL) requiresLayout;

/**
 * Accessor for name attribute.
 * @return unique name of this appender.
 */
- (NSString *) name;
/**
 * Mutator for name attribute.
 * @param aName the name for this appender.
 */
- (void) setName: (NSString *) aName;

/**
 * Accessor for layout attribute.
 * @return layout of this appender.
 */
- (L4Layout *) layout;

/**
 * Mutator for layout attribute.
 * @param aLayout the layout for this appender.
 */
- (void) setLayout: (L4Layout *) aLayout;

/**
 * Accessor for errorHandler attribute.
 * @return errorHandler of this appender.
 */
- (id <L4ErrorHandler>) errorHandler;
/**
 * Mutator for errorHandler attribute.
 * @param anErrorHandler the errorHandler for this appender.
 */
- (void) setErrorHandler: (id <L4ErrorHandler>) anErrorHandler;

@end


@protocol L4AppenderAttachable <NSObject>
/**
 * Adds an appender to be logged to.
 * @param newAppender the new appender to add.
 */
- (void) addAppender:(id <L4Appender>) newAppender;

/**
 * Accessor for the collection of log appenders.
 * @return an array of al appenders.
 */
- (NSArray *) allAppenders;

- (id <L4Appender>) appenderWithName: (NSString *) aName;
- (BOOL) isAttached: (id <L4Appender>) appender;

- (void) removeAllAppenders;
- (void) removeAppender: (id <L4Appender>) appender;
- (void) removeAppenderWithName: (NSString *) aName;

@end
// For copyright & license, see COPYRIGHT.txt.

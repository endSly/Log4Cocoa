#import <Foundation/Foundation.h>

@class L4Logger, L4Filter, L4Layout, L4LoggingEvent, L4Properties;

/**
 * Appenders are responsible for adding a log message to log.
 * This formal protocol defines the messages a class used for appending needs to support.
 */
@protocol L4Appender <NSObject>
/**
 * Initializes an instance from a collection of configuration properties.  
 * For more information on the specific appender properties, see the documentation for the particular class.
 * @param initProperties the properties to use.
 */
- (id) initWithProperties:(L4Properties *) initProperties;

/**
 * Appender log this event.
 * @param anEvent the event to append.
 */
- (void) doAppend:(L4LoggingEvent *) anEvent;

/**
 * Appends to the end of list.
 * @param newFilter the filter to add.
 */
- (void) appendFilter:(L4Filter *) newFilter;

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

/**
 * Returns if the appender requires layout.
 * @return YES if the appender requires layout, NO if it does not.
 */
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
- (void) setName:(NSString *) aName;

/**
 * Accessor for layout attribute.
 * @return layout of this appender.
 */
- (L4Layout *) layout;

/**
 * Mutator for layout attribute.
 * @param aLayout the layout for this appender.
 */
- (void) setLayout:(L4Layout *) aLayout;

@end


/**
 * This protocol defines messages used to chain L4Appender instances together.  The system supports having more than one
 * logging appender, so that a single logging event can be logged in more than one place.
 */
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

/**
 * Returns the L4Appender with the given name.
 * @param aName the name of the L4Appender of interest.
 * @return the L4Appender with the name aName, or nil if it does not exist.
 */
- (id <L4Appender>) appenderWithName:(NSString *)aName;

/**
 * Returns a BOOL value that indicates whether the parameter has been attached to the appender list.
 * @param appender the L4Appender of interest.
 * @return YES if appender has been attached, NO otherwise.
 */
- (BOOL) isAttached:(id <L4Appender>)appender;

/**
 * Clears all L4Appender instances that have been attached.
 */
- (void) removeAllAppenders;

/**
 * Removes a given L4Appender from those attached.
 * @param appender the L4Appender to remove.
 */
- (void) removeAppender:(id <L4Appender>)appender;

/**
 * Removes a L4Appender with the given name from those attached.
 * @param aName the name of the L4Appender to remove.
 */
- (void) removeAppenderWithName:(NSString *)aName;

@end
// For copyright & license, see COPYRIGHT.txt.

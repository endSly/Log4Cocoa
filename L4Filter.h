#import <Foundation/Foundation.h>
#import "L4AppenderProtocols.h"

@class L4LoggingEvent, L4Properties;

/**
 * An enumeration of the allowed L4Filter actions.
 */
typedef enum {
	L4FilterDeny	= -1, /**< Prevent the request to log the event. */
	L4FilterNeutral = 0,  /**< Do not affect the request to log the event. */
	L4FilterAccept  = 1   /**< Allow the request to log he event. */
} L4FilterResult;

/**
 * Filter for log events.
 * This class is intended to serve as the base for filters.  This class itself does nothing;
 * the only way a flter would actually be used would be to subclass it and over-ride the 
 * decide:method.
 */
@interface L4Filter : NSObject 
{
	L4Filter *next; /**< The next filter in the chain.*/
}

/**
 * Initializes an instance from properties.  Currently there are no properties that apply to this class.
 * @param initProperties the proterties to use.
 * @throw L4PropertyMissingException if a required property is missing.
 */
- (id) initWithProperties:(L4Properties *) initProperties;

/**
 * Decide what this filter should do with event.
 * This method is used to determine if the event should be logged.
 * @param event the event to check.
 * @return one of L4FilterDeny, L4FilterNeutral, or L4FilterAccept. 
 */
- (L4FilterResult) decide:(L4LoggingEvent *) event;

/**
 * Accessor for the next filter.
 * @return the next filter.
 */
- (L4Filter *) next;

/**
 * Mutator for the next filter.
 * @param newNext the new next filter.
 */
- (void) setNext:(L4Filter *) newNext;

@end
// For copyright & license, see COPYRIGHT.txt.

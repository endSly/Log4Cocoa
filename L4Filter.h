#import <Foundation/Foundation.h>
#import "L4AppenderProtocols.h"

#define FILTER_DENY	-1
#define FILTER_NEUTRAL  0
#define FILTER_ACCEPT   1

@class L4LoggingEvent;

/**
 * Filter for log events.
 * This class is intended to serve as the base for filters.  This class itself does nothing;
 * the only way a flter would actually be used would be to subclass it and over-ride the 
 * decide: method.
 */
@interface L4Filter : NSObject  {
	L4Filter *next; /**< The next filter in the chain.*/
}

/**
 * Decide what this filter should do with event.
 * This method is used to determine if the event should be logged.
 * @param event the event to check.
 * @return one of FILTER_DENY, FILTER_NEUTRAL, or FILTER_ACCEPT. FILTER_DENY means to not 
 *		log the event.
 */
- (int) decide: (L4LoggingEvent *) event;

/**
 * Accessor for the next filter.
 * @return the next filter.
 */
- (L4Filter *) next;

/**
 * Mutator for the next filter.
 * @param newNext the new next filter.
 */
- (void) setNext: (L4Filter *) newNext;

@end
// For copyright & license, see COPYRIGHT.txt.

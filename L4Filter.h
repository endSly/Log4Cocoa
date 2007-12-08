/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import <Foundation/Foundation.h>
#import "L4AppenderProtocols.h"

#define FILTER_DENY	-1
#define FILTER_NEUTRAL  0
#define FILTER_ACCEPT   1

@class L4LoggingEvent;

@interface L4Filter : NSObject  {
	L4Filter *next;
}

- (int) decide: (L4LoggingEvent *) event;

- (L4Filter *) next;
- (void) setNext: (L4Filter *) newNext;

@end


@interface L4Filter (L4OptionHandlerCategory) <L4OptionHandler>

- (void) activateOptions;

@end

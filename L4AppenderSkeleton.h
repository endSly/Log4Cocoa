/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import <Foundation/Foundation.h>
#import "L4AppenderProtocols.h"
@class L4Filter, L4Level, L4LoggingEvent;

@interface L4AppenderSkeleton : NSObject {
	NSString *name;
	L4Layout *layout;
	L4Level *threshold;
	L4Filter *headFilter;
	L4Filter *tailFilter;
	id errorHandler;
	BOOL closed;
}

- (void) append: (L4LoggingEvent *) anEvent;
- (BOOL) isAsSevereAsThreshold: (L4Level *) aLevel;

- (L4Level *) threshold;
- (void) setThreshold: (L4Level *) aLevel;

@end


@interface L4AppenderSkeleton (L4AppenderCategory) <L4Appender>

- (void) doAppend: (L4LoggingEvent *) anEvent;
// calls [self append: anEvent] after doing threshold checks

- (void) addFilter: (L4Filter *) aFilter;
- (L4Filter *) headFilter;
- (void) clearFilters;
- (void) close;

- (BOOL) requiresLayout;

- (NSString *) name;
- (void) setName: (NSString *) aName;

- (L4Layout *) layout;
- (void) setLayout: (L4Layout *) aLayout;

- (id <L4ErrorHandler>) errorHandler;
- (void) setErrorHandler: (id <L4ErrorHandler>) anErrorHandler;

@end

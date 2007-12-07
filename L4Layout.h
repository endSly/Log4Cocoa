/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import <Foundation/Foundation.h>
#import "L4AppenderProtocols.h"

@class L4LoggingEvent, L4SimpleLayout;

@interface L4Layout : NSObject <L4OptionHandler> {

}

+ (id) simpleLayout;

- (void) activateOptions;

- (NSString *) format: (L4LoggingEvent *) event;
- (NSString *) contentType;
- (NSString *) header;
- (NSString *) footer;
- (BOOL) ignoresExceptions;

@end

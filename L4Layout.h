/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import <Foundation/Foundation.h>
#import "L4AppenderProtocols.h"

@class L4LoggingEvent, L4SimpleLayout;

@interface L4Layout : NSObject {

}

+ (id) simpleLayout;

- (NSString *) format: (L4LoggingEvent *) event;
- (NSString *) contentType;
- (NSString *) header;
- (NSString *) footer;
- (BOOL) ignoresExceptions;

@end

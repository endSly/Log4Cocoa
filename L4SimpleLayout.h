/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import <Foundation/Foundation.h>
#import "L4Layout.h"


@interface L4SimpleLayout : L4Layout {
}

- (NSString *) format: (L4LoggingEvent *) anEvent;
- (BOOL) ignoresException;

@end

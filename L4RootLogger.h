/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import <Foundation/Foundation.h>
#import "L4Logger.h"
@class L4Level;


@interface L4RootLogger : L4Logger {
}

- (id) initWithLevel: (L4Level *) aLevel;
- (void) setLevel: (L4Level *) aLevel;
- (L4Level *) effectiveLevel;

@end

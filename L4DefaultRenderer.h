/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import <Foundation/Foundation.h>
#import "L4LoggerProtocols.h"

@interface L4DefaultRenderer : NSObject <L4ObjectRenderer> {

}

- (NSString *) render: (id) object;

@end

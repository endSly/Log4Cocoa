/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import <Foundation/Foundation.h>

#define LINE_BREAK_SEPERATOR_KEY @"LINE_BREAK_SEPERATOR_KEY"

@interface L4Configurator : NSObject {

}

+ (void) initialize;

+ (void) basicConfiguration;
+ (id) propertyForKey: (NSString *) aKey;

+ (void) resetLineBreakChar;
+ (NSData *) lineBreakChar;

@end

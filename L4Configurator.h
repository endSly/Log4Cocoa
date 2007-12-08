/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import <Foundation/Foundation.h>


@interface L4Configurator : NSObject {

}

/**
 * Making sure that we capture the startup time of this application.  This sanity 
 * check is also in +[L4Logger initialize] too.
 */
+ (void) initialize;

+ (void) basicConfiguration;

+ (NSData *) lineBreakChar;

@end

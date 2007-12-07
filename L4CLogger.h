/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import <Foundation/Foundation.h>
#import "L4Logger.h"

/**
 *  ### TODO -- add pure C cover functions to call into Log4Cocoa.  I plan to convert the __FILE__
 *              argument into the logger name, but I'll need to parse out the final "." (i.e. file.c)
 *              probably convert it to a dash "-".  Also need to handle the pure C types being passed in.
 */


/* DEBUG < INFO < WARN < ERROR < FATAL */

// #define cLogError(message) l4CLogError( __LINE__, __FILE__, __PRETTY_FUNCTION__, message)


@interface L4CLogger : L4Logger {

}

// (void) l4CLogError( int lineNumber, cString fileName, cString prettyFunction, cString message );


@end

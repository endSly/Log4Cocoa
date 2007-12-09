#import <Foundation/Foundation.h>
#import "L4WriterAppender.h"

@interface L4ConsoleAppender : L4WriterAppender {
	BOOL isStandardOut; /**< Tracks if this appender is for stdout.*/
}

/**
 * Creates and returns an L4ConsoleAppender on stdout with the given L4Layout.
 * @param aLayout the layout to use for the created appender.
 * @return the new appender.
 */
+ (L4ConsoleAppender *) standardOutWithLayout: (L4Layout *) aLayout;

/**
 * Creates and returns an L4ConsoleAppender on stderr with the given L4Layout.
 * @param aLayout the layout to use for the created appender.
 * @return the new appender.
 */
+ (L4ConsoleAppender *) standardErrWithLayout: (L4Layout *) aLayout;

/**
 * default init method.  Returned instance isn't connected to anything.
 * @return the new instance.
 */
- (id) init;

/**
 * Creates and returns a new console appender.
 * @param standardOut YES to use stdout; otherwise stderr is used.
 * @param aLayout the layout to use.
 * @return the new instance.
 */
- (id) initTarget: (BOOL) standardOut withLayout: (L4Layout *) aLayout;

/**
 * Accesor for isStandardOut attribute.
 * @return YES if this appender is for stdout; NO if it is for stderr.
 */
- (BOOL) isStandardOut;

@end
// For copyright & license, see COPYRIGHT.txt.

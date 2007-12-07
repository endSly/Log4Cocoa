/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import <Foundation/Foundation.h>
#import "L4WriterAppender.h"

@interface L4ConsoleAppender : L4WriterAppender {
    BOOL isStandardOut;
}

+ (L4ConsoleAppender *) standardOutWithLayout: (L4Layout *) aLayout;
+ (L4ConsoleAppender *) standardErrWithLayout: (L4Layout *) aLayout;

- (id) init;

- (id) initTarget: (BOOL) standardOut
       withLayout: (L4Layout *) aLayout;

- (id) initStandardOutWithLayout: (L4Layout *) aLayout;
- (id) initStandardErrWithLayout: (L4Layout *) aLayout;

- (void) setStandardOut;
- (void) setStandardErr;

- (NSFileHandle *) target;
- (BOOL) isStandardOut;

@end

/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4ConsoleAppender.h"
#import "L4Layout.h"

@implementation L4ConsoleAppender

+ (L4ConsoleAppender *) standardOutWithLayout: (L4Layout *) aLayout
{
    return (L4ConsoleAppender *) [[[L4ConsoleAppender alloc] initTarget: YES
                                                             withLayout: aLayout] autorelease];
}

+ (L4ConsoleAppender *) standardErrWithLayout: (L4Layout *) aLayout
{
    return (L4ConsoleAppender *) [[[L4ConsoleAppender alloc] initTarget: NO
                                                             withLayout: aLayout] autorelease];
}

- (id) init
{
    self = [super init];
    return self;
}

- (id) initTarget: (BOOL) standardOut
       withLayout: (L4Layout *) aLayout
{
    self = [super init];
    if( self != nil )
    {
        if( standardOut )
        {
            [self setStandardOut];
        }
        else
        {
            [self setStandardErr];
        }
        [self setLayout: aLayout];
    }
    return self;
}

- (id) initStandardOutWithLayout: (L4Layout *) aLayout
{
    return [self initTarget: YES
                 withLayout: aLayout];
}

- (id) initStandardErrWithLayout: (L4Layout *) aLayout
{
    return [self initTarget: NO
                 withLayout: aLayout];
}

- (void) setStandardOut
{
    if(!isStandardOut || (fileHandle == nil))
    {
        isStandardOut = YES;
        [fileHandle autorelease];
        fileHandle = [[NSFileHandle fileHandleWithStandardOutput] retain];
    }
}

- (void) setStandardErr
{
    if(isStandardOut || (fileHandle == nil))
    {
        isStandardOut = NO;
        [fileHandle autorelease];
        fileHandle = [[NSFileHandle fileHandleWithStandardError] retain];
    }
}

- (NSFileHandle *) target
{
    return fileHandle;
}

- (BOOL) isStandardOut
{
    return isStandardOut;
}

@end

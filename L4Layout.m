/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4Layout.h"
#import "L4SimpleLayout.h"
#import "L4LoggingEvent.h"

@implementation L4Layout

+ (L4Layout *) simpleLayout
{
	return [[[L4SimpleLayout alloc] init] autorelease];
}

- (NSString *) format: (L4LoggingEvent *) event
{
	return [event description];
}

- (NSString *) contentType
{
	return @"text/plain";
}

- (NSString *) header
{
	return nil;
}

- (NSString *) footer
{
	return nil;
}

- (BOOL) ignoresExceptions
{
	return YES;
}

@end

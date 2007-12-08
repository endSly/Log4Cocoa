/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "NSObject+Log4Cocoa.h"
#import "L4Logger.h"
#import "L4LogManager.h"


@implementation NSObject (Log4Cocoa)

+ (L4Logger *) l4Logger
{
	return [L4LogManager loggerForClass: (Class) self];
}

- (L4Logger *) l4Logger
{
	return [L4LogManager loggerForClass: [self class]];
}

@end

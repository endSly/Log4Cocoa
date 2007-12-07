/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4NSObjectAdditions.h"
#import "L4Logger.h"
#import "L4LogManager.h"

@implementation L4NSObjectAdditions

@end


@implementation NSObject(L4CocoaMethods)

+ (L4Logger *) l4Logger
{
    return [L4LogManager loggerForClass: (Class) self];
}

- (L4Logger *) l4Logger
{
    return [L4LogManager loggerForClass: [self class]];
}

@end


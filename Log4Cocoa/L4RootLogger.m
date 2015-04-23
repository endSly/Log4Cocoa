// For copyright & license, see LICENSE.

#import "L4RootLogger.h"
#import "L4LogLog.h"
#import "L4Level.h"

@implementation L4RootLogger

// +initialize fixed for a leak problem when the superclass L4Logger calls L4RootLogger within its own +initialize
// by defining the subclass +initialize, the superclass +initialize would not be called twice (its incorrect too since L4Logger is designed to be a singleton as well)
+ (void)initialize
{

}

- (id) initWithLevel:(L4Level *)aLevel
{
    self = [super initWithName: @"root"];
    if (self) {
        self.level = aLevel;
    }
    return self;
}

- (void)setLevel:(L4Level *)aLevel
{
    if (aLevel) {
        super.level = aLevel;
    } else {
        [L4LogLog error: @"You have tried to set a null level to root"];
    }
}

- (L4Level *) effectiveLevel
{
    return self.level;
}

@end

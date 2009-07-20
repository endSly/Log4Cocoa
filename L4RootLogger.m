#import "L4RootLogger.h"
#import "L4LogLog.h"
#import "L4Level.h"

@implementation L4RootLogger

- (id) initWithLevel: (L4Level *) aLevel
{
	self = [super initWithName: @"root"];
	if( self != nil ) {
		[self setLevel: aLevel];
	}
	return self;
}

- (void) setLevel: (L4Level *) aLevel
{
	if( aLevel != nil ) {
		[super setLevel: aLevel];
	} else {
		[L4LogLog error: @"You have tried to set a null level to root"];
	}
}

- (L4Level *) effectiveLevel
{
	return level;
}

@end
// For copyright & license, see COPYRIGHT.txt.

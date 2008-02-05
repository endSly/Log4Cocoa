/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4Factory.h"
#import "L4LogLog.h"

@interface L4Factory (Private)
- (id) initWithClass: (Class) aFactoryClass;
@end

@implementation L4Factory

/* ********************************************************************* */
#pragma mark Class methods
/* ********************************************************************* */
+ (id <L4Factory>) factoryWithClass: (Class) aFactoryClass
{
 	return [[[L4Factory alloc] initWithClass: aFactoryClass] autorelease];
}

/* ********************************************************************* */
#pragma mark Instance methods
/* ********************************************************************* */
- (id <L4FactoryObject>) factoryObjectWithProperties: (L4Properties *) properties;
{
 	return [[(id <L4FactoryObject>)[factoryClass alloc] initWithProperties: properties] autorelease];
}

- (id) init
{
 	return nil; // never use this constructor
}

/* ********************************************************************* */
#pragma mark Private methods
/* ********************************************************************* */
- (id) initWithClass: (Class) aFactoryClass
{
 	self = [super init];
 	
 	if ( self != nil ) {
  		if ( [aFactoryClass conformsToProtocol: @protocol(L4FactoryObject)] ) {
				factoryClass = aFactoryClass;
  		} else {
			[L4LogLog error: [NSString stringWithFormat:
								@"Failed to create factory for class with name \"%@\" " \
								"since it does not conform to the L4FactoryObject protocol.",
								[aFactoryClass className]]];
			[self release];
			self = nil;
  		}
 	}
 	
 	return self;
}

@end

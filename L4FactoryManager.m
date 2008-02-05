/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4FactoryManager.h"
#import "L4Factory.h"
#import "L4Properties.h"
#import "L4LogLog.h"
#import "L4AppenderProtocols.h"
#import "L4Filter.h"
#import "L4Layout.h"

@implementation L4FactoryManager

+ (id <L4Factory>) factory: (NSString *) factoryObjectClass ofKind: (Class) factoryKind
{
	id <L4Factory> newFactory = nil;
	
	Class factoryClass = NSClassFromString(factoryObjectClass);
	if ( factoryClass == nil ) {
	 	[L4LogLog error: [NSString stringWithFormat:@"Cannot find %@ class with name: \"%@\".", [factoryKind className], factoryObjectClass]];
	} else {
		//Oddly enough, isSubclassOfClass: is true for subclasses as well as the class itself.
	 	if ( ![factoryClass isSubclassOfClass: factoryKind] ) {
	  		[L4LogLog error: [NSString stringWithFormat:
								@"Failed to create factory with name \"%@\" " \
								"since it is not of the %@ class kind.",
								factoryObjectClass, [factoryKind className]]];
	 	} else {
	  		newFactory = [L4Factory factoryWithClass: factoryClass];
	 	}
	}
	
	return newFactory;
}

+ (id <L4Factory>) factory:(NSString *) factoryObjectClass 
				ofProtocol:(Protocol *) factoryProtocol 
				  withName:(NSString *) factoryProtocolName
{
	id <L4Factory> newFactory = nil;
	
	Class factoryClass = NSClassFromString(factoryObjectClass);
	if ( factoryClass == nil ) {
	 	[L4LogLog error: 
			[NSString stringWithFormat:@"Cannot find %@ class with name: \"%@\".", factoryProtocolName, factoryObjectClass]];
	} else {	  		
	 	if ( ![factoryClass conformsToProtocol: factoryProtocol] ) {
	  		[L4LogLog error: [NSString stringWithFormat: 
								@"Failed to create factory with name \"%@\" since it does not conform to the %@ protocol.",
								factoryObjectClass, factoryProtocolName]];
	 	} else {
	  		newFactory = [L4Factory factoryWithClass: factoryClass];
	 	}
	}
	
	return newFactory;
}

+ (id <L4Factory>) appenderFactory: (NSString *) factoryObjectClass
{
	return [self factory: factoryObjectClass ofProtocol: @protocol(L4Appender) withName: @"L4Appender"];
}

+ (id <L4Factory>) filterFactory: (NSString *) factoryObjectClass
{
	return [self factory: factoryObjectClass ofKind: [L4Filter class]];
}

+ (id <L4Factory>) layoutFactory: (NSString *) factoryObjectClass
{
	return [self factory: factoryObjectClass ofKind: [L4Layout class]];
}

@end

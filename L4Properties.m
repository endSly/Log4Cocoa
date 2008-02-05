/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4Properties.h"

static NSString *L4PropertiesCommentChar = @"#";

@implementation L4Properties
/* ********************************************************************* */
#pragma mark Class methods
/* ********************************************************************* */
+ (id) propertiesWithFileName:(NSString *) aName
{
 	return [[[L4Properties alloc] initWithFileName: aName] autorelease];
}

+ (id) propertiesWithProperties:(NSDictionary *) aProperties
{
 	return [[[L4Properties alloc] initWithProperties: aProperties] autorelease];
}

/* ********************************************************************* */
#pragma mark Instance methods
/* ********************************************************************* */

- (NSArray *) allKeys
{
 	return [properties allKeys];
}

- (int) count
{
 	return [properties count];
}

- (void)dealloc
{
	[properties release];
	properties = nil;
 	
	[super dealloc];
}

- (NSString *) description
{
 	return [properties description];
}

- (id) init
{
	return [self initWithFileName: nil];
}

- (id) initWithFileName:(NSString *) aName
{
	if ( self = [super init] ) {
		properties = [NSMutableDictionary dictionary];
  		
  		NSString *fileContents = [NSString stringWithContentsOfFile: aName];
  		
  		NSEnumerator *lineEnum = [[fileContents componentsSeparatedByString: @"\n"] objectEnumerator];
  		NSString *currentLine = nil;
  		while ( ( currentLine = [lineEnum nextObject] ) != nil ) {
			currentLine = [currentLine stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
				
			NSString *linePrefix = nil;
			if ( [currentLine length] >= [L4PropertiesCommentChar length] ) {
 				linePrefix = [currentLine substringToIndex: [L4PropertiesCommentChar length]];
			}
				
			if ( ![L4PropertiesCommentChar isEqualToString: linePrefix] ) {
				NSRange range = [currentLine rangeOfString: @"="];
				
				if ( ( range.location != NSNotFound ) && ( [currentLine length] > range.location + 1 ) ) {
					[properties setObject: [currentLine substringFromIndex: range.location + 1]
								   forKey: [currentLine substringToIndex: range.location]];
				}
			}
  		}
	}
	
	return self;
}

- (id) initWithProperties:(NSDictionary *) aProperties
{
	if ( self = [super init] ) {
  		properties = [aProperties retain];
 	}
 	
 	return self;
}

- (void) removeStringForKey: (NSString *) aKey
{
 	[properties removeObjectForKey: aKey];
}

- (void) setString: (NSString *) aString forKey: (NSString *) aKey
{
 	[properties setObject: aString forKey: aKey];
}

- (NSString *) stringForKey: (NSString *) aKey
{
 	return [self stringForKey: aKey withDefaultValue: nil];
}

- (NSString *) stringForKey: (NSString *) aKey withDefaultValue: (NSString *) aDefaultVal
{
 	NSString *string = [properties objectForKey: aKey];
 	
 	if ( string == nil ) {
  		return aDefaultVal;
 	} else {
  		return string;
 	}
}

- (L4Properties *) subsetForPrefix: (NSString *) aPrefix
{
 	NSMutableDictionary *subset = [NSMutableDictionary dictionaryWithCapacity: [properties count]];
 	
 	NSEnumerator *keyEnum = [[properties allKeys] objectEnumerator];
 	NSString *key = nil;
 	while ( ( key = [keyEnum nextObject] ) != nil ) {
  		NSRange range = [key rangeOfString: aPrefix options: 0 range: NSMakeRange(0, [key length])];
  		if ( range.location != NSNotFound ) {
			NSString *subKey = [key substringFromIndex: range.length];
			[subset setObject: [properties objectForKey: key] forKey: subKey];
  		}
 	}
 	
 	return [L4Properties propertiesWithProperties: subset];
}

/* ********************************************************************* */
#pragma mark Private methods
/* ********************************************************************* */
@end

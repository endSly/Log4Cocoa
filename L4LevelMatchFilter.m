/**
 * For copyright & license, see COPYRIGHT.txt.
 */
#import "L4LevelMatchFilter.h"
#import "L4LoggingEvent.h"
#import "L4Level.h"
#import "L4Properties.h"

@implementation L4LevelMatchFilter

- (id) initWithAcceptOnMatch:(BOOL)shouldAccept andLevelToMatch:(L4Level *)aLevel
{
	self = [super init];
	if (self != nil) {
		acceptOnMatch = shouldAccept;
		if (aLevel == nil) {
			self = nil;
			[NSException raise:NSInvalidArgumentException format:@"aLevel is not allowed to be nil."];
		} else {
			levelToMatch = [aLevel retain];
		}
	}
	return self;
}

- (id) initWithProperties:(L4Properties *)initProperties
{
	self = [super initWithProperties:initProperties];
	if (self != nil) {
		acceptOnMatch = YES;
		NSString *acceptIfMatched = [initProperties stringForKey:@"AcceptOnMatch"];
		if (acceptIfMatched) {
			acceptOnMatch = [acceptIfMatched boolValue];
		}
		
		NSString *levelName = [initProperties stringForKey:@"LevelToMatch"];
		
		if (levelName) {
			// Returns nil if no level with specified name is found
			levelToMatch = [[L4Level levelWithName:levelName] retain];
			
			if (levelToMatch == nil) {
				[NSException raise:L4PropertyMissingException 
							format:@"L4Level name [%@] not found.", levelName];
			}
		} else {
			[NSException raise:L4PropertyMissingException 
						format:@"LevelToMatch is a required property."];
		}
		
	}
	return self;
}

- (void) dealloc
{
	[levelToMatch release];
	[super dealloc];
}

- (BOOL) acceptOnMatch
{
	return acceptOnMatch;
}

- (L4Level *) levelToMatch
{
	return levelToMatch;
}

- (L4FilterResult) decide:(L4LoggingEvent *)event 
{
	// Default stance.
	L4FilterResult action = L4FilterNeutral;
	if ([[event level] intValue] == [levelToMatch intValue] || [levelToMatch intValue] == [[L4Level all] intValue]){
		action =  acceptOnMatch ? L4FilterAccept :L4FilterDeny;
	}
	
	return action;
}

@end

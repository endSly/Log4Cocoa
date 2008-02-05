/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4BasicConfigurator.h"
#import "L4Properties.h"

@implementation L4BasicConfigurator

+ (id) basicConfigurator 
{
 	return [[[L4BasicConfigurator alloc] init] autorelease];
}

- (id) init
{
 	self = [super initWithFileName:@""];
 	
 	if ( self != nil ) {
  		[properties setString: @"DEBUG, STDOUT" forKey: @"rootLogger"];
  		[properties setString: @"L4ConsoleAppender" forKey: @"appender.STDOUT"];
 	}
 	
 	return self;
}

@end

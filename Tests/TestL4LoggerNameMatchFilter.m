#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import "L4LoggerNameMatchFilter.h"
#import "L4Level.h"
#import "L4Logger.h"
#import "L4LoggingEvent.h"
#import "L4Properties.h"

/**
 * Unit tests for the L4LoggerNameMatchFilter class.
 */
@interface TestL4LoggerNameMatchFilter : SenTestCase {	
}

@end


@implementation TestL4LoggerNameMatchFilter
- (void) testInitWithAcceptOnMatchStringToMatch
{
	NSLog(@"==================================================== TestL4LoggerNameMatchFilter:testInitWithAcceptOnMatchStringToMatch");
	
	L4LoggerNameMatchFilter *filter = nil;
	STAssertThrowsSpecificNamed(filter = [[L4LoggerNameMatchFilter alloc] initWithAcceptOnMatch:NO stringToMatch:nil],
                                NSException, NSInvalidArgumentException, @"An exception should not have been raised.");
	STAssertThrowsSpecificNamed(filter = [[L4LoggerNameMatchFilter alloc] initWithAcceptOnMatch:NO stringToMatch:@""],
								NSException, NSInvalidArgumentException, @"An exception should not have been raised.");
	STAssertNoThrow(filter = [[L4LoggerNameMatchFilter alloc] initWithAcceptOnMatch:NO stringToMatch:@"foo"],
					@"An exception should not have been raised.");
}

- (void) testInitWithProperties
{
	NSLog(@"==================================================== TestL4LoggerNameMatchFilter:testInitWithProperties");
	L4Properties *properties = [L4Properties propertiesWithProperties:[NSDictionary dictionary]];
	
	L4LoggerNameMatchFilter *filter = nil;
	[properties setString:@"NO" forKey:@"AcceptOnMatch"];
	
	STAssertThrowsSpecificNamed(filter = [(L4LoggerNameMatchFilter *)[L4LoggerNameMatchFilter alloc] initWithProperties:properties],
								NSException, L4PropertyMissingException, @"An exception should not have been raised.");
    
	[properties setString:@"foo" forKey:@"StringToMatch"];
	STAssertNoThrow(filter = [(L4LoggerNameMatchFilter *)[L4LoggerNameMatchFilter alloc] initWithProperties:properties],
					@"An exception should not have been raised.");
	STAssertEqualObjects(@"foo", [filter stringToMatch], @"stringToMatch was not what was expected.");
}

- (void) testDecide
{
	NSLog(@"==================================================== TestL4LoggerNameMatchFilter:testDecide");
	
	L4LoggerNameMatchFilter *filter = nil;
	STAssertNoThrow(filter = [[L4LoggerNameMatchFilter alloc] initWithAcceptOnMatch:NO stringToMatch:@"Foo"],
					@"An exception should not have been raised.");
	
	OCMockObject *mockEvent = [OCMockObject mockForClass:[L4LoggingEvent class]];
	OCMockObject *mockLogger = [OCMockObject mockForClass:[L4Logger class]];
	[[[mockEvent stub] andReturn:mockLogger] logger];
	[[[mockLogger stub] andReturn:@"FooClass"] name];
	STAssertEquals(L4FilterDeny, [filter decide:(L4LoggingEvent *)mockEvent], 
				   @"Logging event should not have been allowed.");
	
	mockEvent = [OCMockObject mockForClass:[L4LoggingEvent class]];
	mockLogger = [OCMockObject mockForClass:[L4Logger class]];
	[[[mockEvent stub] andReturn:mockLogger] logger];
	[[[mockLogger stub] andReturn:@"BarClass"] name];
	STAssertEquals(L4FilterNeutral, [filter decide:(L4LoggingEvent *)mockEvent], 
				   @"Logging event should have been neutral.");
	
}

@end

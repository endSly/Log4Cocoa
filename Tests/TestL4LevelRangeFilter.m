#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import "L4LevelRangeFilter.h"
#import "L4Level.h"
#import "L4LoggingEvent.h"
#import "L4Properties.h"

/**
 * Unit tests for the L4LevelRangeFilter class.
 */
@interface TestL4LevelRangeFilter : SenTestCase {
}

@end


@implementation TestL4LevelRangeFilter
- (void) testInitWithAcceptOnMatchFromLevelToLevel
{
	NSLog(@"==================================================== TestL4LevelRangeFilter:testInitWithAcceptOnMatchFromLevelToLevel");
	
	L4LevelRangeFilter *filter = nil;
	STAssertNoThrow(filter = [[L4LevelRangeFilter alloc] initWithAcceptOnMatch:NO 
																	 fromLevel:[L4Level debug] 
																	   toLevel:[L4Level error]],
					@"An exception should not have been raised.");
	STAssertNoThrow(filter = [[L4LevelRangeFilter alloc] initWithAcceptOnMatch:NO 
																	 fromLevel:nil
																	   toLevel:[L4Level error]],
					@"An exception should not have been raised.");
	STAssertNoThrow(filter = [[L4LevelRangeFilter alloc] initWithAcceptOnMatch:NO 
																	 fromLevel:[L4Level debug] 
																	   toLevel:nil],
					@"An exception should not have been raised.");
	STAssertNoThrow(filter = [[L4LevelRangeFilter alloc] initWithAcceptOnMatch:YES 
																	 fromLevel:nil 
																	   toLevel:nil],
					@"An exception should not have been raised.");
}

- (void) testInitWithProperties
{
	NSLog(@"==================================================== TestL4LevelRangeFilter:testInitWithProperties");
	L4Properties *properties = [L4Properties propertiesWithProperties:[NSDictionary dictionary]];
	
	L4LevelRangeFilter *filter = nil;
	[properties setString:@"NO" forKey:@"AcceptOnMatch"];
	
	STAssertNoThrow(filter = [(L4LevelRangeFilter *)[L4LevelRangeFilter alloc] initWithProperties:properties],
					@"An exception should not have been raised.");
	STAssertNil([filter minimumLevelToMatch], @"The minimumLevelToMatch should have been nil.");
	STAssertNil([filter maximumLevelToMatch], @"The maximumLevelToMatch should have been nil.");
	STAssertFalse([filter acceptOnMatch], @"acceptOnMatch should have been NO");

	[properties setString:@"DEBUG" forKey:@"MinimumLevel"];
	[properties setString:@"ERROR" forKey:@"MaximumLevel"];
	STAssertNoThrow(filter = [(L4LevelRangeFilter *)[L4LevelRangeFilter alloc] initWithProperties:properties],
					@"An exception should not have been raised.");
	STAssertEqualObjects([L4Level debug], [filter minimumLevelToMatch], 
						 @"The minimumLevelToMatch was not what was expected.");
	STAssertEqualObjects([L4Level error], [filter maximumLevelToMatch], 
						 @"The maximumLevelToMatch was not what was expected.");
	
}

- (void) testDecide
{
	NSLog(@"==================================================== TestL4LevelRangeFilter:testDecide");
	
	L4LevelRangeFilter *filter = nil;
	STAssertNoThrow(filter = [[L4LevelRangeFilter alloc] initWithAcceptOnMatch:NO 
																	 fromLevel:[L4Level info] 
																	   toLevel:[L4Level error]],
					@"An exception should not have been raised.");
	
	OCMockObject *mockEvent = [OCMockObject mockForClass:[L4LoggingEvent class]];
	[[[mockEvent stub] andReturn:[L4Level info]] level];
	STAssertEquals(L4FilterDeny, [filter decide:(L4LoggingEvent *)mockEvent], 
				   @"Logging event should not have been allowed.");

	mockEvent = [OCMockObject mockForClass:[L4LoggingEvent class]];
	[[[mockEvent stub] andReturn:[L4Level debug]] level];
	STAssertEquals(L4FilterNeutral, [filter decide:(L4LoggingEvent *)mockEvent], 
				   @"Logging event should have been neutral.");
	
	mockEvent = [OCMockObject mockForClass:[L4LoggingEvent class]];
	[[[mockEvent stub] andReturn:[L4Level fatal]] level];
	STAssertEquals(L4FilterNeutral, [filter decide:(L4LoggingEvent *)mockEvent], 
				   @"Logging event should have been neutral.");
	
}

- (void) testDecide_minimumNil
{
	NSLog(@"==================================================== TestL4LevelRangeFilter:testDecide_minimumNil");
	
	L4LevelRangeFilter *filter = nil;
	STAssertNoThrow(filter = [[L4LevelRangeFilter alloc] initWithAcceptOnMatch:YES
																	 fromLevel:nil 
																	   toLevel:[L4Level error]],
					@"An exception should not have been raised.");
	
	OCMockObject *mockEvent = [OCMockObject mockForClass:[L4LoggingEvent class]];
	[[[mockEvent stub] andReturn:[L4Level info]] level];
	STAssertEquals(L4FilterAccept, [filter decide:(L4LoggingEvent *)mockEvent], 
				   @"Logging event should have been allowed.");
		
	mockEvent = [OCMockObject mockForClass:[L4LoggingEvent class]];
	[[[mockEvent stub] andReturn:[L4Level fatal]] level];
	STAssertEquals(L4FilterNeutral, [filter decide:(L4LoggingEvent *)mockEvent], 
				   @"Logging event should have been neutral.");
	
}

- (void) testDecide_maximumNil
{
	NSLog(@"==================================================== TestL4LevelRangeFilter:testDecide_maximumNil");
	
	L4LevelRangeFilter *filter = nil;
	STAssertNoThrow(filter = [[L4LevelRangeFilter alloc] initWithAcceptOnMatch:YES
																	 fromLevel:[L4Level info] 
																	   toLevel:nil],
					@"An exception should not have been raised.");
	
	OCMockObject *mockEvent = [OCMockObject mockForClass:[L4LoggingEvent class]];
	[[[mockEvent stub] andReturn:[L4Level info]] level];
	STAssertEquals(L4FilterAccept, [filter decide:(L4LoggingEvent *)mockEvent], 
				   @"Logging event should have been allowed.");
	
	mockEvent = [OCMockObject mockForClass:[L4LoggingEvent class]];
	[[[mockEvent stub] andReturn:[L4Level debug]] level];
	STAssertEquals(L4FilterNeutral, [filter decide:(L4LoggingEvent *)mockEvent], 
				   @"Logging event should have been neutral.");
	
	mockEvent = [OCMockObject mockForClass:[L4LoggingEvent class]];
	[[[mockEvent stub] andReturn:[L4Level fatal]] level];
	STAssertEquals(L4FilterAccept, [filter decide:(L4LoggingEvent *)mockEvent], 
				   @"Logging event should have been allowed.");
	
}

@end

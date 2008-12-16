#import <SenTestingKit/SenTestingKit.h>
#import "L4Properties.h"

@interface TestL4Properties : SenTestCase {
	NSDictionary *fullDictionary;
}
@end


@implementation TestL4Properties

- (void) setUp
{
	fullDictionary = [[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:@"L4ConsoleAppender", 
															@"false", 
															@"L4PatternLayout", 
															@"%-5p : %m%n", 
															@"L4RollingFileAppender", 
															@"10MB", 
															@"1", 
															@"L4PatternLayout", 
															@"DEBUG, A2", 
															@"INHERIT", nil] 
												   forKeys:[[NSArray alloc] initWithObjects:@"log4cocoa.appender.A1", 
															@"log4cocoa.appender.A1.LogToStandardOut",
															@"log4cocoa.appender.A1.layout", 
															@"log4cocoa.appender.A1.layout.ConversionPattern", 
															@"log4cocoa.appender.A2", 
															@"log4cocoa.appender.A2.MaximumFileSize", 
															@"log4cocoa.appender.A2.MaxBackupIndex", 
															@"log4cocoa.appender.A2.layout", 
															@"log4cocoa.rootLogger", 
															@"log4cocoa.logger.class_of_the_day", nil]];
	
}

- (void) testInitWithFileName
{
	NSLog(@"==================================================== TestL4Properties:testInitWithFileName");
	
	NSString *filename = [[NSBundle bundleForClass:[self class]] pathForResource:@"test" ofType:@"properties"];
	STAssertNotNil(filename, @"The test properties file could not be found.");
	
	L4Properties *properties = [L4Properties propertiesWithFileName:filename];
	STAssertNotNil(properties, @"L4Properties could not be instantiated.");
	STAssertEquals([properties count], 10, @"Expected 10 keys, but found %i", [properties count]);
	
	STAssertEqualObjects([properties stringForKey:@"log4cocoa.appender.A1"], @"L4ConsoleAppender", 
						 @"Expected 'L4ConsoleAppender', but found %@", 
						 [properties stringForKey:@"log4cocoa.appender.A1"]);
	STAssertEqualObjects([properties stringForKey:@"log4cocoa.appender.A1.LogToStandardOut"], @"false", 
						 @"Expected 'false', but found %@", 
						 [properties stringForKey:@"log4cocoa.appender.A1.LogToStandardOut"]);
	STAssertEqualObjects([properties stringForKey:@"log4cocoa.appender.A1.layout"], @"L4PatternLayout", 
						 @"Expected 'L4PatternLayout', but found %@", 
						 [properties stringForKey:@"log4cocoa.appender.A1.layout"]);
	STAssertEqualObjects([properties stringForKey:@"log4cocoa.appender.A1.layout.ConversionPattern"], @"%-5p : %m%n", 
						 @"Expected '%-5p : %m%n', but found %@", 
						 [properties stringForKey:@"log4cocoa.appender.A1.layout.ConversionPattern"]);
	STAssertEqualObjects([properties stringForKey:@"log4cocoa.appender.A2"], @"L4RollingFileAppender", 
						 @"Expected 'L4RollingFileAppender', but found %@", 
						 [properties stringForKey:@"log4cocoa.appender.A2"]);
	STAssertEqualObjects([properties stringForKey:@"log4cocoa.appender.A2.MaximumFileSize"], @"10MB", 
						 @"Expected '10MB', but found %@", 
						 [properties stringForKey:@"log4cocoa.appender.A2.MaximumFileSize"]);
	STAssertEqualObjects([properties stringForKey:@"log4cocoa.appender.A2.MaxBackupIndex"], @"1", 
						 @"Expected '1', but found %@", 
						 [properties stringForKey:@"log4cocoa.appender.A2.MaxBackupIndex"]);
	STAssertEqualObjects([properties stringForKey:@"log4cocoa.appender.A2.layout"], @"L4PatternLayout", 
						 @"Expected 'L4PatternLayout', but found %@", 
						 [properties stringForKey:@"log4cocoa.appender.A2.layout"]);
	STAssertEqualObjects([properties stringForKey:@"log4cocoa.rootLogger"], @"DEBUG, A2", 
						 @"Expected 'DEBUG, A2', but found %@", 
						 [properties stringForKey:@"log4cocoa.rootLogger"]);
	STAssertEqualObjects([properties stringForKey:@"log4cocoa.logger.class_of_the_day"], @"INHERIT", 
						 @"Expected 'INHERIT', but found %@", 
						 [properties stringForKey:@"log4cocoa.logger.class_of_the_day"]);
	
}

- (void) testInitWithProperties
{
	NSLog(@"==================================================== TestL4Properties:testInitWithProperties");

	L4Properties *properties = [L4Properties propertiesWithProperties:fullDictionary];
	STAssertNotNil(properties, @"L4Properties could not be instantiated.");
	STAssertEquals([properties count], 10, @"Expected 10 keys, but found %i", [properties count]);
	
	STAssertEqualObjects([properties stringForKey:@"log4cocoa.appender.A1"], @"L4ConsoleAppender", 
						 @"Expected 'L4ConsoleAppender', but found %@", 
						 [properties stringForKey:@"log4cocoa.appender.A1"]);
	STAssertEqualObjects([properties stringForKey:@"log4cocoa.appender.A1.LogToStandardOut"], @"false", 
						 @"Expected 'false', but found %@", 
						 [properties stringForKey:@"log4cocoa.appender.A1.LogToStandardOut"]);
	STAssertEqualObjects([properties stringForKey:@"log4cocoa.appender.A1.layout"], @"L4PatternLayout", 
						 @"Expected 'L4PatternLayout', but found %@", 
						 [properties stringForKey:@"log4cocoa.appender.A1.layout"]);
	STAssertEqualObjects([properties stringForKey:@"log4cocoa.appender.A1.layout.ConversionPattern"], @"%-5p : %m%n", 
						 @"Expected '%-5p : %m%n', but found %@", 
						 [properties stringForKey:@"log4cocoa.appender.A1.layout.ConversionPattern"]);
	STAssertEqualObjects([properties stringForKey:@"log4cocoa.appender.A2"], @"L4RollingFileAppender", 
						 @"Expected 'L4RollingFileAppender', but found %@", 
						 [properties stringForKey:@"log4cocoa.appender.A2"]);
	STAssertEqualObjects([properties stringForKey:@"log4cocoa.appender.A2.MaximumFileSize"], @"10MB", 
						 @"Expected '10MB', but found %@", 
						 [properties stringForKey:@"log4cocoa.appender.A2.MaximumFileSize"]);
	STAssertEqualObjects([properties stringForKey:@"log4cocoa.appender.A2.MaxBackupIndex"], @"1", 
						 @"Expected '1', but found %@", 
						 [properties stringForKey:@"log4cocoa.appender.A2.MaxBackupIndex"]);
	STAssertEqualObjects([properties stringForKey:@"log4cocoa.appender.A2.layout"], @"L4PatternLayout", 
						 @"Expected 'L4PatternLayout', but found %@", 
						 [properties stringForKey:@"log4cocoa.appender.A2.layout"]);
	STAssertEqualObjects([properties stringForKey:@"log4cocoa.rootLogger"], @"DEBUG, A2", 
						 @"Expected 'DEBUG, A2', but found %@", 
						 [properties stringForKey:@"log4cocoa.rootLogger"]);
	STAssertEqualObjects([properties stringForKey:@"log4cocoa.logger.class_of_the_day"], @"INHERIT", 
						 @"Expected 'INHERIT', but found %@", 
						 [properties stringForKey:@"log4cocoa.logger.class_of_the_day"]);
}

- (void) testSubsetForPrefix
{
	NSLog(@"==================================================== TestL4Properties:testSubsetForPrefix");
	
	L4Properties *fullProperties = [L4Properties propertiesWithProperties:fullDictionary];
	STAssertNotNil(fullProperties, @"L4Properties could not be instantiated.");
	
	L4Properties *properties = [fullProperties subsetForPrefix:@"log4cocoa.appender.A1"];
	STAssertEqualObjects([properties stringForKey:@""], @"L4ConsoleAppender", 
						 @"Expected 'L4ConsoleAppender', but found %@", 
						 [properties stringForKey:@""]);
	STAssertEqualObjects([properties stringForKey:@".LogToStandardOut"], @"false", 
						 @"Expected 'false', but found %@", 
						 [properties stringForKey:@".LogToStandardOut"]);
	STAssertEqualObjects([properties stringForKey:@".layout"], @"L4PatternLayout", 
						 @"Expected 'L4PatternLayout', but found %@", 
						 [properties stringForKey:@".layout"]);
	STAssertEqualObjects([properties stringForKey:@".layout.ConversionPattern"], @"%-5p : %m%n", 
						 @"Expected '%-5p : %m%n', but found %@", 
						 [properties stringForKey:@".layout.ConversionPattern"]);
}

@end

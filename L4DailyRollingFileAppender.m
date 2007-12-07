//
//  L4DailyRollingFileAppender.m
//  Log4Cocoa
//
//  Created by Michael James on Thu Apr 29 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "L4DailyRollingFileAppender.h"
#import "L4Layout.h"
#import <math.h>

@interface L4DailyRollingFileAppender (__PrivateMethods)

- (NSCalendarDate*)_lastRolloverDate;
- (void)_setLastRolloverDate: (NSDate*)date;
- (void)_rollOver;

@end

@implementation L4DailyRollingFileAppender

- (id)init
{
	return [self initWithLayout: nil fileName: nil rollingFrequency: never];
}

- (id)initWithLayout: (L4Layout*)aLayout fileName: (NSString*)aName rollingFrequency: (L4RollingFrequency)rollingFrequency
{
	self = [super initWithLayout: aLayout fileName: aName append: YES bufferIO: NO bufferSize: 0];
	
	if (self != nil)
	{
		[self setRollingFrequency: rollingFrequency];
	}
	
	return self;
}

- (void)dealloc
{
	[_lastRolloverDate release];
	_lastRolloverDate = nil;
	
	[super dealloc];
}

- (L4RollingFrequency)rollingFrequency
{
	return _rollingFrequency;
}

- (void)setRollingFrequency: (L4RollingFrequency)rollingFrequency
{	
	_rollingFrequency = rollingFrequency;
	[self _setLastRolloverDate: [NSCalendarDate calendarDate]];
}

@end

@implementation L4DailyRollingFileAppender (__ProtectedMethods)

- (void)subAppend: (L4LoggingEvent*)event
{
	// check if it's time to rollover, and if so, rollover
	[self _rollOver];	
	
	// call superclass's subAppend:
	[super subAppend: event];
}

@end

@implementation L4DailyRollingFileAppender (__PrivateMethods)

- (NSCalendarDate*)_lastRolloverDate
{
	return _lastRolloverDate;
}

- (void)_setLastRolloverDate: (NSDate*)date
{
	if ((NSDate*)_lastRolloverDate != date)
	{
		[_lastRolloverDate release];
		_lastRolloverDate = nil;
		_lastRolloverDate = [date retain];
	}
}

- (void)_rollOver
{
	NSCalendarDate*	now = nil;
	NSString*		pathExtension = nil;
	NSCalendarDate*	tempLastRolloverDate = nil;
	NSCalendarDate*	tempCalendarDate = nil, *tempCalendarDate2 = nil;
	NSString*		newFileName = nil;
	NSFileManager*	fm = nil;
	BOOL			rolloverTime = NO;

	fm = [NSFileManager defaultManager];

	// get the current date and time
	now = [NSCalendarDate calendarDate];

	// if the rolling frequency is never, return
	if (_rollingFrequency == never)
	{
		return;
	}

	// save a reference to the last rollover date, before we possible change it
	tempLastRolloverDate = [[self _lastRolloverDate] retain];

	// determine if we need to rollover now
	switch (_rollingFrequency)
	{
		case monthly:
		{
			// if the last rollover date and now are not in the same month of the same year, time to rollover
			if ([_lastRolloverDate monthOfYear] != [now monthOfYear] || [_lastRolloverDate yearOfCommonEra] != [now yearOfCommonEra])
			{
				rolloverTime = YES;

				// update the last rollover date to now
				[self _setLastRolloverDate: now];
			}
		}
			break;

		case weekly:
		{
			// first find the first days of the week for the last rollover date and now
			tempCalendarDate = [_lastRolloverDate dateByAddingYears: 0 months: 0 days: (0 - [_lastRolloverDate dayOfWeek]) hours: 0 minutes: 0 seconds: 0];
			tempCalendarDate2 = [now dateByAddingYears: 0 months: 0 days: (0 - [now dayOfWeek]) hours: 0 minutes: 0 seconds: 0];

			// if the last rollover date and now are not in the same week of the same year, time to rollover
			if ([tempCalendarDate dayOfYear] != [tempCalendarDate2 dayOfYear] || [tempCalendarDate yearOfCommonEra] != [tempCalendarDate2 yearOfCommonEra])
			{
				rolloverTime = YES;

				// update the last rollover date to now
				[self _setLastRolloverDate: now];
			}
		}
			break;

		case daily:
		{
			// if the last rollover date and now are not in the same day of the same year, time to rollover
			if ([_lastRolloverDate dayOfYear] != [now dayOfYear] || [_lastRolloverDate yearOfCommonEra] != [now yearOfCommonEra])
			{
				rolloverTime = YES;

				// update the last rollover date to now
				[self _setLastRolloverDate: now];
			}
		}
			break;

		case half_daily:
		{
			// if the last rollover date is between noon and midnight and now is between midnight and noon, time to rollover
			if ([_lastRolloverDate hourOfDay] >= 12 && [now hourOfDay] < 12)
			{
				rolloverTime = YES;

				// update the last rollover date to now
				[self _setLastRolloverDate: now];
			}
			// else if the last rollover date is between midnight and noon and now is between noon and midnight, time to rollover
			else if ([_lastRolloverDate hourOfDay] < 12 && [now hourOfDay] >= 12)
			{
				rolloverTime = YES;

				// update the last rollover date to now
				[self _setLastRolloverDate: now];
			}
		}
			break;

		case hourly:
		{
			// if the last rollover date is not the same hour of the same day of the same year as now, it is time to rollover
			if ([_lastRolloverDate hourOfDay] != [now hourOfDay]  || [_lastRolloverDate dayOfYear] != [now dayOfYear] || [_lastRolloverDate yearOfCommonEra] != [now yearOfCommonEra])
			{
				rolloverTime = YES;

				// update the last rollover date to now
				[self _setLastRolloverDate: now];
			}
		}
			break;

		case minutely:
		{
			// if the last rollover date is not the same minute of the same hour of the same day of the same year, it is time to rollover
			if ([_lastRolloverDate minuteOfHour] != [now minuteOfHour] || [_lastRolloverDate hourOfDay] != [now hourOfDay] || [_lastRolloverDate dayOfYear] != [now dayOfYear] || [_lastRolloverDate yearOfCommonEra] != [now yearOfCommonEra])
			{
				rolloverTime = YES;

				// update the last rollover date to now
				[self _setLastRolloverDate: now];
			}
		}
			break;

		default:
		{
			rolloverTime = NO;
		}
			break;
	}

	// if we have passed the rollover date
	if (rolloverTime)
	{
		// if rolling frequency is not never, calculate the path extension
		if (_rollingFrequency != never)
		{
			switch (_rollingFrequency)
			{
				case monthly:
				{
					pathExtension = [tempLastRolloverDate descriptionWithCalendarFormat: @"%Y-%m" timeZone: nil locale: nil];
				}
				break;

				case weekly:
				{
					pathExtension = [tempLastRolloverDate descriptionWithCalendarFormat: [@"%Y-%m-" stringByAppendingString: [NSString stringWithFormat: @"%d", floor([tempCalendarDate dayOfYear] / 7)]] timeZone: nil locale: nil];
				}
				break;

				case daily:
				{
					pathExtension = [tempLastRolloverDate descriptionWithCalendarFormat: @"%Y-%m-%d" timeZone: nil locale: nil];
				}
				break;

				case half_daily:
				{
					pathExtension = [tempLastRolloverDate descriptionWithCalendarFormat: @"%Y-%m-%d-%p" timeZone: nil locale: nil];
				}
				break;

				case hourly:
				{
					pathExtension = [tempLastRolloverDate descriptionWithCalendarFormat: @"%Y-%m-%d-%H" timeZone: nil locale: nil];
				}
				break;

				case minutely:
				{
					pathExtension = [tempLastRolloverDate descriptionWithCalendarFormat: @"%Y-%m-%d-%H-%M" timeZone: nil locale: nil];
				}
				break;
				
				default:
				{
					// ignore other values, if we are here, we got an illegal value so reset the rolling frequency to never
					[self setRollingFrequency: never];
				}
				break;
			}
		}

		[tempLastRolloverDate release];
		tempLastRolloverDate = nil;

		// generate the new rollover log file name
		newFileName = [[self fileName] stringByAppendingPathExtension: pathExtension];

		// close the current log file
		[self closeFile];

		// rename the current log file to the new rollover log file name
		if (![fm movePath: [self fileName] toPath: newFileName handler: nil])
		{
			// if we can't rename the file, raise an exception
			[NSException raise: @"CantMoveFileException" format: @"Unable to move file from %@ to %@", [self fileName], newFileName];
		}

		// re-activate this appender (this will open a new log file named [self fileName])
		[self activateOptions];
	}

	[tempLastRolloverDate release];
	tempLastRolloverDate = nil;
}

@end
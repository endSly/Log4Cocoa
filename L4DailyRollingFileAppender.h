/**
 * For copyright & license, see COPYRIGHT.txt.
 */


#import <Foundation/Foundation.h>
#import "L4FileAppender.h"

/*!
	@typedef L4RollingFrequency
	@abstract The accepted constants for L4DailyRollingFileAppenderFrequency's <code>setFrequency:</code> method.
	@constant never Never roll the file over (this is a default setting)
	@constant monthly Roll the file over every month
	@constant weekly Roll the file over every week
	@constant daily Roll the file over every day
	@constant half_daily Roll the file over every half day (once at midnight, once at noon)
	@constant hourly Roll the file over every hour
	@constant minutely Roll the file over every minute
*/
typedef enum L4RollingFrequency
{
	never,
	monthly,
	weekly,
	daily,
	half_daily,
	hourly,
	minutely
} L4RollingFrequency;

/*!
	@class L4DailyRollingFileAppender
	@discussion L4DailyRollingFileAppender extends L4FileAppender so that the underlying file is rolled over at a user-chosen frequency.

		For example, if the fileName is set to /foo/bar.log and the frequency is set to daily, on 2001-02-16 at midnight, the logging file /foo/bar.log will be copied to /foo/bar.log.2001-02-16 and logging for 2001-02-17 will continue in /foo/bar.log until it rolls over the next day.

		It is possible to specify monthly, weekly, half-daily, daily, hourly, or minutely rollover schedules.  
*/
@interface L4DailyRollingFileAppender : L4FileAppender
{
	L4RollingFrequency	_rollingFrequency;
	NSCalendarDate*		_lastRolloverDate;
}

/*!
	@method init
	@abstract This initializer calls the <code>initWithLayout:fileName:rollingFrequency:</code> method with the respective values: nil, nil, never
	@result An initialized instance of this class
*/
- (id)init;

/*!
	@method initWithLayout:fileName:rollingFrequency:
	@abstract Initializes an instance of this class with the specified layout, file name, and rolling frequency.
	@param aLayout The layout object for this appender
	@param aName The file path to the file in which you want logging output recorded
	@param rollingFrequency The frequency at which you want the log file rolled over
	@result An initialized instance of this class
*/
- (id)initWithLayout: (L4Layout*)aLayout fileName: (NSString*)aName rollingFrequency: (L4RollingFrequency)rollingFrequency;

/*!
	@method rollingFrequency
	@abstract Returns this object's rolling frequency.
	@result This object's rolling frequency
*/
- (L4RollingFrequency)rollingFrequency;

/*!
	@method setRollingFrequency:
	@abstract Sets the object's rolling frequency
	@param rollingFrequency The desired rolling frequency for this object
*/
- (void)setRollingFrequency: (L4RollingFrequency)rollingFrequency;

@end

/*!
	@category L4DailyRollingFileAppender (__ProtectedMethods)
	@discussion These methods are "protected" methods and should not be called except by subclasses.
*/
@interface L4DailyRollingFileAppender (__ProtectedMethods)

/*!
	@method subAppend:
	@discussion This method overrides the implementation in L4WriterAppender.  It checks if the rolling frequency has been exceeded.  If so, it rolls the file over.
	@param event An L4LoggingEvent that contains logging specific information
*/
- (void)subAppend: (L4LoggingEvent*)event;

@end
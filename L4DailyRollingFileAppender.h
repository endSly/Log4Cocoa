#import <Foundation/Foundation.h>
#import "L4FileAppender.h"

/**
 * The accepted constants for L4DailyRollingFileAppenderFrequency's <code>setFrequency:</code> method.
 */
typedef enum L4RollingFrequency
{
	never,		/**< Never roll the file. */
	monthly,	/**< Roll the file over every month. */
	weekly,		/**< Roll the file over every week. */
	daily,		/**< Roll the file over every day. */
	half_daily,	/**< Roll the file over every 12 hours. */
	hourly,		/**< Roll the file over every hour. */
	minutely	/**< Roll the file over every minute. */
} L4RollingFrequency;

/**
 * L4DailyRollingFileAppender extends L4FileAppender so that the underlying file is rolled over at a 
 * user-chosen frequency. For example, if the fileName is set to /foo/bar.log and the frequency is set
 * to daily, on 2001-02-16 at midnight, the logging file /foo/bar.log will be copied to /foo/bar.log.2001-02-16
 * and logging for 2001-02-17 will continue in /foo/bar.log until it rolls over the next day.
 * It is possible to specify monthly, weekly, half-daily, daily, hourly, or minutely rollover schedules.  
*/
@interface L4DailyRollingFileAppender : L4FileAppender
{
	L4RollingFrequency	rollingFrequency; /**< The frequency with which the file should be rolled.*/
	NSCalendarDate*		lastRolloverDate; /**< The date the last role-over ocured.*/
}

/**
 * This initializer calls the <code>initWithLayout:fileName:rollingFrequency:</code> method with the respective values: nil, nil, never.
 */
- (id)init;

/**
 * Initializes an instance of this class with the specified layout, file name, and rolling frequency.
 * @param aLayout The layout object for this appender
 * @param aName The file path to the file in which you want logging output recorded
 * @param aRollingFrequency The frequency at which you want the log file rolled over
 */
- (id)initWithLayout:(L4Layout*)aLayout fileName:(NSString*)aName rollingFrequency:(L4RollingFrequency)aRollingFrequency;

/**
 * Returns this object's rolling frequency.
 * @return This object's rolling frequency
 */
- (L4RollingFrequency)rollingFrequency;

/**
 Sets the object's rolling frequency
 * @param aRollingFrequency The desired rolling frequency for this object
 */
- (void)setRollingFrequency: (L4RollingFrequency)aRollingFrequency;

@end

/**
 * These methods are "protected" methods and should not be called except by subclasses.
*/
@interface L4DailyRollingFileAppender (ProtectedMethods)

/**
 This method overrides the implementation in L4WriterAppender.  It checks if the rolling frequency has been exceeded.
 * If so, it rolls the file over.
 * @param event An L4LoggingEvent that contains logging specific information.
 */
- (void)subAppend: (L4LoggingEvent*)event;

@end
// For copyright & license, see COPYRIGHT.txt.

#import <Foundation/Foundation.h>

#define	   L4LogLog_PREFIX @"log4cocoa: "
#define  L4LogLog_WARN_PREFIX @"log4cocoa: WARN: "
#define L4LogLog_ERROR_PREFIX @"log4cocoa: ERROR: "

@interface L4LogLog : NSObject {
}

+ (BOOL) internalDebuggingEnabled;
+ (void) setInternalDebuggingEnabled: (BOOL) enabled;

+ (BOOL) quietModeEnabled;
+ (void) setQuietModeEnabled: (BOOL) enabled;

/**
 * If debuging & !quietMode, debug messages get
 * sent to standard out, because Log4Cocoa classes
 * can't use Log4Cocoa loggers.
 */
+ (void) debug: (NSString *) message;
+ (void) debug: (NSString *) message exception: (NSException *) e;

/**
 * If !quietMode, warn & error messages get
 * sent to standard error, because Log4Cocoa classes
 * can't use Log4Cocoa loggers.
 */
+ (void) warn: (NSString *) message;
+ (void) warn: (NSString *) message exception: (NSException *) e;

+ (void) error: (NSString *) message;
+ (void) error: (NSString *) message exception: (NSException *) e;

+ (void) writeMessage: (NSString *) message withPrefix: (NSString *) prefix toFile: (NSFileHandle *) fileHandle exception: (NSException *) e;

@end
// For copyright & license, see COPYRIGHT.txt.

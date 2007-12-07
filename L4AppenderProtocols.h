/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import <Foundation/Foundation.h>

@class L4Logger, L4Filter, L4Layout, L4LoggingEvent;

@protocol L4OptionHandler <NSObject>

- (void) activateOptions;

@end

@protocol L4ErrorHandler <L4OptionHandler>

- (void) activateOptions;

- (void) setLogger: (L4Logger *) aLogger;

- (void) error: (NSString *) message;

- (void) error: (NSString *) message
     exception: (NSException *) e
     errorCode: (int) errorCode;

- (void) error: (NSString *) message
     exception: (NSException *) e
     errorCode: (int) errorCode
         event: (L4LoggingEvent *) event;

- (void) setAppender: (id) appender; // can't forward declare protocols, so check to see if the object responds
- (void) setBackupAppender: (id) appender;

@end


@protocol L4Appender <NSObject>

- (void) doAppend: (L4LoggingEvent *) anEvent;   // appender log this event

- (void) addFilter: (L4Filter *) newFilter;      // adds to end of list
- (L4Filter *) headFilter;   // returns first filter or nil of there are none
- (void) clearFilters;       // removes all filters from list
- (void) close;              // it is a programing error to append to a close appender

- (BOOL) requiresLayout;

- (NSString *) name;      // unique name of this appender
- (void) setName: (NSString *) aName;

- (L4Layout *) layout;
- (void) setLayout: (L4Layout *) aLayout;

- (id <L4ErrorHandler>) errorHandler;
- (void) setErrorHandler: (id <L4ErrorHandler>) anErrorHandler;

@end


@protocol L4AppenderAttachable <NSObject>

- (void) addAppender: (id <L4Appender>) newAppender;

- (NSEnumerator *) allAppenders;
- (NSArray *) allAppendersArray;

- (id <L4Appender>) appenderWithName: (NSString *) aName;
- (BOOL) isAttached: (id <L4Appender>) appender;

- (void) removeAllAppenders;
- (void) removeAppender: (id <L4Appender>) appender;
- (void) removeAppenderWithName: (NSString *) aName;

@end

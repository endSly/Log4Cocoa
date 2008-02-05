#import <Foundation/Foundation.h>
#import "L4FactoryProtocols.h"

@interface L4FactoryManager : NSObject {
    /**
     * If L4Factory instances were frequently needed, it might be worthwhile to
     * cache them, but since they are currently only needed at startup time, it
     * would be over-engineering to implement factory caching at this point.
     */
}

/**
 * Creates a factory for the specified appender class or returns nil if the
 * specified class is not of kind L4Appender.
 * @param factoryObjectClass the factory object's class name.
 * @return the requested factory or nil if the specified class is not of kind L4Appender.
 */
+ (id <L4Factory>) appenderFactory: (NSString *) factoryObjectClass;

/**
 * Creates a factory for the specified filter class or returns nil if the
 * specified class is not of kind L4Filter.
 * @param factoryObjectClass the factory object's class name.
 * @return the requested factory or nil if the specified class is not of kind L4Filter.
 */
+ (id <L4Factory>) filterFactory: (NSString *) factoryObjectClass;

/**
 * Creates a factory for the specified layout class or returns nil if the
 * specified class is not of kind L4Layout.
 * @param factoryObjectClass the factory object's class name.
 * @return the requested factory or nil if the specified class is not of kind L4Layout.
 */
+ (id <L4Factory>) layoutFactory: (NSString *) factoryObjectClass;

@end
// For copyright & license, see COPYRIGHT.txt.

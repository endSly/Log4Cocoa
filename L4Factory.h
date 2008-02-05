#import <Foundation/Foundation.h>
#import "L4FactoryProtocols.h"

@interface L4Factory : NSObject <L4Factory> {
    Class factoryClass;
}

/**
 * Creates a factory for the specified class.
 * @param aFactoryClass the factory object's class.
 */
+ (id <L4Factory>) factoryWithClass: (Class) aFactoryClass;

@end
// For copyright & license, see COPYRIGHT.txt.

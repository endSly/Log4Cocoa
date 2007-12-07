/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import <Foundation/Foundation.h>
@class L4Logger;

@interface L4NSObjectAdditions : NSObject {

}

@end

/******
 * Convience methods for all NSObject classes.
 * ### TODO - I should do the same thing for NSProxy???
 */

/*****
 * You probably will want to override these methods in your local base class
 * and provide caching local iVar, since these methods result in an NSDictionary
 * lookup each time they are called.  Actually its not a bad hit, but in a high
 * volume logging environment, it might make a difference.
 */
@interface NSObject (L4CocoaMethods)

+ (L4Logger *) l4Logger;
- (L4Logger *) l4Logger;

@end

/*****

CODE TO ADD TO YOUR BASE CLASS .h file declarations

L4Logger *myLoggerIVar; // instance variable

*/

/*****
 CODE TO ADD TO YOUR BASE CLASS .m file

static L4Logger *myLoggerClassVar; // static "class" variable

+ (L4Logger *) log
{
    if( myLoggerClassVar == nil )
    {
        myLoggerClassVar = [super logger];  
    }

    return myLoggerClassVar;
}

- (L4Logger *) log
{
    if( myLoggerIVar == nil )
    {
        myLoggerIVar = [super logger];  
    }

    return myLoggerIVar;
}

*/


//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import <Foundation/Foundation.h>

#import "___VARIABLE_classPrefix:identifier___Model.h"

#undef MODELKEY_LOADING
#define MODELKEY_LOADING  @"loading"

#undef MODELKEY_SUCCEED
#define MODELKEY_SUCCEED  @"succed"

#undef MODELKEY_SUCCEED_OLD
#define MODELKEY_SUCCEED_OLD  @"succedOld"

#undef MODELKEY_FAILED
#define MODELKEY_FAILED  @"failed"

#undef MODELKEY_TIMEOUT
#define MODELKEY_TIMEOUT  @"timeout"


#undef MODELOBJECTKEY_STEP
#define MODELOBJECTKEY_STEP @"step"

#undef MODELOBJECTKEY_OBJECT
#define MODELOBJECTKEY_OBJECT @"object"

@interface ___VARIABLE_classPrefix:identifier___ModelManager : NSObject
AS_SINGLETON(___VARIABLE_classPrefix:identifier___ModelManager)
AS_NOTIFICATION(TEST)

- (BOOL)getLoginUpdate:(NSDictionary*)dic;

@end

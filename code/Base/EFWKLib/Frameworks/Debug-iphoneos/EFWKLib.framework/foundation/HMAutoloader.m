//
//  HMAutoloader.m
//  CarAssistant
//
//  Created by Eric on 14-2-23.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMAutoloader.h"

@implementation HMAutoLoader

+(void)load{
    
    const char * autoLoadClasses[] = {
        //		"BeeHTTPMockServer",
        //		"BeeActiveRecord",
        //		"BeeModel",
        //		"BeeController",
        //		"BeeService",
        //		"BeeUITemplate",
		// ADD CLASS BEFLOW THIS LINE!!!!
		
		// here
		
		// DO NOT MODIFY
        //		"BeeUnitTest",
		"HMService",
        "HMUIKeyboard",
		NULL
	};
    
    PROGRESS([HMSystemInfo appName],
             [HMSystemInfo appShortVersion],
             [HMSystemInfo appIdentifier],
             [HMSystemInfo deviceModel],[HMSystemInfo OSVersion],
             [HMSandbox appPath],@"UUID",[HMSystemInfo deviceUUID]);
    
    for ( NSInteger i = 0;; ++i )
	{
		const char * className = autoLoadClasses[i];
		if ( NULL == className )
			break;
		
		Class classType = NSClassFromString( [NSString stringWithUTF8String:className] );
		if ( classType )
		{
            //			CC( @"Loading '%@' ...", [classType description] );
            
			BOOL succeed = [classType autoLoad];
			if ( succeed )
			{
                //				[__loadedClasses addObject:classType];
			}
		}
	}
}

@end


@implementation HMAutoLoad
+(BOOL)autoLoad{
    return NO;
}
- (void)load
{
	
}

- (void)unload
{
	
}

@end

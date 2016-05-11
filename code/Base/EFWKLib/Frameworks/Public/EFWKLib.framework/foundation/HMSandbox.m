//
//  HMSandbox.m
//  CarAssistant
//
//  Created by Eric on 14-3-2.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMSandbox.h"

#pragma mark -

@implementation HMSandbox

+ (NSString *)appPath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

+ (NSString *)docPath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

+ (NSString *)libPrefPath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	return [[paths objectAtIndex:0] stringByAppendingFormat:@"/Preference"];
}

+ (NSString *)libCachePath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	return [[paths objectAtIndex:0] stringByAppendingFormat:@"/Caches"];
}

+ (NSString *)tmpPath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	return [[paths objectAtIndex:0] stringByAppendingFormat:@"/tmp"];
}

+ (BOOL)touch:(NSString *)path
{
    return [self touch:path ignoreName:NO];
}

+ (BOOL)touchIgnoreName:(NSString *)path{
    return [self touch:path ignoreName:YES];
}

+ (BOOL)touch:(NSString *)path ignoreName:(BOOL)ignore{
    if ([path rangeOfString:@"/"].location!=NSNotFound) {
        NSMutableArray *arry = [[path componentsSeparatedByString:@"/"] mutableArray];
        if (ignore)[arry removeLastObject];
        
        NSString *pathName = [arry componentsJoinedByString:@"/"];
        if ( NO == [[NSFileManager defaultManager] fileExistsAtPath:pathName] )
        {
            return [[NSFileManager defaultManager] createDirectoryAtPath:pathName
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:NULL];
        }
    }
    
    return NO;
}

+ (NSString *)pathWithbundleName:(NSString*)bundleName fileName:(NSString *)file
{
    NSString *path = [[NSBundle mainBundle] resourcePath];
    if (bundleName) {
       path = [path stringByAppendingPathComponent: bundleName];
    }
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    path = [bundle resourcePath];
    
    if (file) {
        path = [path stringByAppendingPathComponent:file];
    }
    
    return path;
}


@end

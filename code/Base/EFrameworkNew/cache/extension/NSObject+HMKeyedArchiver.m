//
//  NSObject+HMKeyedArchiver.m
//  CarAssistant
//
//  Created by Eric on 14-4-23.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "NSObject+HMKeyedArchiver.h"

@implementation NSObject (HMKeyedArchiver)

- (NSString*)filePathArchiver{
    NSString *pathName = [NSString stringWithFormat:@"%@/archiver/",[HMSandbox libCachePath]];
    if ( NO == [[NSFileManager defaultManager] fileExistsAtPath:pathName] )
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:pathName
								  withIntermediateDirectories:YES
												   attributes:nil
														error:NULL];
	}
    return pathName;
}

- (void)removeAllObjectsForArchiver:(NSString *)branch{
    NSString * pathName = nil;
    if ( branch && [branch length] )
    {
        pathName = [self.filePathArchiver stringByAppendingFormat:@"%@/", branch];
    }
    else
    {
        pathName = self.filePathArchiver;
    }
#if (__ON__ == __HM_DEVELOPMENT__)
    CC(@"Caches",@"remove",pathName);
#endif
    [[NSFileManager defaultManager] removeItemAtPath:pathName error:NULL];
    [[NSFileManager defaultManager] createDirectoryAtPath:pathName
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
}

- (NSString *)saveWithArchiver:(NSString*)name{
    if (!class_conformsToProtocol([self class],@protocol(NSCoding))&&![self isKindOfClass:[NSArray class]]) {
        
        NSAssert(NO,@"self not contorms NSCoding");
        return nil;
    }
    
    NSString *file = [NSString stringWithFormat:@"%@/%@",self.filePathArchiver,name==nil?[NSString stringWithFormat:@"%@.archive",[self class]]:name];
    
    [HMSandbox touchIgnoreName:file];
    
    if ( [NSKeyedArchiver archiveRootObject:self toFile:file])
        return file;
    else
        return nil;
}

+ (instancetype)restoreWithArchiver:(NSString*)name{
    if (!class_conformsToProtocol([self class],@protocol(NSCoding))&&![self isKindOfClass:[NSArray class]]) {
        
        NSAssert(NO,@"self not contorms NSCoding");
        return nil;
    }
    NSString *file = [NSString stringWithFormat:@"%@/%@",self.filePathArchiver,name==nil?[NSString stringWithFormat:@"%@.archive",[self class]]:name];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:file];
}

+ (BOOL)hadSavedWithArchiver:(NSString *)name{
    NSString *file = [NSString stringWithFormat:@"%@/%@",self.filePathArchiver,name==nil?[NSString stringWithFormat:@"%@.archive",[self class]]:name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:nil]) {
        return YES;
    }
    return NO;
}

@end

@implementation NSObject (HMPlist)

- (NSString*)filePathPlist{
    NSString *pathName = [NSString stringWithFormat:@"%@/plist/",[HMSandbox libCachePath]];
    if ( NO == [[NSFileManager defaultManager] fileExistsAtPath:pathName] )
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:pathName
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    return pathName;
}

- (void)removeAllObjectsForPlist:(NSString *)branch{
    NSString * pathName = nil;
    if ( branch && [branch length] )
    {
        pathName = [self.filePathPlist stringByAppendingFormat:@"%@/", branch];
    }
    else
    {
        pathName = self.filePathPlist;
    }
#if (__ON__ == __HM_DEVELOPMENT__)
    CC(@"Caches",@"remove",pathName);
#endif
    [[NSFileManager defaultManager] removeItemAtPath:pathName error:NULL];
    [[NSFileManager defaultManager] createDirectoryAtPath:pathName
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
}

- (NSString *)saveWithPlist:(NSString*)name{
    if (![[self class] isSubclassOfClass:[NSDictionary class]]&&![[self class] isSubclassOfClass:[NSArray class]]) {
        
        NSAssert(NO,@"self not contorms NSDictionary or NSArray");
        return nil;
    }

    NSString *file = [NSString stringWithFormat:@"%@/%@",self.filePathPlist,name==nil?[NSString stringWithFormat:@"%@.plist",[self class]]:name];
    
    [HMSandbox touchIgnoreName:file];
    
    if (![(NSArray*)self writeToFile:file atomically:YES])return nil;
    
    return file;
}

+ (instancetype)restoreWithPlist:(NSString*)name{

    if (![[self class] isSubclassOfClass:[NSDictionary class]]&&![[self class] isSubclassOfClass:[NSArray class]]) {
        
        NSAssert(NO,@"self not contorms NSDictionary or NSArray");
        return nil;
    }
    NSString *file = [NSString stringWithFormat:@"%@/%@",self.filePathPlist,name==nil?[NSString stringWithFormat:@"%@.plist",[self class]]:name];
    if ([[self class] isSubclassOfClass:[NSDictionary class]]) {
        if ([[self class] isSubclassOfClass:[NSMutableDictionary class]])return [NSMutableDictionary dictionaryWithContentsOfFile:file];
        return [NSDictionary dictionaryWithContentsOfFile:file];
    }else{
        if ([[self class] isSubclassOfClass:[NSMutableArray class]])return [NSMutableArray arrayWithContentsOfFile:file];
        return [NSArray arrayWithContentsOfFile:file];
    }
}

+ (BOOL)hadSavedWithPlist:(NSString *)name{
    NSString *file = [NSString stringWithFormat:@"%@/%@",self.filePathPlist,name==nil?[NSString stringWithFormat:@"%@.plist",[self class]]:name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:nil]) {
        return YES;
    }
    return NO;
}

@end

//
//  NSObject+HMExtension.m
//  CloudDog
//
//  Created by Eric on 14-6-30.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "NSObject+HMExtension.h"


@implementation NSObject (HMExtension)

+ (IMP)swizzleSelector:(SEL)origSelector withIMP:(SEL)newSelector {
    
    Class class = [self class];
    Method origMethod = class_getInstanceMethod(class,
                                                origSelector);
//    Method newMethod = class_getInstanceMethod(class,
//                                                newSelector);
    IMP origIMP = method_getImplementation(origMethod);
    IMP newIMP = class_getMethodImplementation( class, newSelector );
    if(!class_addMethod(self, origSelector, newIMP,
                        method_getTypeEncoding(origMethod)))
    {
        method_setImplementation(origMethod, newIMP);
//        CC(@"Swizzle",@"swizzle method",[class description],origMethod,newMethod);
    }
    
    return origIMP;
}

- (void)unzip:(NSString*)path toDirectory:(NSString*)toDirectory{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]) {
        Class class = NSClassFromString(@"ZipArchive");
        if (class) {
            NSObject *za = [[[class alloc] init] autorelease];
            if ([za UnzipOpenFile:path]) {
                INFO(path,@"unzip to",toDirectory);
                [HMSandbox touch:toDirectory];
                BOOL ret = [za UnzipFileTo:toDirectory  overWrite: YES];
                if (NO == ret){} [za UnzipCloseFile];
            }
        }
        
    }
}

- (void)zip:(NSString*)path newName:(NSString*)newName{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]) {
        Class class = NSClassFromString(@"ZipArchive");
        if (class) {
            NSObject *za = [[[class alloc] init] autorelease];
            if ([za CreateZipFile2:path]) {
                INFO(path,@"zip to",newName);
                BOOL ret = [za addFileToZip:path newname:newName];
                if (NO == ret){} [za CloseZipFile2];
            }
        }
    }
}

@end

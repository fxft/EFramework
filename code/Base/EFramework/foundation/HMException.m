//
//  HMException.m
//  CarAssistant
//
//  Created by Eric on 14-4-2.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMException.h"
#import "HMMacros.h"
#import "HMFoundation.h"

@interface HMException ()

@end

@implementation HMException

@end

@implementation NSObject (UncaughtException)

- (void) onCrash_divByZero
{
	int zeroDivisor = 0;
	int result = 10 / zeroDivisor;
#pragma unused(result)
}

- (void) onCrash_deallocatedObject
{
	// Note: EXC_BAD_ACCESS errors tend to cause the app to close stdout,
	// which means you won't see the trace on your console.
	// It is, however, stored to the error log file.
	NSObject* object = [[NSObject alloc] init];
	[object release];
	NSLog(@"%@", object);
}

- (void) onCrash_outOfBounds
{
	NSArray* array = [NSArray arrayWithObject:[[[NSObject alloc] init] autorelease]];
	NSLog(@"%@", [array objectAtIndex:100]);
}

- (void) onCrash_unimplementedSelector
{
	id notAViewController = [NSData data];
	[notAViewController presentViewController:nil animated:YES completion:nil];
}

@end


//
//  HMPrecompile.h
//  CarAssistant
//
//  Created by Eric on 14-2-21.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

/**
 *  开发模式预设
 *  ARC兼容
 *
 */
#import <Foundation/Foundation.h>
#ifdef __OBJC__

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <TargetConditionals.h>

#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreLocation/CoreLocation.h>

#import <Accelerate/Accelerate.h>
#else	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import <WebKit/WebKit.h>

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#endif	// #ifdef __OBJC__
#pragma mark -
// ----------------------------------
// Option values
// ----------------------------------

#undef	__ON__
#define __ON__		(1)

#undef	__OFF__
#define __OFF__		(0)

#undef	__AUTO__

#ifdef DEBUG
#define __AUTO__	(1)
#else	// #ifdef _DEBUG
#define __AUTO__	(0)
#endif	// #ifdef _DEBUG
// ----------------------------------
// Global compile option
// ----------------------------------
#ifndef __HM_DEVELOPMENT__
#define __HM_DEVELOPMENT__			(__AUTO__)				// Whether the development model?
#endif

#ifndef __HM_LOG__
#define __HM_LOG__					(__HM_DEVELOPMENT__)	// Whether enable logging?
#endif

#ifndef __HM_LOG_STROE__
#define __HM_LOG_STROE__					(__OFF__)	// Whether enable logging stroe? 未实现
#endif

#ifndef __HM_LOG_CONSOLE__
#define __HM_LOG_CONSOLE__					(__ON__)	// Whether enable logging?
#endif

#ifndef __HM_LOG_DATABASE__
#define __HM_LOG_DATABASE__					(__HM_DEVELOPMENT__)	// Whether enable logging database?
#endif

// ----------------------------------
// Compatible with ARC
// ----------------------------------


#undef __bridge_type
#if !__has_feature(objc_arc)
#define __bridge_type
#else
#define __bridge_type __bridge
#endif

#undef __bridge_retain_type
#if !__has_feature(objc_arc)
#define __bridge_retain_type
#else
#define __bridge_retain_type __bridge_retain
#endif

#undef __bridge_transfer_type
#if !__has_feature(objc_arc)
#define __bridge_transfer_type
#else
#define __bridge_transfer_type __bridge_transfer
#endif

#undef __bridge_retained_type
#if !__has_feature(objc_arc)
#define __bridge_retained_type
#else
#define __bridge_retained_type __bridge_retained
#endif

#undef __autoreleasing_type
#if !__has_feature(objc_arc)
#define __autoreleasing_type
#else
#define __autoreleasing_type __autoreleasing
#endif

#undef __strong_type
#if !__has_feature(objc_arc)
#define __strong_type
#else
#define __strong_type __strong
#endif

#undef __unsafe_unretained_type
#if !__has_feature(objc_arc)
#define __unsafe_unretained_type
#else
#define __unsafe_unretained_type __unsafe_unretained
#endif

#undef __weak_type
#if !__has_feature(objc_arc)
#define __weak_type
#else
#define __weak_type __weak
#endif

#pragma mark -
#ifndef HM_STRONG
#if __has_feature(objc_arc)
#define HM_STRONG strong
#else
#define HM_STRONG retain
#endif
#endif

#ifndef HM_WEAK
#if __has_feature(objc_arc_weak)
#define HM_WEAK weak
#elif __has_feature(objc_arc)
#define HM_WEAK unsafe_unretained
#else
#define HM_WEAK assign
#endif
#endif

#if __has_feature(objc_arc)

#define HM_PROP_RETAIN					strong
#define HM_RETAIN( x )					(x)
#define HM_RELEASE( x )
#define HM_AUTORELEASE( x )			(x)
#define HM_BLOCK_COPY( x )				(x)
#define HM_BLOCK_RELEASE( x )
#define HM_SUPER_DEALLOC()
#define HM_AUTORELEASE_POOL_START()	@autoreleasepool {
#define HM_AUTORELEASE_POOL_END()		}

#else

#define HM_PROP_RETAIN					retain
#define HM_RETAIN( x )					[(x) retain]
#define HM_RELEASE( x )				[(x) release]
#define HM_AUTORELEASE( x )			[(x) autorelease]
#define HM_BLOCK_COPY( x )				Block_copy( x )
#define HM_BLOCK_RELEASE( x )			Block_release( x )
#define HM_SUPER_DEALLOC()				[super dealloc]
#define HM_AUTORELEASE_POOL_START()	NSAutoreleasePool * __pool = [[NSAutoreleasePool alloc] init];
#define HM_AUTORELEASE_POOL_END()		[__pool release];

#endif

#pragma mark -

#undef	SAFE_RELEASE_SUBLAYER
#define SAFE_RELEASE_SUBLAYER( __x ) \
{ \
    [__x removeFromSuperlayer]; \
    HM_RELEASE(__x); \
    __x = nil; \
}

#undef	SAFE_RELEASE_SUBVIEW
#define SAFE_RELEASE_SUBVIEW( __x ) \
{ \
    [__x removeFromSuperview]; \
    HM_RELEASE(__x); \
    __x = nil; \
}

#undef	SAFE_RELEASE
#define SAFE_RELEASE( __x ) \
{ \
    HM_RELEASE(__x); \
    __x = nil; \
}

#undef	SAFE_RELEASE_TIMER
#define SAFE_RELEASE_TIMER( __x ) \
{ \
    [__x invalidate];\
    HM_RELEASE(__x); \
    __x = nil; \
}

#undef	SAFE_RELEASE_MUTABLEARRAY
#define SAFE_RELEASE_MUTABLEARRAY( __x ) \
{ \
    [__x removeAllObjects];\
    HM_RELEASE(__x); \
    __x = nil; \
}

#pragma mark -

#undef	__INT
#define __INT( __x )			[NSNumber numberWithInteger:(NSInteger)__x]

#undef	__UINT
#define __UINT( __x )			[NSNumber numberWithUnsignedInt:(NSUInteger)__x]

#undef	__FLOAT
#define	__FLOAT( __x )			[NSNumber numberWithFloat:(float)__x]

#undef	__DOUBLE
#define	__DOUBLE( __x )			[NSNumber numberWithDouble:(double)__x]

#undef	__BOOL
#define __BOOL( __x )			[NSNumber numberWithBool:(BOOL)__x]

@interface HMPrecompile : NSObject

@end

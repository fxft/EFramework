//
//  HMMacros.m
//  CarAssistant
//
//  Created by Eric on 14-2-20.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMMacros.h"

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

@implementation UIView(LifeCycle)

+ (instancetype)spawn
{
	return [[[self alloc] init] autorelease];
}

+ (instancetype)view
{
	return [[[self alloc] init] autorelease];
}

- (void)initSelfDefault{
    
}

- (void)load
{
	
}

- (void)unload
{
	
}

@end

#pragma mark -

@implementation UIControl(LifeCycle)

- (void)initSelfDefault{
    
}

- (void)load
{
	
}

- (void)unload
{
	
}

@end



#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)


@implementation HMMacros

@end

//
//  HMException.h
//  CarAssistant
//
//  Created by Eric on 14-4-2.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (UncaughtException)

- (void) onCrash_divByZero;
- (void) onCrash_deallocatedObject;
- (void) onCrash_outOfBounds;
- (void) onCrash_unimplementedSelector;

@end

/**
 *  并没什么鸟用
 */
@interface HMException : NSObject

@end

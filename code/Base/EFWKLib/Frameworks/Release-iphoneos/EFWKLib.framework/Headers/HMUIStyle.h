//
//  HMUIStyle.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMMacros.h"
#import "HMUIStyleContext.h"
#import "UIView+Metrics.h"
#import "HMUIShape.h"
#import "UIColor+HMExtension.h"

typedef enum {
    TTPositionStatic,
    TTPositionAbsolute,
    TTPositionFloatLeft,
    TTPositionFloatRight,
} TTPosition;

@class HMUIStyleContext;

@interface HMUIStyle : NSObject{
    HMUIStyle* _next;
}

@property (nonatomic, HM_STRONG) HMUIStyle*         next;

- (id)initWithNext:(HMUIStyle*)next;

- (HMUIStyle*)next:(HMUIStyle*)next;

- (void)draw:(HMUIStyleContext*)context;

- (UIEdgeInsets)addToInsets:(UIEdgeInsets)insets forSize:(CGSize)size;
- (CGSize)addToSize:(CGSize)size context:(HMUIStyleContext*)context;

- (void)addStyle:(HMUIStyle*)style;

- (id)firstStyleOfClass:(Class)cls;
- (id)styleForPart:(NSString*)name;

@end

@interface HMUIStyle (StyleInner)

+ (CGGradientRef)newGradientWithColors:(UIColor**)colors locations:(CGFloat*)locations
                                 count:(int)count;

+ (CGGradientRef)newGradientWithColors:(UIColor**)colors count:(int)count;

@end

//
//  HMUIShape.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMMacros.h"
#import "UIView+Metrics.h"

extern const CGFloat kArrowPointWidth;
extern const CGFloat kArrowRadius;
/**
 * A constant denoting that a corner should be rounded.
 * @const -1
 */
extern const CGFloat ttkRounded;

#define TT_ROUNDED                    ttkRounded
#define RD(_RADIUS) (_RADIUS == TT_ROUNDED ? round(fh/2) : _RADIUS)


@interface HMUIShape : NSObject

+ (instancetype)shape;

- (void)openPath:(CGRect)rect;
- (void)closePath:(CGRect)rect;

- (void)addTopEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource;
- (void)addRightEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource;
- (void)addBottomEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource;
- (void)addLeftEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource;

/**
 * Opens the path, adds all edges, and closes the path.
 */
- (void)addToPath:(CGRect)rect;

- (void)addInverseToPath:(CGRect)rect;

- (UIEdgeInsets)insetsForSize:(CGSize)size;


@end

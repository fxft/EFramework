//
//  HMUISpeechBubbleShape.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIShape.h"

extern inline CGFloat SPEECH_LOCATION_TOP_OFFSET(CGFloat _offset);
extern inline CGFloat SPEECH_LOCATION_BOTTOM_OFFSET(CGFloat _offset);
extern inline CGFloat SPEECH_LOCATION_LEFT_OFFSET(CGFloat _offset);
extern inline CGFloat SPEECH_LOCATION_RIGHT_OFFSET(CGFloat _offset);

#define SPEECH_ARROW_RIGHT (180.f)
#define SPEECH_ARROW_LEFT (0.f)
#define SPEECH_ARROW_UP (90.f)
#define SPEECH_ARROW_DOWN (270.f)

@interface HMUISpeechBubbleShape : HMUIShape{
    CGFloat _radius;
    CGFloat _pointLocation;
    CGFloat _pointAngle;
    CGSize  _pointSize;
}

@property (nonatomic) CGFloat radius;
@property (nonatomic) CGFloat pointLocation;
@property (nonatomic) CGFloat pointAngle;//
@property (nonatomic) CGSize  pointSize;

/**
 * The shape that defines a rectangular shape with a pointer.
 * Radius - number of pixels for the rounded corners
 * pointLocation - location of the point where the top edge starts at 45, the right edge at 135,
 *                 the bottom edge at 225 and the left edge at 315.
 * pointAngle - not fgunctional yet. Make this equal to pointLocation in order to point it in the
 * right direction.
 * pointSize - the square in which the pointer will be defined, should be narrower or less high than
 *             the shape minus the radiuses.
 *
 * Pointers are not placed on the rounded corners.
 *
 * pointSize should be less wide or high than the edge that it is placed on minus 2 * radius.
 * radius should be smaller than the length of the edge / 2.
 *
 */
+ (HMUISpeechBubbleShape*)shapeWithRadius:(CGFloat)radius
                          pointLocation:(CGFloat)pointLocation
                             pointAngle:(CGFloat)pointAngle
                              pointSize:(CGSize)pointSize;


+ (HMUISpeechBubbleShape*)shapeTopWithRadius:(CGFloat)radius arrow:(CGFloat)offset pointSize:(CGSize)pointSize;
+ (HMUISpeechBubbleShape*)shapeBottomWithRadius:(CGFloat)radius arrow:(CGFloat)offset pointSize:(CGSize)pointSize;
+ (HMUISpeechBubbleShape*)shapeRightWithRadius:(CGFloat)radius arrow:(CGFloat)offset pointSize:(CGSize)pointSize;
+ (HMUISpeechBubbleShape*)shapeLeftWithRadius:(CGFloat)radius arrow:(CGFloat)offset pointSize:(CGSize)pointSize;

@end

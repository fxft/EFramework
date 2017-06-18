//
//  HMUIStarView.m
//  EFExtend
//
//  Created by mac on 15/8/18.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import "HMUIStarView.h"

@interface HMUIStarView ()
@property (nonatomic, readonly) BOOL shouldUseImages;
@end

@implementation HMUIStarView {
    CGFloat _minimumValue;
    NSUInteger _maximumValue;
    CGFloat _value;
}

@dynamic minimumValue;
@dynamic maximumValue;
@dynamic value;
@dynamic shouldUseImages;

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _customInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _customInit];
    }
    return self;
}

- (void)_customInit {
    self.exclusiveTouch = YES;
    _minimumValue = 0;
    _maximumValue = 5;
    _value = 0;
    _spacing = 5.f;
}

- (void)setNeedsLayout {
    [super setNeedsLayout];
    [self setNeedsDisplay];
}

#pragma mark - Properties

- (UIColor *)backgroundColor {
    if ([super backgroundColor]) {
        return [super backgroundColor];
    } else {
        return self.isOpaque ? [UIColor whiteColor] : [UIColor clearColor];
    };
}

- (CGFloat)minimumValue {
    return MAX(_minimumValue, 0);
}

- (void)setMinimumValue:(CGFloat)minimumValue {
    if (_minimumValue != minimumValue) {
        _minimumValue = minimumValue;
        [self setNeedsDisplay];
    }
}

- (NSUInteger)maximumValue {
    return MAX(_minimumValue, _maximumValue);
}

- (void)setMaximumValue:(NSUInteger)maximumValue {
    if (_maximumValue != maximumValue) {
        _maximumValue = maximumValue;
        [self setNeedsDisplay];
        [self invalidateIntrinsicContentSize];
    }
}

- (CGFloat)value {
    return MIN(MAX(_value, _minimumValue), _maximumValue);
}

- (void)setValue:(CGFloat)value {
    if (_value != value && value >= _minimumValue && value <= _maximumValue) {
        _value = value;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        [self setNeedsDisplay];
    }
}

- (void)setSpacing:(CGFloat)spacing {
    _spacing = MAX(spacing, 0);
    [self setNeedsDisplay];
}

- (void)setAllowsHalfStars:(BOOL)allowsHalfStars {
    if (_allowsHalfStars != allowsHalfStars) {
        _allowsHalfStars = allowsHalfStars;
        [self setNeedsDisplay];
    }
}

- (void)setEmptyStarImage:(UIImage *)emptyStarImage {
    if (_emptyStarImage != emptyStarImage) {
        [_emptyStarImage release];
        _emptyStarImage = [emptyStarImage retain];
        [self setNeedsDisplay];
    }
}

- (void)setHalfStarImage:(UIImage *)halfStarImage {
    if (_halfStarImage != halfStarImage) {
        [_halfStarImage release];
        _halfStarImage = [halfStarImage retain];
        [self setNeedsDisplay];
    }
}

- (void)setFilledStarImage:(UIImage *)filledStarImage {
    if (_filledStarImage != filledStarImage) {
        [_filledStarImage release];
        _filledStarImage = [filledStarImage retain];
        [self setNeedsDisplay];
    }
}

- (BOOL)shouldUseImages {
    return (self.emptyStarImage!=nil && self.filledStarImage!=nil);
}

#pragma mark - Image Drawing

- (void)_drawStarImageWithFrame:(CGRect)frame tintColor:(UIColor*)tintColor highlighted:(BOOL)highlighted {
    UIImage *image = highlighted ? self.filledStarImage : self.emptyStarImage;
    [self _drawImage:image frame:frame tintColor:tintColor];
}

- (void)_drawHalfStarImageWithFrame:(CGRect)frame tintColor:(UIColor *)tintColor {
    UIImage *image = self.halfStarImage;
    if (image == nil) {
        // first draw star outline
        [self _drawStarImageWithFrame:frame tintColor:tintColor highlighted:NO];
        
        image = self.filledStarImage;
        CGRect imageFrame = CGRectMake(0, 0, image.size.width * image.scale / 2.f, image.size.height * image.scale);
        frame.size.width /= 2.f;
        CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, imageFrame);
        UIImage *halfImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
        image = [halfImage imageWithRenderingMode:image.renderingMode];
        CGImageRelease(imageRef);
    }
    [self _drawImage:image frame:frame tintColor:tintColor];
}

- (void)_drawImage:(UIImage *)image frame:(CGRect)frame tintColor:(UIColor *)tintColor {
    if (image.renderingMode == UIImageRenderingModeAlwaysTemplate) {
        [tintColor setFill];
    }
    [image drawInRect:frame];
}

#pragma mark - Shape Drawing

- (void)_drawStarShapeWithFrame:(CGRect)frame tintColor:(UIColor*)tintColor highlighted:(BOOL)highlighted {
    UIBezierPath* starShapePath = UIBezierPath.bezierPath;
    [starShapePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.62723 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37309 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02500 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.37292 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37309 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39112 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.30504 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62908 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.20642 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97500 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78265 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.79358 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97500 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.69501 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62908 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39112 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.62723 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37309 * CGRectGetHeight(frame))];
    [starShapePath closePath];
    starShapePath.miterLimit = 4;
    
    if (highlighted) {
        [tintColor setFill];
        [starShapePath fill];
    }
    
    [tintColor setStroke];
    starShapePath.lineWidth = 1;
    [starShapePath stroke];
}

- (void)_drawHalfStarShapeWithFrame:(CGRect)frame tintColor:(UIColor *)tintColor {
    
    // first draw star outline
    [self _drawStarShapeWithFrame:frame tintColor:tintColor highlighted:NO];
    
    UIBezierPath* starShapePath = UIBezierPath.bezierPath;
    [starShapePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02500 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.37292 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37309 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39112 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.30504 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62908 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.20642 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97500 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78265 * CGRectGetHeight(frame))];
    [starShapePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02500 * CGRectGetHeight(frame))];
    [starShapePath closePath];
    starShapePath.miterLimit = 4;
    
    [tintColor setFill];
    [starShapePath fill];
    
    [tintColor setStroke];
    starShapePath.lineWidth = 1;
    [starShapePath stroke];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
    CGContextFillRect(context, rect);
    
    CGFloat availableWidth = rect.size.width - (_spacing * (_maximumValue - 1));
    CGFloat cellWidth = (availableWidth / _maximumValue);
    CGFloat starSide = (cellWidth <= rect.size.height) ? cellWidth : rect.size.height;
    for (int idx = 0; idx < _maximumValue; idx++) {
        CGPoint center = CGPointMake(cellWidth*idx + cellWidth/2 + _spacing*idx, rect.size.height/2);
        CGRect frame = CGRectMake(center.x - starSide/2, center.y - starSide/2, starSide, starSide);
        BOOL highlighted = (idx+1 <= ceilf(_value));
        if (_allowsHalfStars && highlighted && (idx+1 > _value)) {
            [self _drawHalfStarWithFrame:frame tintColor:self.tintColor];
        } else {
            [self _drawStarWithFrame:frame tintColor:self.tintColor highlighted:highlighted];
        }
    }
}

- (void)_drawStarWithFrame:(CGRect)frame tintColor:(UIColor *)tintColor highlighted:(BOOL)highlighted {
    if (self.shouldUseImages) {
        [self _drawStarImageWithFrame:frame tintColor:tintColor highlighted:highlighted];
    } else {
        [self _drawStarShapeWithFrame:frame tintColor:tintColor highlighted:highlighted];
    }
}

- (void)_drawHalfStarWithFrame:(CGRect)frame tintColor:(UIColor *)tintColor {
    if (self.shouldUseImages) {
        [self _drawHalfStarImageWithFrame:frame tintColor:tintColor];
    } else {
        [self _drawHalfStarShapeWithFrame:frame tintColor:tintColor];
    }
}

#pragma mark - Touches

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    if (![self isFirstResponder]) {
        [self becomeFirstResponder];
    }
    [self _handleTouch:touch];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    [self _handleTouch:touch];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    if ([self isFirstResponder]) {
        [self resignFirstResponder];
    }
    [self _handleTouch:touch];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
    if ([self isFirstResponder]) {
        [self resignFirstResponder];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return !self.isUserInteractionEnabled;
}

- (void)_handleTouch:(UITouch *)touch {
    CGFloat cellWidth = self.bounds.size.width / _maximumValue;
    CGPoint location = [touch locationInView:self];
    CGFloat value = location.x / cellWidth;
    if (_allowsHalfStars && value+.5f < ceilf(value)) {
        self.value = floor(value)+.5f;
    } else {
        self.value = ceilf(value);
    }
}

#pragma mark - First responder

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - Intrinsic Content Size

- (CGSize)sizeThatFits:(CGSize)size{
    CGSize filled = self.filledStarImage.size;
    CGSize empty = self.emptyStarImage.size;
    CGSize half = self.halfStarImage.size;
    
    CGFloat height = MAX(MAX(filled.height, empty.height), half.height);
    height = height==0?44.f:height;
    return CGSizeMake(_maximumValue * height + (_maximumValue-1) * _spacing, height);
}

- (CGSize)intrinsicContentSize {
    CGSize filled = self.filledStarImage.size;
    CGSize empty = self.emptyStarImage.size;
    CGSize half = self.halfStarImage.size;

    CGFloat height = MAX(MAX(filled.height, empty.height), half.height);
    height = height==0?44.f:height;
    return CGSizeMake(_maximumValue * height + (_maximumValue-1) * _spacing, height);
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString *)accessibilityLabel {
    return [super accessibilityLabel] ?: NSLocalizedString(@"Rating", @"Accessibility label for star rating control.");
}

- (UIAccessibilityTraits)accessibilityTraits {
    return ([super accessibilityTraits] | UIAccessibilityTraitAdjustable);
}

- (NSString *)accessibilityValue {
    return [@(self.value) description];
}

- (BOOL)accessibilityActivate {
    return YES;
}

- (void)accessibilityIncrement {
    self.value += self.allowsHalfStars ? .5f : 1.f;
}

- (void)accessibilityDecrement {
    self.value -= self.allowsHalfStars ? .5f : 1.f;
}

- (void)dealloc
{
    self.emptyStarImage = nil;
    self.filledStarImage = nil;
    self.halfStarImage = nil;
    
    HM_SUPER_DEALLOC();
}
@end

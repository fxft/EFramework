//
//  HMUIProgressView.m
//  GPSService
//
//  Created by Eric on 14-4-16.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIProgressView.h"
#import "HMViewCategory.h"

#import <QuartzCore/QuartzCore.h>

@protocol ProgressLayerProtocal <NSObject>
@property(nonatomic, HM_STRONG) UIColor *trackTintColor;
@property(nonatomic, HM_STRONG) UIColor *progressTintColor;
@property(nonatomic, HM_STRONG) UIColor *trackBorderTintColor;
@property(nonatomic, HM_STRONG) UIColor *progressBorderTintColor;
@property(nonatomic) NSInteger roundedCorners;
@property(nonatomic) CGFloat thicknessRatio;
@property(nonatomic) CGFloat progress;
@property(nonatomic) CGFloat radius;
@property(nonatomic) CGFloat trackHeight;
@property(nonatomic) CGFloat spotlightPoint;
@property(nonatomic) BOOL spotlightEnable;
@property(nonatomic) CGFloat hasBorder;
@end

@interface DACircularProgressLayer : CALayer<ProgressLayerProtocal>


@end

@implementation DACircularProgressLayer

@dynamic trackTintColor;
@dynamic progressTintColor;
@dynamic trackBorderTintColor;
@dynamic progressBorderTintColor;

@dynamic roundedCorners;
@dynamic thicknessRatio;
@dynamic progress;
@dynamic radius;
@dynamic trackHeight;
@dynamic spotlightPoint;
@dynamic spotlightEnable;
@dynamic hasBorder;

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    return [key isEqualToString:@"progress"] ? YES : [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds;
    CGPoint centerPoint = CGPointMake(rect.size.height / 2.0f, rect.size.width / 2.0f);
    CGFloat radius = MIN(rect.size.height, rect.size.width) / 2.0f;
    
    CGFloat progress = MIN(self.progress, 1.0f - FLT_EPSILON);
    CGFloat radians = (progress * 2.0f * M_PI) - M_PI_2;
    
    CGContextSetFillColorWithColor(context, self.trackTintColor.CGColor);
    CGMutablePathRef trackPath = CGPathCreateMutable();
    CGPathMoveToPoint(trackPath, NULL, centerPoint.x, centerPoint.y);
    CGPathAddArc(trackPath, NULL, centerPoint.x, centerPoint.y, radius, 3.0f * M_PI_2, -M_PI_2, NO);
    CGPathCloseSubpath(trackPath);
    CGContextAddPath(context, trackPath);
    CGContextFillPath(context);
    CGPathRelease(trackPath);
    
    if (progress > 0.0f)
    {
        CGContextSetFillColorWithColor(context, self.progressTintColor.CGColor);
        CGMutablePathRef progressPath = CGPathCreateMutable();
        CGPathMoveToPoint(progressPath, NULL, centerPoint.x, centerPoint.y);
        CGPathAddArc(progressPath, NULL, centerPoint.x, centerPoint.y, radius, 3.0f * M_PI_2, radians, NO);
        CGPathCloseSubpath(progressPath);
        CGContextAddPath(context, progressPath);
        CGContextFillPath(context);
        CGPathRelease(progressPath);
    }
    
    if (progress > 0.0f && self.roundedCorners)
    {
        CGFloat pathWidth = radius * self.thicknessRatio;
        CGFloat xOffset = radius * (1.0f + ((1.0f - (self.thicknessRatio / 2.0f)) * cosf(radians)));
        CGFloat yOffset = radius * (1.0f + ((1.0f - (self.thicknessRatio / 2.0f)) * sinf(radians)));
        CGPoint endPoint = CGPointMake(xOffset, yOffset);
        
        CGContextAddEllipseInRect(context, CGRectMake(centerPoint.x - pathWidth / 2.0f, 0.0f, pathWidth, pathWidth));
        CGContextFillPath(context);
        
        CGContextAddEllipseInRect(context, CGRectMake(endPoint.x - pathWidth / 2.0f, endPoint.y - pathWidth / 2.0f, pathWidth, pathWidth));
        CGContextFillPath(context);
    }
    
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGFloat innerRadius = radius * (1.0f - self.thicknessRatio);
    CGPoint newCenterPoint = CGPointMake(centerPoint.x - innerRadius, centerPoint.y - innerRadius);
    CGContextAddEllipseInRect(context, CGRectMake(newCenterPoint.x, newCenterPoint.y, innerRadius * 2.0f, innerRadius * 2.0f));
    CGContextFillPath(context);
}

@end


@interface DALineProgressLayer : CALayer<ProgressLayerProtocal>

@end

@implementation DALineProgressLayer

@dynamic trackTintColor;
@dynamic progressTintColor;
@dynamic trackBorderTintColor;
@dynamic progressBorderTintColor;
@dynamic roundedCorners;
@dynamic thicknessRatio;
@dynamic progress;
@dynamic radius;
@dynamic trackHeight;
@dynamic spotlightPoint;
@dynamic spotlightEnable;
@dynamic hasBorder;

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    return ([key isEqualToString:@"progress"]||[key isEqualToString:@"spotlightPoint"]) ? YES : [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds;
//    CGPoint centerPoint = CGPointMake(rect.size.height / 2.0f, rect.size.width / 2.0f);
    CGFloat radius = (rect.size.height-self.trackHeight) / 2.0f;
    CGFloat radians = self.radius;
    CGFloat progress = MIN(self.progress, 1.0f);
    
    
    
    CGFloat fh = self.trackHeight;
    if (radians>fh/2) {
        radians = floor(fh/2);
    }
    CGFloat border = self.hasBorder;
    CGRect frame = rect;
    frame = CGRectEdgeInsets(frame, UIEdgeInsetsVerAndHor(radius+border, border));
    CGFloat fw = frame.size.width;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, fw, floor(fh/2));
    CGPathAddArcToPoint(path, NULL, fw, fh, floor(fw/2), fh, RD(radians));
    CGPathAddArcToPoint(path, NULL, 0, fh, 0, floor(fh/2), RD(radians));
    CGPathAddArcToPoint(path, NULL, 0, 0, floor(fw/2), 0, RD(radians));
    CGPathAddArcToPoint(path, NULL, fw, 0, fw, floor(fh/2), RD(radians));
    CGPathCloseSubpath(path);
    
    CGContextTranslateCTM(context, frame.origin.x, frame.origin.y);
    
    CGContextSaveGState(context);
    
    CGContextAddPath(context, path);
    CGContextSetFillColorWithColor(context, self.trackTintColor.CGColor);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    
    if (progress > 0.0f)
    {
        fw *= progress;
        CGRect frame = rect;
        frame.size = CGSizeMake(fw, frame.size.height);
        
        CGContextSaveGState(context);
        CGContextClipToRect(context, frame);
        CGContextAddPath(context, path);
        CGContextSetFillColorWithColor(context, self.progressTintColor.CGColor);
        CGContextFillPath(context);
        
        CGContextRestoreGState(context);
        
        if (self.spotlightEnable) {
            
            CGContextSaveGState(context);
            
            CGFloat spotRadius = ceil(rect.size.width/10);
            CGPoint spotOrigin = CGPointMake(rect.size.width * self.spotlightPoint-spotRadius,
                                             fh/2.f);
            
            
            CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
            CGFloat components[] = {1, 1, 1, .6, 0, 0, 0, 0};
            CGFloat locations[] = {0, 1};
            
//            CGRect frame = rect;
//            frame.size = CGSizeMake(fw, frame.size.height);
//            frame = CGRectEdgeInsets(frame, UIEdgeInsetsVerAndHor(-radius-1/2.f, -1/2.f));
            
            CGContextAddPath(context, path);
            CGContextClip(context);
            CGContextSetBlendMode(context, kCGBlendModePlusLighter);
            
            CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, locations, 2);
            CGContextDrawRadialGradient(context, gradient, spotOrigin, 0, spotOrigin, spotRadius, 0);
            CGGradientRelease(gradient);
            CGColorSpaceRelease(space);
            
            CGContextRestoreGState(context);
        }
        
        if (progress<1.f&&self.progressBorderTintColor) {
            
            CGContextSaveGState(context);
            CGRect frame = CGRectMake(fw-radians/2, -2, radians/2, fh+4);
            CGContextSetShadowWithColor(context, CGSizeMake(1, 1), 6, self.progressBorderTintColor.CGColor);
            CGContextAddRect(context, frame);
            CGContextSetFillColorWithColor(context, RGBA(255, 255, 255, 1).CGColor);
            
            CGContextFillPath(context);
            CGContextRestoreGState(context);
        }

    }
    if (self.trackBorderTintColor) {
        CGContextSaveGState(context);
        CGContextAddPath(context, path);
        CGContextSetStrokeColorWithColor(context, self.trackBorderTintColor.CGColor);
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    }
    CGPathRelease(path);
}

@end

@interface HMUIProgressView ()

@property (nonatomic,HM_STRONG) CALayer<ProgressLayerProtocal> *progressLayer;

@end


@implementation HMUIProgressView{
    UIProgressType _progressType;
    CGFloat _progress;
    UIView *_indeterminateView;
}
@synthesize progressLayer;
@synthesize progressType=_progressType;
@synthesize progress = _progress;
@synthesize indeterminateView = _indeterminateView;


- (DACircularProgressLayer *)circularProgressLayer
{
    return (DACircularProgressLayer *)self.progressLayer;
}

- (id)init
{
    return [super initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
}

- (void)dealloc
{
    self.progressLayer = nil;
    self.trackTintColor = nil;
    self.progressTintColor = nil;
    self.trackBorderTintColor = nil;
    self.progressBorderTintColor = nil;
    self.indeterminateView = nil;

    HM_SUPER_DEALLOC();
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
    
        
    }
    return self;
}

- (void)awakeFromNib{
    [self initSelfDefault];
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSelfDefault];
    }
    return self;
}

- (void)initSelfDefault{
    
    self.progressType = UIProgressTypeCircle;
}

- (void)setProgressType:(UIProgressType)progressType{
    CGRect frame = self.bounds;
    if (_progressType!=progressType) {
        _progressType = progressType;
        
        if (self.progressLayer) {
            [self.progressLayer removeFromSuperlayer];
        }
        if (_progressType==UIProgressTypeLine) {
            self.progressLayer = [[[DALineProgressLayer alloc]init]autorelease];
            [self.progressLayer setTrackTintColor:RGBA(181, 181, 181, .9)];
            [self.progressLayer setProgressTintColor:RGBA(21, 140, 255, .9)];
        }else if (_progressType==UIProgressTypeCircle){
            self.progressLayer = [[[DACircularProgressLayer alloc]init]autorelease];
            [self.progressLayer setTrackTintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3f]];
            [self.progressLayer setProgressTintColor:[UIColor whiteColor]];
            CGFloat border = MIN(frame.size.height, frame.size.width);
            frame = CGRectInset(frame, (frame.size.width-border)/2.0, (frame.size.height-border)/2.0);
        }
        
        [self.progressLayer setThicknessRatio:0.3f];
        [self.progressLayer setRoundedCorners:NO];
        
        [self.progressLayer setRadius:5.f];
        [self.progressLayer setTrackHeight:4.f];//ceilf(.8*self.height)];
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setIndeterminateDuration:4.0f];
        [self setIndeterminate:NO];
       
        
        [self.layer addSublayer:self.progressLayer];
        [self.progressLayer setNeedsDisplay];
    }
    if (_progressType==UIProgressTypeCircle){
        CGFloat border = MIN(frame.size.height, frame.size.width);
        frame = CGRectInset(frame, (frame.size.width-border)/2.0, (frame.size.height-border)/2.0);
    }
    [self.progressLayer setFrame:frame];
}

- (void)didMoveToWindow
{
    CGFloat windowContentsScale = self.window.screen.scale;
    self.circularProgressLayer.contentsScale = windowContentsScale;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.progressType = self.progressType;
}

#pragma mark - Progress

- (CGFloat)progress
{
    return _progress;//self.circularProgressLayer.progress;
}

- (void)setProgress:(CGFloat)progress
{
    [self setProgress:progress animated:NO];
}

- (void)setLayerProgress{
    self.circularProgressLayer.progress = _progress;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated{
    [self setProgress:progress animated:animated duration:1.f];
}

- (void)setProgress:(CGFloat)progress duration:(NSTimeInterval)duration{
    [self setProgress:progress animated:YES duration:duration];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated duration:(NSTimeInterval)duration
{
    self.hidden = NO;
    
    CGFloat pinnedProgress = MIN(MAX(progress, 0.0f), 1.0f);
    CGFloat oldProgress = _progress;
    _progress = pinnedProgress;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setLayerProgress) object:self];
    
    if (animated)
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"progress"];
        animation.duration = fabs(oldProgress - pinnedProgress)*duration; // Same duration as UIProgressView animation
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.fromValue = [NSNumber numberWithFloat:oldProgress];
        animation.toValue = [NSNumber numberWithFloat:pinnedProgress];
        animation.fillMode = kCAFillModeForwards ;
        animation.removedOnCompletion = NO;
        [self.circularProgressLayer addAnimation:animation forKey:@"progress"];
        [self performSelector:@selector(setLayerProgress) withObject:self afterDelay:.25f inModes:@[NSRunLoopCommonModes]];
    }
    else
    {
        self.circularProgressLayer.progress = pinnedProgress;
        [self.circularProgressLayer removeAnimationForKey:@"progress"];
        [self.circularProgressLayer setNeedsDisplay];
    }
   
//#if (__ON__ == __HM_DEVELOPMENT__)
//    CC( @"UIProgress",@"Progress:%.2f",pinnedProgress);
//#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
}

- (void)delayToHide:(NSTimeInterval)delay{
    self.alpha=1.f;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideSelf) object:nil];
    [self performSelector:@selector(hideSelf) withObject:nil afterDelay:delay];
    
}

- (void)hideSelf{
    [UIView animateWithDuration:.25f animations:^{
        self.alpha=0.f;
    } completion:^(BOOL finished) {
        self.alpha=1.f;
        self.hidden = YES;
    }];
}

- (void)setIndeterminateView:(UIView *)indeterminateView{
    if (_indeterminateView) {
        [_indeterminateView removeFromSuperview];
        [_indeterminateView release];
    }
    _indeterminateView = [indeterminateView retain];
    
    if (_indeterminateView) {
        _indeterminateView.hidden = YES;
        [self addSubview:_indeterminateView];
    }
    
}

#pragma mark - UIAppearance methods

- (CGFloat)trackHeight{
    return self.circularProgressLayer.trackHeight;
}

- (void)setTrackHeight:(CGFloat)trackHeight{
    self.circularProgressLayer.trackHeight = trackHeight;
    [self.circularProgressLayer setNeedsDisplay];
}

- (CGFloat)radius{
    return self.circularProgressLayer.radius;
}

- (void)setRadius:(CGFloat)radius{
    self.circularProgressLayer.radius = radius;
    [self.circularProgressLayer setNeedsDisplay];
}

- (UIColor *)trackTintColor
{
    return self.circularProgressLayer.trackTintColor;
}

- (void)setTrackTintColor:(UIColor *)trackTintColor
{
    self.circularProgressLayer.trackTintColor = trackTintColor;
    [self.circularProgressLayer setNeedsDisplay];
}

- (UIColor *)progressTintColor
{
    return self.circularProgressLayer.progressTintColor;
}

- (void)setProgressTintColor:(UIColor *)progressTintColor
{
    self.circularProgressLayer.progressTintColor = progressTintColor;
    [self.circularProgressLayer setNeedsDisplay];
}


- (UIColor *)progressBorderTintColor{
    return self.circularProgressLayer.progressBorderTintColor;
}

- (void)setProgressBorderTintColor:(UIColor *)progressBorderTintColor{
    self.circularProgressLayer.progressBorderTintColor = progressBorderTintColor;
    [self.circularProgressLayer setNeedsDisplay];
}

- (UIColor *)trackBorderTintColor{
     return self.circularProgressLayer.trackBorderTintColor;
}

- (void)setTrackBorderTintColor:(UIColor *)trackBorderTintColor{
    self.circularProgressLayer.trackBorderTintColor = trackBorderTintColor;
    [self.circularProgressLayer setNeedsDisplay];
}

- (NSInteger)roundedCorners
{
    return self.roundedCorners;
}

- (void)setRoundedCorners:(NSInteger)roundedCorners
{
    self.circularProgressLayer.roundedCorners = roundedCorners;
    [self.circularProgressLayer setNeedsDisplay];
}

- (CGFloat)thicknessRatio
{
    return self.circularProgressLayer.thicknessRatio;
}

- (void)setThicknessRatio:(CGFloat)thicknessRatio
{
    self.circularProgressLayer.thicknessRatio = MIN(MAX(thicknessRatio, 0.f), 1.f);
    [self.circularProgressLayer setNeedsDisplay];
}

- (NSInteger)hasBorder{
    return self.circularProgressLayer.hasBorder;
}

- (void)setHasBorder:(NSInteger)hasBorder{
    self.circularProgressLayer.hasBorder = hasBorder;
    [self.circularProgressLayer setNeedsDisplay];
}

- (NSInteger)indeterminate
{
    CAAnimation *spinAnimation = [self.layer animationForKey:@"indeterminateAnimation"];
    return (spinAnimation == nil ? 0 : 1);
}

- (void)setIndeterminate:(NSInteger)indeterminate
{
    if (indeterminate && !self.indeterminate)
    {
        if (self.progressType==UIProgressTypeCircle) {
            CABasicAnimation *spinAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
            spinAnimation.byValue = [NSNumber numberWithFloat:2.0f*M_PI];
            spinAnimation.duration = self.indeterminateDuration;
            spinAnimation.repeatCount = HUGE_VALF;
            if (self.indeterminateView) {
                _indeterminateView.hidden = NO;
                if ([_indeterminateView isKindOfClass:[UIImageView class]]&&[(UIImageView *)_indeterminateView animationImages].count>0) {
                    [(UIImageView *)_indeterminateView startAnimating];
                }else{
                    [self.indeterminateView.layer addAnimation:spinAnimation forKey:@"indeterminateAnimation"];
                }
            }else{
                [self.circularProgressLayer addAnimation:spinAnimation forKey:@"indeterminateAnimation"];
            }
        }else if (self.progressType == UIProgressTypeLine){
            self.circularProgressLayer.spotlightEnable = YES;
            CABasicAnimation *spinAnimation = [CABasicAnimation animationWithKeyPath:@"spotlightPoint"];
            spinAnimation.toValue = [NSNumber numberWithFloat:1.5f];
            spinAnimation.fromValue = [NSNumber numberWithFloat:-.5f];
            spinAnimation.duration = self.indeterminateDuration;
            spinAnimation.repeatCount = HUGE_VALF;
            [self.circularProgressLayer addAnimation:spinAnimation forKey:@"spotlightPoint"];
        }
    }
    else
    {
         if (self.progressType==UIProgressTypeCircle) {
             if (self.indeterminateView) {
                 _indeterminateView.hidden = YES;
                 if ([_indeterminateView isKindOfClass:[UIImageView class]]&&[(UIImageView *)_indeterminateView animationImages].count>0) {
                     [(UIImageView *)_indeterminateView stopAnimating];
                 }else{
                     [self.indeterminateView.layer removeAnimationForKey:@"indeterminateAnimation"];
                 }
             }else{
                 [self.circularProgressLayer removeAnimationForKey:@"indeterminateAnimation"];
             }
         }else if (self.progressType == UIProgressTypeLine){
             self.circularProgressLayer.spotlightEnable = NO;
            [self.circularProgressLayer removeAnimationForKey:@"spotlightPoint"];
         }
    }
}

@end

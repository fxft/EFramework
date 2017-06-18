//
//  UIView+HMExtension.m
//  CarAssistant
//
//  Created by Eric on 14-3-9.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "UIView+HMExtension.h"
@interface __HMBackgroundImageView : UIImageView
@end

#pragma mark -

@implementation __HMBackgroundImageView
@end

#pragma mark -

@implementation HMUIShadowImageView
@synthesize style=_style;
@synthesize color=_color;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _shadowOffset = CGPointMake(-4, -4);
    }
    return self;
}
- (void)dealloc
{
    self.color = nil;
    HM_SUPER_DEALLOC();
}
- (CGSize)intrinsicContentSize{
    CGSize size = [super intrinsicContentSize];
    return size;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self resetView];
}

- (void)setStyle:(StyleEmbossShadow)style{
    
    if (_style!=style) {
        _style = style;
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}

- (void)setColor:(UIColor *)color{
    if (_color!=color) {
        [_color release];
        _color = [color retain];
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
    
}

- (void)setBlur:(CGFloat)blur{
    if (_blur!=blur) {
        _blur = blur;
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}

- (void)setLevel:(CGFloat)level{
    if (_level!=level) {
        _level = level;
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }

}

- (void)setShadowOffset:(CGPoint)shadowOffset{
    if (!CGPointEqualToPoint(_shadowOffset, shadowOffset)) {
        _shadowOffset = shadowOffset;
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}


- (void)resetView{
    UIImage *load = [UIImage imageEmbossStyle:_style blur:self.blur level:self.level color:self.color];
    self.image = load;
    CGSize imageSize = self.image.size;
    CGFloat offf = floor(imageSize.width/3);
    switch (_style) {
        case styleEmbossDarkLineLeft:
            self.x = -load.size.width;
            self.y = 0;
            self.height = self.superview.height;
            self.width = load.size.width;
            break;
        case styleEmbossDarkLineRight:
            self.x = self.superview.width;
            self.y = 0;
            self.height = self.superview.height;
            self.width = load.size.width;
            break;
        case styleEmbossDarkLineTop:
            self.y = -load.size.height;
            self.x = 0;
            self.width = self.superview.width;
            self.height = load.size.height;
            break;
        case styleEmbossDarkLineBottom:
            self.width = self.superview.width;
            self.x = 0;
            self.y = self.superview.height;
            self.height = load.size.height;
            break;
        case styleEmbossDarkLineLeftBottom:
            self.frame = CGRectEdgeInsets(self.superview.bounds, UIEdgeInsetsMake(self.shadowOffset.y, -offf, -offf, self.shadowOffset.x));
            break;
        case styleEmbossDarkLineRightBottom:
            self.frame = CGRectEdgeInsets(self.superview.bounds, UIEdgeInsetsMake(self.shadowOffset.y, self.shadowOffset.x, -offf, -offf));
            break;
        case styleEmbossDarkLineLeftTop:
            self.frame = CGRectEdgeInsets(self.superview.bounds, UIEdgeInsetsMake(-offf, -offf, self.shadowOffset.y, self.shadowOffset.x));
            break;
        case styleEmbossDarkLineRightTop:
            self.frame = CGRectEdgeInsets(self.superview.bounds, UIEdgeInsetsMake(-offf, self.shadowOffset.x, self.shadowOffset.y, -offf));
            break;
        case styleEmbossDarkLineLeftBottomRight:
            self.frame = CGRectEdgeInsets(self.superview.bounds, UIEdgeInsetsMake(self.shadowOffset.y, -offf, -offf, -offf));
            break;
        case styleEmbossDarkLineLeftTopRight:
            self.frame = CGRectEdgeInsets(self.superview.bounds, UIEdgeInsetsMake(-offf, -offf, self.shadowOffset.y, -offf));
            break;
        case styleEmbossDarkLineTopRightBottom:
            self.frame = CGRectEdgeInsets(self.superview.bounds, UIEdgeInsetsMake(-offf, self.shadowOffset.x, -offf, -offf));
            break;
        case styleEmbossDarkLineTopLeftBottom:
            self.frame = CGRectEdgeInsets(self.superview.bounds, UIEdgeInsetsMake(-offf, -offf, -offf, self.shadowOffset.x));
            break;
        case styleEmbossDarkLineArround:
            self.frame = CGRectEdgeInsets(self.superview.bounds, UIEdgeInsetsAll(-offf));
            break;
        default:
            self.width = self.superview.width;
            self.x = 0;
            self.y = self.superview.height;
            self.height = load.size.height;
            break;
    }
    
}


@end

@interface __BeeFrameTextLabel : UILabel
@end

#pragma mark -

@implementation __BeeFrameTextLabel

- (void)layoutSubviews{
    [super layoutSubviews];
    self.text = [NSString stringWithFormat:@"(%.1f,%.1f,%.1f,%.1f)",self.superview.x,self.superview.y,self.superview.w,self.superview.h];
    [self sizeToFit];
    self.y = 0;
}
@end


@implementation HMBadgeLabel{
    BOOL yes;
}
@synthesize type=_type;
@synthesize color=_color;
@synthesize maxSize=_maxSize;
@synthesize minSize=_minSize;
@synthesize textLabel;
@synthesize autoPosition;
@synthesize customPosition;
@synthesize text=_text;

- (id)init
{
    self = [super init];
    if (self) {
        self.autoPosition = 1;
        textLabel= [[UILabel spawn]retain];
        self.backgroundColor = [UIColor clearColor];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textAlignment = UITextAlignmentCenter;
        textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        [self addSubview:textLabel];
    }
    return self;
}

- (void)didMoveToWindow{
    
    [self resetStyle];
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    if (yes) {
        [self.superview removeObserver:self forKeyPath:@"frame"];
    }
    if (newSuperview) {
        [newSuperview addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        yes= YES;
    }else{
        yes = NO;
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqual:@"frame"]) {
        NSValue *value = [change valueForKey:@"new"];
        CGRect frame = CGRectZero;
        [value getValue:&frame];
        frame = self.frame;
        [self resetStyle];
    }
}

- (void)setType:(BadgeType)type{
    _type = type;
    [self resetStyle];
}

- (void)setColor:(UIColor *)color{
    if (_color) {
        [_color release];
    }
    _color = [color retain];
    [self resetStyle];
}


- (void)resetStyle{
    if (textLabel.text==nil) {
        self.style__ = nil;
        [self setNeedsDisplay];
        return;
    }
    switch (_type) {
        case badgeType_Extrude:
            self.style__ = [HMUIStyleSheet badgeExtrudeWithFillColor:_color];
            break;
        case badgeType_Flatten:
            self.style__ = [HMUIStyleSheet badgeFlattenWithFillColor:_color];
            break;
        case badgeType_FlattenBorder:
            self.style__ = [HMUIStyleSheet badgeFlattenBorderWithFillColor:_color];
            break;
        default:
            break;
    }
    ///计算出text大小 设置最小值
    [textLabel sizeToFit];
    CGRect frame = textLabel.frame;
    UIEdgeInsets inset = [self styleInsets];
    CGRect minFrame = [self styleMinBounds];
    if (textLabel.text.length==0) {
        
        frame.size.height = minFrame.size.width-minFrame.size.height;
        
    }else{
        if (_maxSize.height==0) {
            _maxSize.height = frame.size.height;
        }
        if (_maxSize.width==0) {
            _maxSize.width = frame.size.width;
        }
        frame.size.height = MAX(MIN(_maxSize.height, frame.size.height), _minSize.height);
        frame.size.width = MAX(MAX(frame.size.height, MIN(_maxSize.width, frame.size.width)), _minSize.width);
    }
    frame.size.height += inset.top+inset.bottom;
    frame.size.width += inset.left+inset.right;
    UIView *superV = self.superview;
    if (superV) {
        CGPoint point = CGPointZero;
        //0:none 1:top-right 2:top-left 3:center  4:bottom-right 5:bottom-left
        switch (self.autoPosition) {
            case badgeAutoPosition_Top_right:
                point = CGPointMake(superV.width-frame.size.width-2, 2);
                break;
            case badgeAutoPosition_Center:
                point = CGPointMake((superV.width-frame.size.width)/2, (superV.height-frame.size.height)/2);
                break;
            case badgeAutoPosition_Center_left:
                point = CGPointMake(0, (superV.height-frame.size.height)/2);
                break;
            case badgeAutoPosition_Center_right:
                point = CGPointMake(superV.width-frame.size.width-2, (superV.height-frame.size.height)/2);
                break;
            case badgeAutoPosition_Bottom_right:
                point = CGPointMake(superV.width-frame.size.width-2, superV.height-frame.size.height-2);
                break;
            case badgeAutoPosition_Bottom_left:
                point = CGPointMake(0, superV.height-frame.size.height-2);
                break;
            case badgeAutoPosition_Custom:
                point = self.customPosition;
                break;
            default:
                break;
        }
        frame.origin = point;
    }
    self.frame = frame;
    frame.origin = CGPointZero;
    textLabel.frame = CGRectEdgeInsets(frame, inset);
    [self setNeedsDisplay];
    
    //    minFrame = CGRectMakeBound(MAX(minFrame.size.width, frame.size.height), MAX(minFrame.size.height, frame.size.height));
    //    frame.size = CGSizeMake(MAX(minFrame.size.width, MIN(_maxSize.width, self.width)), MAX(minFrame.size.height, MIN(_maxSize.height, self.height)));
    //    UIView *superV = self.superview;
    //    if (superV) {
    //        frame.origin = CGPointMake(superV.width-frame.size.width-2, 2);
    //    }
    //    self.frame = frame;
    //    UIEdgeInsets inset = [self styleInsets];
    //
    //    textLabel.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsTBAndHor(inset.top, inset.bottom, 0));
    //    [self setNeedsDisplay];
}

- (void)setMaxSize:(CGSize)maxSize{
    _maxSize = maxSize;
    [self resetStyle];
}

- (void)setText:(NSString *)text{
    [textLabel setText:text];
    [self resetStyle];
}

- (void)dealloc
{
    [textLabel release];
    self.color = nil;
    HM_SUPER_DEALLOC();
}

@end

#undef	KEY_TAGSTRING
#define KEY_TAGSTRING	"UIView.tagString"

@implementation UIView (HMExtension)
@dynamic tagString;
@dynamic badgeText;
@dynamic badgeTextLabel;
@dynamic backgroundImageView;
@dynamic backgroundImage;

+ (instancetype)viewFromXib{
    
    NSArray *nib = [[NSBundle mainBundle]loadNibNamed:[[self class] description] owner:self options:nil];
    return [nib lastObject];
    
}


- (NSString *)tagString
{
    NSObject * obj = objc_getAssociatedObject( self, KEY_TAGSTRING );
    if ( obj && [obj isKindOfClass:[NSString class]] )
        return (NSString *)obj;
    
    return nil;
}

- (void)setTagString:(NSString *)value
{
    objc_setAssociatedObject( self, KEY_TAGSTRING, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

- (UIView *)viewWithTagString:(NSString *)value
{
    if ( nil == value )
        return nil;
    
    for ( UIView * subview in self.subviews )
    {
        NSString * tag = subview.tagString;
        if ( [tag isEqualToString:value] )
        {
            return subview;
        }
    }
    
    return nil;
}

- (UIViewController *)viewController
{
    UIView * view = self;
    for (UIView* next = view; next; next = next.superview) {
        UIResponder * nextResponder = [next nextResponder];
        if ( [nextResponder isKindOfClass:[UIViewController class]] )
        {
            return (UIViewController *)nextResponder;
        }
    }
    
    return nil;
}
- (UIView *)getSubviewFor:(UIView*)view class:(Class)clazz{
    UIView *vv = nil;
    for ( UIView * subView in view.subviews ){
        
        if ([subView isKindOfClass:clazz]) {
            vv = subView;
        }else{
            vv = [self getSubviewFor:subView class:clazz];
        }
        if (vv) {
            break;
        }
    }
    return vv;
}

#pragma mark -
- (HMBadgeLabel *)badgeLabel
{
    HMBadgeLabel * _badgeLabel = nil;
    
    for ( UIView * subView in self.subviews )
    {
        if ( [subView isKindOfClass:[HMBadgeLabel class]] )
        {
            _badgeLabel = (HMBadgeLabel *)subView;
            break;
        }
    }
    
    if ( nil == _badgeLabel )
    {
        _badgeLabel = [HMBadgeLabel spawn];
        _badgeLabel.frame = CGRectMake(self.width-25, 0, 25, 25);
        _badgeLabel.autoresizesSubviews = YES;
        _badgeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
        
        [self addSubview:_badgeLabel];
        [self bringSubviewToFront:_badgeLabel];
    }
    
    return (HMBadgeLabel*)_badgeLabel;
}

- (HMBadgeLabel*)setBadgeType:(NSInteger)type color:(UIColor *)color maxSize:(CGSize)maxSize{
    HMBadgeLabel *label = [self badgeLabel];
    label.type = type;
    label.color = color;
    label.maxSize = maxSize;
    return label;
}

- (NSString *)badgeText{
    return [self badgeLabel].text;
}

- (void)setBadgeText:(NSString *)badgeText{
    [self badgeLabel].text = badgeText;
}

- (UILabel *)badgeTextLabel{
    return [[self badgeLabel] textLabel];
}

#pragma mark -

- (UIImageView *)backgroundImageView
{
    UIImageView * imageView = nil;
    
    for ( UIView * subView in self.subviews )
    {
        if ( [subView isKindOfClass:[__HMBackgroundImageView class]] )
        {
            imageView = (UIImageView *)subView;
            break;
        }
    }
    if (imageView==nil&&[self isKindOfClass:[UITableViewCell class]]) {
        for ( UIView * subView in self.subviews )
        {
            for (UIView * subsubView in subView.subviews) {
                if ( [subsubView isKindOfClass:[__HMBackgroundImageView class]] )
                {
                    imageView = (UIImageView *)subsubView;
                    break;
                }
            }
            if (imageView) {
                break;
            }
        }
        //        imageView = (UIImageView*)[self getSubviewFor:self class:[__HMBackgroundImageView class]];
    }
    
    if ( nil == imageView )
    {
        imageView = [[[__HMBackgroundImageView alloc] initWithFrame:self.bounds] autorelease];
        imageView.autoresizesSubviews = YES;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
        imageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:imageView];
        [self sendSubviewToBack:imageView];
    }
    
    return imageView;
}

- (UIImage *)backgroundImage
{
    return self.backgroundImageView.image;
}

- (void)setBackgroundImage:(UIImage *)image
{
    UIImageView * imageView = self.backgroundImageView;
    if ( imageView )
    {
        if ( image )
        {
            imageView.image = image;
            imageView.frame = self.bounds;
            [imageView setNeedsDisplay];
        }
        else
        {
            imageView.image = nil;
            [imageView removeFromSuperview];
        }
    }
}

#pragma mark -
- (void)hideBackgroundShadowStyle:(StyleEmbossShadow)style{
    HMUIShadowImageView * imageView = [self shadowImageViewWithStyle:style];
    imageView.hidden = YES;
}

- (HMUIShadowImageView*)shadowImageViewWithStyle:(StyleEmbossShadow)style{
    HMUIShadowImageView * imageView = nil;
    
    for ( HMUIShadowImageView * subView in self.subviews )
    {
        if ( [subView isKindOfClass:[HMUIShadowImageView class]]&&subView.style == style )
        {
            imageView = (HMUIShadowImageView *)subView;
            break;
        }
    }
    
    if (imageView==nil&&[self isKindOfClass:[UITableViewCell class]]) {
        for ( UIView * subView in self.subviews )
        {
            for (HMUIShadowImageView * subsubView in subView.subviews) {
                if ( [subsubView isKindOfClass:[HMUIShadowImageView class]] &&subsubView.style == style)
                {
                    imageView = (HMUIShadowImageView *)subsubView;
                    break;
                }
            }
            if (imageView) {
                break;
            }
        }
    }
    return imageView;
}

- (UIImageView *)showBackgroundShadowStyle:(StyleEmbossShadow)style{
   return [self showBackgroundShadowStyle:style color:nil];
}

- (UIImageView *)showBackgroundShadowStyle:(StyleEmbossShadow)style color:(UIColor*)shadowColor{
   return [self showBackgroundShadowStyle:style blur:CGFLOAT_MAX level:CGFLOAT_MAX offset:CGPointZero color:shadowColor];
}

- (UIImageView *)showBackgroundShadowStyle:(StyleEmbossShadow)style blur:(CGFloat)blur level:(CGFloat)level color:(UIColor*)shadowColor{
    return [self showBackgroundShadowStyle:style blur:blur level:level offset:CGPointZero color:shadowColor];
}

- (UIImageView *)showBackgroundShadowStyle:(StyleEmbossShadow)style blur:(CGFloat)blur level:(CGFloat)level offset:(CGPoint)offset color:(UIColor*)shadowColor
{
    HMUIShadowImageView * imageView = [self shadowImageViewWithStyle:style];
    imageView.hidden = NO;
    
    UIImage *image = [UIImage imageEmbossStyle:style blur:blur level:level color:shadowColor];
    
    if ( nil == imageView )
    {
        imageView = [HMUIShadowImageView imageViewFor:image];
        imageView.alpha = .6f;
        [self addSubview:imageView];
        [self sendSubviewToBack:imageView];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
        
    }
    
    if (imageView.image!=image) {
        imageView.image = image;
        [imageView layoutIfNeeded];
    }
    
    imageView.style = style;
    imageView.color = shadowColor;
    imageView.blur = blur;
    imageView.level = level;
    imageView.shadowOffset = offset;
    return imageView;
}


- (void)showshadowColor:(UIColor*)shadowColor
{
    [self.layer setShadowColor:shadowColor==nil?[RGB(0, 0, 0) CGColor]:shadowColor.CGColor];
    [self.layer setShadowOffset:CGSizeMake(0, 0)];
    [self.layer setShadowOpacity:1];
    [self.layer setShadowRadius:3.0];
}

#pragma mark -

- (UILabel *)showFrameText:(BOOL)yesOrNo{
#if DEBUG
    if (yesOrNo) {
        UILabel * label = nil;
        
        for ( UIView * subView in self.subviews )
        {
            if ( [subView isKindOfClass:[__BeeFrameTextLabel class]] )
            {
                label = (UILabel *)subView;
                break;
            }
        }
        
        if ( nil == label )
        {
            label = [[[__BeeFrameTextLabel alloc] init] autorelease];
            label.font = [UIFont systemFontOfSize:8];
            label.autoresizesSubviews = YES;
            label.backgroundColor = [UIColor whiteColor];
            label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;

            [self addSubview:label];
            [self bringSubviewToFront:label];
        }
        return label;
    }
#endif
    return nil;
}

- (void)showHolder:(UIView *)holder show:(BOOL)yesOrNo animated:(BOOL)animated{
    
    [self showHolder:holder show:yesOrNo center:self.center animated:animated];
    
}

- (void)showHolder:(UIView *)holder show:(BOOL)yesOrNo center:(CGPoint)center animated:(BOOL)animated{
    
    
    if (![self.subviews containsObject:holder]&&yesOrNo) {
        [self addSubview:holder];
    }
    if (!yesOrNo&&![self.subviews containsObject:holder]) {
        
        return;
    }
    
    [holder.layer removeAllAnimations];
    [holder.layer.sublayers makeObjectsPerformSelector:@selector(removeAllAnimations)];
    
    holder.center = center;
    
    if (holder.superview) {
        [holder bringSubviewToFront:self.subviews.lastObject];
    }
    
    if (yesOrNo){
        holder.alpha=1.f;
        holder.hidden = !yesOrNo;
    }
    
    if (animated) {
        if (yesOrNo)holder.alpha=0.f;
        [UIView animateWithDuration:.25f animations:^{
            if (yesOrNo)holder.alpha=1.f;
            else holder.alpha = 0.f;
        }completion:^(BOOL finished) {
            if (!yesOrNo&&finished) {
                [holder removeFromSuperview];
            }
            holder.hidden = !yesOrNo;
#if (__ON__ == __HM_LOG__)
            CC([self class],@"completion");
#endif
        }];
    }else{
        if (!yesOrNo)[holder removeFromSuperview];
        holder.hidden = !yesOrNo;
#if (__ON__ == __HM_LOG__)
        CC([self class],@"no animated");
#endif
    }
}


#pragma mark -
- (void)removeReflection{
    NSArray *layers=[[self layer] sublayers];
    for (CALayer *layer in layers) {
        if ([layer.name isEqualToString:@"___reflectionLayer___"]) {
            [layer removeFromSuperlayer];
            return;
        }
    }
}

- (void)showReflection{
    [self addReflectionWithContents:[self.layer contents]];
}

- (void)addReflectionWithContents:(id)contents{
    
    //删除冲突的图层
    [self removeReflection];
    
    //图片阴影层
    
    CGRect bounds = self.bounds;
    CALayer *reflectionLayer = [[CALayer alloc] init];
    
    [reflectionLayer setName:@"___reflectionLayer___"];
    [reflectionLayer setBounds:bounds];
    
    [reflectionLayer setPosition:CGPointMake(0, bounds.size.height+3)];
    [reflectionLayer setAnchorPoint:CGPointMake(0, 1)];
    [reflectionLayer setContents:contents];
    
    [reflectionLayer setValue:[NSNumber numberWithFloat:180.0] forKeyPath:@"transform.rotation.x"];
    
    //渐变层
    
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    
    [gradientLayer setBounds:[reflectionLayer bounds]];
    
    [gradientLayer setPosition:CGPointMake([reflectionLayer bounds].size.width/2, [reflectionLayer bounds].size.height/2)];
    
    [gradientLayer setColors:[NSArray arrayWithObjects: (id)[[UIColor clearColor] CGColor],(id)[[UIColor blackColor] CGColor], nil]];
    
    [gradientLayer setStartPoint:CGPointMake(0.5,0.35)];
    
    [gradientLayer setEndPoint:CGPointMake(0.5,1.0)];
    
    [reflectionLayer setMask:gradientLayer];
    [gradientLayer release];
    
    [[self layer] addSublayer:reflectionLayer];
    [reflectionLayer release];
    
}

#if DEBUG
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"frame"]) {
        [self showFrameText:YES].text = [NSString stringWithFormat:@"(%.1f,%.1f,%.1f,%.1f)",self.x,self.y,self.w,self.h];
        [[self showFrameText:YES] sizeToFit];
        [self showFrameText:YES].y = 0;
    }
}
#endif

@end

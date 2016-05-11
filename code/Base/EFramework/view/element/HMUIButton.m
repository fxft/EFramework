//
//  HMUIButton.m
//  CarAssistant
//
//  Created by Eric on 14-3-19.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIButton.h"

#import "HMFoundation.h"
#import "HMViewCategory.h"

#undef	LONG_INTERVAL
#define LONG_INTERVAL	(0.75f)

@interface UIButton (butten)
- (void)_setFont:(UIFont *)font;
@end

@interface UIButten()

- (void)didTouchDown;
- (void)didTouchLong;
- (void)didTouchDownRepeat;
- (void)didTouchUpInside;
- (void)didTouchUpOutside;
- (void)didTouchCancel;

- (void)didDragInside;
- (void)didDragOutside;
- (void)didDragEnter;
- (void)didDragExit;


@property (nonatomic, assign) CGPoint previousTouchPoint;
@property (nonatomic, assign) BOOL previousTouchHitTestResponse;
@property (nonatomic, copy) ButtenClicked clicked;

- (void)resetHitTestCache;

@end

@implementation UIButten{
    NSTimer *               _timer;
    BOOL                    _repeatCount;
    BOOL                    _builded;
//    NSMutableDictionary *   _titleStrings;
//    NSMutableDictionary *   _attributeStrings;

    NSMutableDictionary *   _titleFonts;

//    NSMutableDictionary *   _titleColors;
//    NSMutableDictionary *   _titleShadows;
    
    NSMutableDictionary *   _imageUrls;
    NSRecursiveLock *       _imageUrlLock;
    
    BOOL                    _enableAllEvents;
    CGSize                  _imageSize;
    CGSize                  _imageSizeTarget;

    UIButtenType            _buttenType;
    BOOL                    _inited;
    UIEdgeInsets            _titleEdgeInsets;
    UIEdgeInsets            _imageEdgeInsets;
    BOOL                    _checkedSend;
    
}
@synthesize enableAllEvents = _enableAllEvents;
@synthesize imageSize = _imageSize;
@synthesize buttenType = _buttenType;
@synthesize userInfo;
@synthesize clicked;
@synthesize previousTouchPoint = _previousTouchPoint;
@synthesize previousTouchHitTestResponse = _previousTouchHitTestResponse;
@synthesize textMargin;
@synthesize backgroundImageEdgeInsets = _backgroundImageEdgeInsets;

DEF_SIGNAL2( TOUCH_DOWN ,UIButten)
DEF_SIGNAL2( TOUCH_DOWN_LONG ,UIButten)
DEF_SIGNAL2( TOUCH_DOWN_REPEAT ,UIButten)
DEF_SIGNAL2( TOUCH_UP_INSIDE ,UIButten)
DEF_SIGNAL2( TOUCH_UP_OUTSIDE ,UIButten)
DEF_SIGNAL2( TOUCH_UP_CANCEL ,UIButten)
DEF_SIGNAL2( TOUCH_CHECK_INSIDE ,UIButten)


DEF_SIGNAL2( DRAG_INSIDE ,UIButten)		// 拖出
DEF_SIGNAL2( DRAG_OUTSIDE ,UIButten)		// 拖入
DEF_SIGNAL2( DRAG_ENTER ,UIButten)		// 进入
DEF_SIGNAL2( DRAG_EXIT ,UIButten)			// 退出

+ (id)spawn{
    
    UIButten *btn = [[UIButten alloc]init];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn initSelfDefault];
    
    return [btn autorelease];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
        [self initSelfDefault];
    }
    return self;
}



- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self initSelfDefault];

}

- (void)dealloc
{
    NSString *tags = [NSString stringWithFormat:@"%p",self];
    [self disableHttpRespondersByTagString:tags];
    
    self.eventReceiver = nil;
    self.userInfo = nil;
    self.clicked = nil;
    [_timer invalidate];
    _timer  = nil;
    [_imageUrlLock release];
//    [_titleStrings removeAllObjects];
//    [_titleStrings release];
    [_titleFonts removeAllObjects];
    [_titleFonts release];
//    [_titleShadows removeAllObjects];
//    [_titleShadows release];
//    [_attributeStrings removeAllObjects];
//    [_attributeStrings release];
//    [_titleColors removeAllObjects];
//    [_titleColors release];
    [_imageUrls removeAllObjects];
    [_imageUrls release];
    
    HM_SUPER_DEALLOC();
}

-(void)initSelfDefault{
    if (!_inited) {
        
        self.adjustsImageWhenDisabled = YES;
        self.adjustsImageWhenHighlighted = YES;
        
        [self addTarget:self action:@selector(didTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        
        if (_titleFonts.count==0||([self titleFontForState:UIControlStateNormal]==nil)) {
            [self setTitleFont:[UIFont systemFontOfSize:18.f] forState:UIControlStateNormal];
        }
        [self load];
        
        _inited = YES;
        
    }
    
}

- (void)_setFont:(UIFont *)font{
    
    if (font) {
        [self setTitleFont:font forState:UIControlStateNormal];
    }else{
        [self setTitleFont:[UIFont systemFontOfSize:18] forState:UIControlStateNormal];
    }
    [super _setFont:font];
}


- (void)setBackgroundImagePrefixName:(NSString*)name title:(NSString *)title{
 
    if (name) {
        
        if ([name isUrl]){
            [self setBackgroundImageWithURLString:name forState:UIControlStateNormal];
        }else {
            NSString *suffix = [name pathExtension];
            NSString *prefix = [name stringByDeletingPathExtension];
            
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_up.%@",prefix,suffix]];
            if (!image) {
                image = [UIImage imageNamed:name];
            }
            image = [image stretched];
            [self setBackgroundImage:image forState:UIControlStateNormal];
            
            image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_down.%@",prefix,suffix]];
            image = [image stretched];
            [self setBackgroundImage:image forState:UIControlStateHighlighted];
            
            image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_disable.%@",prefix,suffix]];
            image = [image stretched];
            [self setBackgroundImage:image forState:UIControlStateDisabled];
            
            image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_select.%@",prefix,suffix]];
            image = [image stretched];
            [self setBackgroundImage:image forState:UIControlStateSelected];
        }
    }
    if (title) {
        [self setTitle:title forState:UIControlStateNormal];
    }
}


- (void)setImagePrefixName:(NSString*)name title:(NSString *)title{
    
    if (name) {
        if ([name isUrl]){
            [self setImageWithURLString:name forState:UIControlStateNormal];
        }else {
            NSString *suffix = [name pathExtension];
            NSString *prefix = [name stringByDeletingPathExtension];
            
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_up.%@",prefix,suffix]];
            if (!image) {
                image = [UIImage imageNamed:name];
            }
            [self setImage:image forState:UIControlStateNormal];
            
            image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_down.%@",prefix,suffix]];
            [self setImage:image forState:UIControlStateHighlighted];
            
            image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_disable.%@",prefix,suffix]];
            [self setImage:image forState:UIControlStateDisabled];
            
            image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_select.%@",prefix,suffix]];
            [self setImage:image forState:UIControlStateSelected];
        }
        
    }
    if (title) {
        [self setTitle:title forState:UIControlStateNormal];
    }
}

- (BOOL)is:(NSString *)string{
    return [self.tagString isEqualToString:string];
}

- (void)setImageSize:(CGSize)imageSize{ 
    
    _imageSize = imageSize;
    _imageSizeTarget = imageSize;
    [self setNeedsDisplay];
}

- (CGSize)imageSize{
    if (!CGSizeEqualToSize(_imageSizeTarget, CGSizeZero)) {
        _imageSize = _imageSizeTarget;
    }else{
        _imageSize = self.currentImage.size;

    }
    return _imageSize;
}


- (void)setButtenType:(UIButtenType)buttenType{
    _buttenType = buttenType;
    
    [self setNeedsDisplay];
}

- (void)setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets{
    _titleEdgeInsets = titleEdgeInsets;

    [super setTitleEdgeInsets:titleEdgeInsets];
}

- (void)setImageEdgeInsets:(UIEdgeInsets)imageEdgeInsets{
    _imageEdgeInsets = imageEdgeInsets;

    [super setImageEdgeInsets:imageEdgeInsets];
}

- (UIEdgeInsets)titleEdgeInsets{
    UIEdgeInsets eee = [super titleEdgeInsets];
    if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, eee)) {
        return eee;
    }
    return _titleEdgeInsets;
}

- (UIEdgeInsets)imageEdgeInsets{
    UIEdgeInsets eee = [super imageEdgeInsets];
    if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, eee)) {
        return eee;
    }
    return _imageEdgeInsets;
}

- (void)setBackgroundImageEdgeInsets:(UIEdgeInsets)backgroundImageEdgeInsets{
    if (!UIEdgeInsetsEqualToEdgeInsets(_backgroundImageEdgeInsets, backgroundImageEdgeInsets)) {
        _backgroundImageEdgeInsets = backgroundImageEdgeInsets;
        if (self.superview&&_inited) {
            [self setNeedsLayout];
            [self layoutIfNeeded];
        }
    }
}

- (void)setImageWithURLString:(NSString *)url forState:(UIControlState)state{
    [self setImageWithURLString:url forState:state placeholder:nil];
}

- (void)handleRequest:(HMHTTPRequestOperation *)request
{
    
	if ( request.created )
	{
		// TODO:
	}
	else if ( request.sending )
	{
        
	}
	else if ( request.sendProgressed )
	{

	}
	else if ( request.recving )
	{
	}
	else if ( request.recvProgressed )
	{

	}
	else if ( request.beCancelled )
	{
        
	}
    else if ( request.paused )
    {

	}
    else if ( request.failed )
	{
        
        if ( request.timeOut)
		{
			         
		}else{

        }

	}
	else if ( request.succeed )
	{
        if (request.responseObject) {
            [_imageUrlLock lock];
            NSArray *keys = [NSArray arrayWithArray:_imageUrls.allKeys];
            for (NSString *key in keys) {
                UIControlState tState = [self stateforKey:key];
                NSDictionary *stateItem = [_imageUrls objectForKey:key];
                NSString *tUrl = [stateItem valueForKey:@"url"];
                BOOL background = [[stateItem valueForKey:@"bkg"] boolValue];
                if ([tUrl is:request.url]) {
#if (__ON__ == __HM_DEVELOPMENT__)
                    CC( @"UIButten",@"%@--%@",key,tUrl);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
                    
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        UIImage *_image= [UIImage imageWithDataAtScale:request.responseData scale:[UIScreen mainScreen].scale];
                        NSURL *URL = [NSURL URLWithString:request.url];
                        if (_image) {
                            [HMHTTPRequestOperation cachedImage:_image withURL:URL];
                        }else{
                            [[HMMemoryCache sharedInstance] removeObjectForKey:AFDataCacheKeyFromURLRequest(URL)];
                            [[HMFileCache sharedInstance] removeObjectForKey:AFDataCacheKeyFromURLRequest(URL) branch:@"images"];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (background) {
                                [self setBackgroundImage:_image forState:tState];
                            }else{
                                [self setImage:_image forState:tState];
                            }
                            [_imageUrls removeObjectForKey:key];
                        });
                    });
                }
                
                if (tState == self.state) {
                    self.alpha = 0.f;
                    __weak_type typeof(self) weakSelf = self;
                    [UIView animateWithDuration:.25f animations:^{
                        __strong_type typeof(weakSelf) strongSelf = weakSelf;
                        if (strongSelf.superview) {
                            strongSelf.alpha = 1.f;
                        }
                        
                    }];
                }
            }
            [_imageUrlLock unlock];
        }
	}
    
}
- (void)setImageWithURLString:(NSString *)url forState:(UIControlState)state placeholder:(UIImage*)placeholderImage{
    
    [self setImageWithURLString:url forState:state placeholder:placeholderImage background:NO];
}

- (void)setBackgroundImageWithURLString:(NSString *)url forState:(UIControlState)state{
    [self setBackgroundImageWithURLString:url forState:state placeholder:nil];
}
    
- (void)setBackgroundImageWithURLString:(NSString *)url forState:(UIControlState)state placeholder:(UIImage *)placeholderImage{
    [self setImageWithURLString:url forState:state placeholder:placeholderImage background:YES];
}

- (void)setImageWithURLString:(NSString *)url forState:(UIControlState)state placeholder:(UIImage*)placeholderImage background:(BOOL)background{
    NSURL *URL = [NSURL URLWithString:url];
    
    UIImage *image = [UIImage imageCachedWithURL:URL];
    if (image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (background) {
                [image stretched];
                [self setBackgroundImage:image forState:state];
            }else{
                [self setImage:image forState:state];
            }
        });
        return;
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (placeholderImage) {
                if (background) {
                    [self setBackgroundImage:placeholderImage forState:state];
                }else{
                    [self setImage:placeholderImage forState:state];
                }
            }
        });
        
    }
    if (_imageUrls==nil) {
        _imageUrls = [[NSMutableDictionary dictionary]retain];
        if (_imageUrlLock==nil) {
            _imageUrlLock = [[NSRecursiveLock alloc]init];
        }
    }
    [_imageUrls setValue:@{@"url":url,@"bkg":@(background)} forKey:[self keyforState:state]];
    
    HMHTTPRequestOperation * operation = [self attemptingForURLString:url];
    if (operation) {
#if (__ON__ == __HM_DEVELOPMENT__)
        CC( @"UIButten",@"%@>>>> attempting to %@",[self class],url);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
        return;
    }else{
#if (__ON__ == __HM_DEVELOPMENT__)
        CC( @"UIButten",@"%@>>>> %@ for %@",[self class],url,[self keyforState:state]);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    }
    NSTimeInterval timeout = 60;
    if ([[[url pathExtension] lowercaseString] rangeOfString:@"gif"].location != NSNotFound) {
        timeout = 120;
    }
    
    operation = [[HMHTTPRequestOperationManager sharedImageInstance] GET_HTTP:url parameters:nil responder:self timeOut:timeout];
    NSString *tags = [NSString stringWithFormat:@"%p",self];
    operation.tagString = tags;
//    opertaion.attentRecvProgress = YES;
    [operation setResponseType:HTTPResponseType_IMAGE];
    operation.order = [NSString stringWithFormat:@"%@ for state %@",url,[self keyforState:state]];
    operation.useCache = YES;
    operation.refreshCache = YES;

}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIControl


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHighlighted:(BOOL)highlighted {
    
    [super setHighlighted:highlighted];

    [self setTitleState:self.state];

    [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    [self setTitleState:self.state];

    [self setNeedsDisplay];

}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    
    [self setTitleState:self.state];

    [self setNeedsDisplay];

}

- (NSString *)keyforState:(UIControlState)state{
    switch (state) {
        case UIControlStateNormal:
            return @"Normal";
            break;
        case UIControlStateHighlighted:
            return @"Highlighted";
            break;
        case UIControlStateDisabled:
            return @"Disabled";
            break;
        case UIControlStateSelected:
            return @"Selected";
            break;
        default:
            break;
    }
    return @" ";
}

- (UIControlState)stateforKey:(NSString *)state{
    if ([state isEqualToString:@"Normal"]) {
        return UIControlStateNormal;
    }else if ([state isEqualToString:@"Highlighted"]) {
        return UIControlStateHighlighted;
    }else if ([state isEqualToString:@"Disabled"]) {
        return UIControlStateDisabled;
    }else if ([state isEqualToString:@"Selected"]) {
        return UIControlStateSelected;
    }else{
        return UIControlStateReserved;
    }
}

- (void)didMoveToWindow{
    [super didMoveToWindow];
    if (self.superview) {
        [self setTitleState:self.state];
    }
}

//- (void)setTitleShadowColor:(UIColor *)color forState:(UIControlState)state{
//    if (_titleShadows==nil) {
//        _titleShadows = [[NSMutableDictionary dictionary]retain];
//    }
//    [_titleShadows setValue:color forKey:[self keyforState:state]];
//    [super setTitleShadowColor:color forState:state];
//}
//
//- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state{
//    if (_titleColors==nil) {
//        _titleColors = [[NSMutableDictionary dictionary]retain];
//    }
//    [_titleColors setValue:color forKey:[self keyforState:state]];
//    [super setTitleColor:color forState:state];
//}
//
//- (void)setTitle:(NSString *)title forState:(UIControlState)state{
//    if (_titleStrings==nil) {
//        _titleStrings = [[NSMutableDictionary dictionary]retain];
//    }
//    [_titleStrings setValue:title forKey:[self keyforState:state]];
//
//    [super setTitle:title forState:state];
//}

- (void)setTitleFont:(UIFont *)font forState:(UIControlState)state{
    if (_titleFonts==nil) {
        _titleFonts = [[NSMutableDictionary alloc]init];
    }
    [_titleFonts setValue:font forKey:[self keyforState:state]];

    if (self.superview&&_inited) {
        if (self.state==state) {
            if (font!=self.titleLabel.font) {
                self.titleLabel.font = font;
            }
        }
//        [self setNeedsLayout];
//        [self layoutIfNeeded];
    }
}

//- (void)setAttributedTitle:(NSAttributedString *)title forState:(UIControlState)state{
//    if (_attributeStrings==nil) {
//        _attributeStrings = [[NSMutableDictionary dictionary]retain];
//    }
//    [_attributeStrings setValue:title forKey:[self keyforState:state]];
//    [super setAttributedTitle:title forState:state];
//}

//- (NSString *)titleForState:(UIControlState)state{
//    NSString *string = [super titleForState:state];
//    if (![string notEmpty]) {
//        string = [_titleStrings valueForKey:[self keyforState:state]];
//    }
//    
//    return string?string:[_titleStrings valueForKey:[self keyforState:UIControlStateNormal]];
//}

- (UIFont *)titleFontForState:(UIControlState)state{
    
    UIFont *font = [_titleFonts valueForKey:[self keyforState:state]];
    font = font?font:[_titleFonts valueForKey:[self keyforState:UIControlStateNormal]];

    return font;
}

//- (NSAttributedString *)attributedStringForState:(UIControlState)state{
//    NSAttributedString *string = [super attributedTitleForState:state];
//    if (!string) {
//        string = [_attributeStrings valueForKey:[self keyforState:state]];
//    }
//
//    return string?string:[_attributeStrings valueForKey:[self keyforState:UIControlStateNormal]];
//}

//- (UIColor *)titleShadowColorForState:(UIControlState)state{
//    UIColor *color = [super titleShadowColorForState:state];
//    if (!color)
//    color =[_titleShadows valueForKey:[self keyforState:state]];
//    return color?color:[_titleShadows valueForKey:[self keyforState:UIControlStateNormal]];
//}

//- (UIColor *)titleColorForState:(UIControlState)state{
//    UIColor *color = [super titleColorForState:state];
//    if (!color)
//        color = [_titleColors valueForKey:[self keyforState:state]];
//    return color?color:[_titleColors valueForKey:[self keyforState:UIControlStateNormal]];
//}

- (void)setTitleState:(UIControlState)state{
//    UIColor *color = [self titleShadowColorForState:state];
    
    NSAttributedString *attributeString = [self attributedTitleForState:state];
    if (attributeString!=nil) {
//        [super setAttributedTitle:attributeString forState:state];
    }else{
//        NSString *string = [self titleForState:state];
//        if (string!=nil) {
//            [super setTitle:string forState:state];
//        }
//        color = [self titleColorForState:state];
//        if (color) {
//            [super setTitleColor:color forState:state];
//        }
        UIFont *font = [self titleFontForState:state];
        if (font!=self.titleLabel.font) {
            self.titleLabel.font = font;
        }
    }

}

- (BOOL)enableAllEvents{
    return _enableAllEvents;
}

- (void)setEnableAllEvents:(BOOL)enableAllEvents{
    
    if (!_builded&&enableAllEvents) {
        
        [self addTarget:self action:@selector(didTouchDown) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(didTouchDownRepeat) forControlEvents:UIControlEventTouchDownRepeat];
        
        [self addTarget:self action:@selector(didTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
        
        [self addTarget:self action:@selector(didDragInside) forControlEvents:UIControlEventTouchDragInside];
        [self addTarget:self action:@selector(didDragOutside) forControlEvents:UIControlEventTouchDragOutside];
        [self addTarget:self action:@selector(didDragEnter) forControlEvents:UIControlEventTouchDragEnter];
        [self addTarget:self action:@selector(didDragExit) forControlEvents:UIControlEventTouchDragExit];
        _builded = YES;
        
    }else if (!enableAllEvents&&_builded){
        
        [self removeTarget:self action:@selector(didTouchDown) forControlEvents:UIControlEventTouchDown];
        [self removeTarget:self action:@selector(didTouchDownRepeat) forControlEvents:UIControlEventTouchDownRepeat];
        
        [self removeTarget:self action:@selector(didTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
        
        [self removeTarget:self action:@selector(didDragInside) forControlEvents:UIControlEventTouchDragInside];
        [self removeTarget:self action:@selector(didDragOutside) forControlEvents:UIControlEventTouchDragOutside];
        [self removeTarget:self action:@selector(didDragEnter) forControlEvents:UIControlEventTouchDragEnter];
        [self removeTarget:self action:@selector(didDragExit) forControlEvents:UIControlEventTouchDragExit];
        
        _builded = NO;
    }
    
    _enableAllEvents = enableAllEvents;
}

#pragma mark - event

#pragma mark
- (BOOL)isAlphaVisibleAtPoint:(CGPoint)point forImage:(UIImage *)image
{
    // Correct point to take into account that the image does not have to be the same size
    // as the button. See https://github.com/ole/OBShapedButton/issues/1
    CGSize iSize = image.size;
    CGSize bSize = self.bounds.size;
    point.x *= (bSize.width != 0) ? (iSize.width / bSize.width) : 1;
    point.y *= (bSize.height != 0) ? (iSize.height / bSize.height) : 1;
    
    CGColorRef pixelColor = [[image colorAtPixel:point] CGColor];
    CGFloat alpha = CGColorGetAlpha(pixelColor);
    return alpha >= kAlphaVisibleThreshold;
}


// UIView uses this method in hitTest:withEvent: to determine which subview should receive a touch event.
// If pointInside:withEvent: returns YES, then the subview’s hierarchy is traversed; otherwise, its branch
// of the view hierarchy is ignored.
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // Return NO if even super returns NO (i.e., if point lies outside our bounds)
    BOOL superResult = [super pointInside:point withEvent:event];
    if (!superResult||!(_buttenType&UIButtenTypeShaped)) {
        return superResult;
    }
    
    // Don't check again if we just queried the same point
    // (because pointInside:withEvent: gets often called multiple times)
    if (CGPointEqualToPoint(point, self.previousTouchPoint)) {
        return self.previousTouchHitTestResponse;
    } else {
        self.previousTouchPoint = point;
    }
    
    // We can't test the image's alpha channel if the button has no image. Fall back to super.
    UIImage *buttonImage = [self imageForState:UIControlStateNormal];
    UIImage *buttonBackground = [self backgroundImageForState:UIControlStateNormal];
    
    BOOL response = NO;
    
    if (buttonImage == nil && buttonBackground == nil) {
        response = YES;
    }
    else if (buttonImage != nil && buttonBackground == nil) {
        response = [self isAlphaVisibleAtPoint:point forImage:buttonImage];
    }
    else if (buttonImage == nil && buttonBackground != nil) {
        response = [self isAlphaVisibleAtPoint:point forImage:buttonBackground];
    }
    else {
        if ([self isAlphaVisibleAtPoint:point forImage:buttonImage]) {
            response = YES;
        } else {
            response = [self isAlphaVisibleAtPoint:point forImage:buttonBackground];
        }
    }
    
    self.previousTouchHitTestResponse = response;
    return response;
}

// Reset the Hit Test Cache when a new image is assigned to the button
- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    [super setImage:image forState:state];
    [self resetHitTestCache];
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
    [super setBackgroundImage:image forState:state];
    [self resetHitTestCache];
}

- (void)resetHitTestCache
{

    self.previousTouchPoint = CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN);
    self.previousTouchHitTestResponse = NO;
}

#pragma mark  checkBox

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = touches.anyObject;
    if (_buttenType&UIButtenTypeIconClickedInside) {
        CGPoint point = [touch locationInView:self.imageView];
        CGRect frame = self.imageView.frame;
        if (_builded&UIButtenTypeIconSideBottom) {
            frame.size.width = self.width;
            frame.origin.x = 0;
            frame.size.height += self.textMargin;
        }else if (_builded&UIButtenTypeIconSideTop) {
            frame.size.width = self.width;
            frame.size.height += self.textMargin;
            frame.origin.x = 0;
        }else if (_builded&UIButtenTypeIconSideRight) {
            frame.size.width = self.width - frame.origin.x;
            frame.size.height = self.height;
        }else {
            frame.size.width += frame.origin.x;
            frame.size.height = self.height;
            frame.origin.x = 0;
        }
        if (CGRectContainsPoint(frame, point)) {
            _checkedSend = YES;
            [self sendSignal:UIButten.TOUCH_CHECK_INSIDE];
        }
    }
    
    [super touchesEnded:touches withEvent:event];
    
}

- (void)didTouchDown
{
	_repeatCount = 0;
    
	[_timer invalidate];
	_timer = nil;
	
	if ( NO == _enableAllEvents )
		return;
    
	_timer = [NSTimer scheduledTimerWithTimeInterval:LONG_INTERVAL
											  target:self
											selector:@selector(didTouchLong)
											userInfo:nil
											 repeats:NO];
    
	[self sendSignal:UIButten.TOUCH_DOWN];
}

- (void)didTouchDownRepeat
{
	_repeatCount += 1;
	
	if ( NO == _enableAllEvents )
		return;
	
	[self sendSignal:UIButten.TOUCH_DOWN_REPEAT];
}

- (void)didTouchLong
{
	_timer = nil;
	
	[self sendSignal:UIButten.TOUCH_DOWN_LONG];
}

- (void)didTouchUpInside
{
	[_timer invalidate];
	_timer = nil;
	if (!_checkedSend) {
        [self sendSignal:UIButten.TOUCH_UP_INSIDE];
    }
    _checkedSend = NO;	
}

- (void)didTouchUpOutside
{
	[_timer invalidate];
	_timer = nil;
    
	if ( NO == _enableAllEvents )
		return;
	
	[self sendSignal:UIButten.TOUCH_UP_OUTSIDE];
}

- (void)didTouchCancel
{
	[_timer invalidate];
	_timer = nil;
    
	if ( NO == _enableAllEvents )
		return;
	
	[self sendSignal:UIButten.TOUCH_UP_CANCEL];
}

- (void)didDragInside
{
	if ( NO == _enableAllEvents )
		return;
	
	[self sendSignal:UIButten.DRAG_INSIDE];
}

- (void)didDragOutside
{
	if ( NO == _enableAllEvents )
		return;
	
	[self sendSignal:UIButten.DRAG_OUTSIDE];
}

- (void)didDragEnter
{
	if ( NO == _enableAllEvents )
		return;
	
	[self sendSignal:UIButten.DRAG_ENTER];
}

- (void)didDragExit
{
	if ( NO == _enableAllEvents )
		return;
	
	[self sendSignal:UIButten.DRAG_EXIT];
}

ON_Button(signal){
    signal.forward = YES;
    
    if ([signal is:[UIButten TOUCH_CHECK_INSIDE]]) {
        if ((_buttenType&UIButtenTypeCheckBox)&&(_buttenType&UIButtenTypeAutoSelect)) {
            self.selected = !self.selected;
        }
        if (self.clicked) {
            self.clicked([UIButten TOUCH_CHECK_INSIDE]);
            signal.forward = NO;
        }
    }else if ([signal is:[UIButten TOUCH_UP_INSIDE]]){
        
        if (_buttenType&UIButtenTypeAutoSelect) {
            if (_buttenType&UIButtenTypeIconClickedInside) {
                
            }else{
                self.selected = !self.selected;
            }
        }
        
        if (self.clicked) {
            self.clicked([UIButten TOUCH_UP_INSIDE]);
            signal.forward = NO;
        }
    }
}
- (instancetype)onClicked:(ButtenClicked)clk{
    self.clicked = clk;
    return self;
}

#pragma mark -

- (CGSize)sizeThatFits:(CGSize)size{
    

    CGSize size1 = [super sizeThatFits:size];
    
    CGSize size3 = [self sizeFor:size1];

    return size3;
}


- (CGSize)intrinsicContentSize{

    CGSize size1 = [super intrinsicContentSize];
    
    CGSize size3 = [self sizeFor:size1];

    return size3;
}

- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize{
    CGSize size1 = [super systemLayoutSizeFittingSize:targetSize];
    
    return size1;
}

- (void)setFrame:(CGRect)frame{
    
    
    [super setFrame:frame];
    
    if (self.style__) {
        [self setNeedsDisplay];
    }
    
}

- (void)layoutSubviews{

    [self resetViewFrame:self.size];
    
    [super layoutSubviews];
    
    if (self.style__) {
        [self setNeedsDisplay];
    }
}

- (CGSize)sizeFor:(CGSize)size0{
    if (self.contentHorizontalAlignment!=UIControlContentHorizontalAlignmentCenter||self.contentVerticalAlignment!=UIControlContentVerticalAlignmentCenter) {
        return size0;
    }
    
    size0 = CGSizeZero;
    
    CGSize size1 = size0;
    CGSize size =  CGSizeZero;
    
    if ([self attributedTitleForState:self.state]) {
        size =  [[self attributedTitleForState:self.state] sizeBySize:size];
    }else{
        if ([self titleForState:self.state]) {
            size = [[self titleForState:self.state] sizeWithFont:[self titleFontForState:self.state] bySize:size];
        }
    }
    
    CGSize __imageSize = self.imageSize;
    
    if (_buttenType&UIButtenTypeIconSideLeft) {
        //左边图片，右边文字
        size1 = CGSizeMake(size.width+__imageSize.width+self.textMargin, MAX(__imageSize.height, size.height));
        
    }else if (_buttenType&UIButtenTypeIconSideRight) {
        //右边图片，左边文字
        size1 = CGSizeMake(__imageSize.width+self.textMargin+size.width, MAX(__imageSize.height, size.height));
        
    }else if (_buttenType&UIButtenTypeIconSideTop) {
        //上面图片，下面文字
        size1 = CGSizeMake(MAX(size.width,__imageSize.width), __imageSize.height+size.height+self.textMargin);
        
    }else if (_buttenType&UIButtenTypeIconSideBottom) {
        //下面图片，上面文字
        size1 = CGSizeMake(MAX(size.width,__imageSize.width), MAX(__imageSize.height+size.height+self.textMargin,size1.height));
        
    }else{
        //默认情况
        size1 = CGSizeMake(size.width+__imageSize.width+self.textMargin, MAX(__imageSize.height, size.height));
        if (!UIEdgeInsetsEqualToEdgeInsets(super.titleEdgeInsets, UIEdgeInsetsZero)||!UIEdgeInsetsEqualToEdgeInsets(super.imageEdgeInsets, UIEdgeInsetsZero)) {
            CGFloat width = MAX(super.titleEdgeInsets.left+super.titleEdgeInsets.right+size.width, super.imageEdgeInsets.left+super.imageEdgeInsets.right+__imageSize.width);
            
            CGFloat height = MAX(super.titleEdgeInsets.top+super.titleEdgeInsets.bottom+size.height, super.imageEdgeInsets.top+super.imageEdgeInsets.bottom+__imageSize.height);
            
            size1 = CGSizeMake(width, height);
        }
        
    }
    /**
     *  重新计算大小
     */
    if (CGSizeEqualToSize(__imageSize, CGSizeZero)) {
        size1.width+=12;
        size1.height+=12;
    }
    
    CGSize size3 = size1;//[self autolayoutForSize:size1];
    
    if (self.style__!=nil) {
        CGSize size2 = [self.style__ addToSize:size3 context:nil];
        
        size3 = size2;
    }
    if (size0.height>size3.height) {
        size3.height = size0.height;
    }
    
    if (size0.width>size3.width) {
        size3.width = size0.width;
    }
    
    return size3;
}


- (void)resetViewFrame:(CGSize)size{
    
    
    if (self.contentHorizontalAlignment!=UIControlContentHorizontalAlignmentCenter||self.contentVerticalAlignment!=UIControlContentVerticalAlignmentCenter) {
        return;
    }
    
    UIEdgeInsets indsets = UIEdgeInsetsZero;
    
    CGSize __imageSize = self.imageSize;
    
    CGSize sizeText = CGSizeZero;
    
    
    if ([self attributedTitleForState:self.state]) {
        sizeText =  [[self attributedTitleForState:self.state] sizeBySize:size];
    }else{
        if ([self titleForState:self.state]) {
            sizeText = [[self titleForState:self.state] sizeWithFont:[self titleFontForState:self.state] bySize:size];
        }
    }
    
    if (CGSizeEqualToSize(sizeText, CGSizeZero)&&CGSizeEqualToSize(__imageSize, CGSizeZero)) {
        return;
    }
    
    if (self.style__) {
        indsets = [self.style__ addToInsets:indsets forSize:self.size];
        
        if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, indsets)) {
            _imageEdgeInsets = indsets;
            _titleEdgeInsets = indsets;
        }
        
    }
    
    
    if (!CGSizeEqualToSize(__imageSize, CGSizeZero)) {
        _imageEdgeInsets = UIEdgeInsetsMake(MAX(indsets.top, (size.height-__imageSize.height)/2), MAX(indsets.left, (size.width-__imageSize.width)/2-self.textMargin), MAX(indsets.bottom, (size.height-__imageSize.height)/2), MAX(indsets.right, (size.width-__imageSize.width)/2));
        
    }
   
    if (!CGSizeEqualToSize(sizeText, CGSizeZero)) {
        
        CGFloat top = MAX(0, (size.height-__imageSize.height)/2);
        top = MAX(top, indsets.top);
        
        CGFloat bottom = MAX(top, indsets.bottom);
        
        CGFloat left = MAX(0, (size.width-__imageSize.width-textMargin-sizeText.width)/2);
        left = MAX(left, indsets.left);
        
        CGFloat right = MAX(0, (size.width-__imageSize.width-left));
        right = MAX(right, indsets.right);
        
        if (!CGSizeEqualToSize(__imageSize, CGSizeZero))
        _imageEdgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
        
        top = MAX(0, (size.height-sizeText.height)/2);
//        if (self.titleLabel.numberOfLines!=1) {
//            top = 1;
//        }
        top = MAX(top, indsets.top);
        bottom = MAX(top, indsets.bottom);
        
        right = MAX(left, indsets.right);
        left = left+__imageSize.width+self.textMargin;
        left = MAX(left, indsets.left);
        
        _titleEdgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
    }
    
    
    if (_buttenType&UIButtenTypeIconSideTop||_buttenType&UIButtenTypeIconSideBottom||_buttenType&UIButtenTypeIconSideLeft||_buttenType&UIButtenTypeIconSideRight) {//!CGSizeEqualToSize(self.imageSize, CGSizeZero)
        CGFloat height = size.height;
        CGFloat width = size.width;
        CGFloat top;
        CGFloat bottom;
        CGFloat left;
        CGFloat right;
        
        if (_buttenType&UIButtenTypeIconSideRight) {
            
            top = MAX(0, (height-__imageSize.height)/2);
            top = MAX(top, indsets.top);
            
            bottom = MAX(top, indsets.bottom);
            
            right = MAX(0, (width-__imageSize.width-textMargin-sizeText.width)/2);
            right = MAX(right, indsets.right);
            
            left = MAX(0, (width-__imageSize.width-right));
            left = MAX(left, indsets.left);
            
            _imageEdgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
            
            top = MAX(0, (height-sizeText.height)/2);
//            if (self.titleLabel.numberOfLines!=1) {
//                top = 0;
//            }
            top = MAX(top, indsets.top);
            bottom = MAX(top, indsets.bottom);
            
            left = MAX(right, indsets.left);
            right = MAX(right+__imageSize.width+textMargin, indsets.right);
            
            
            _titleEdgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
            
        }else if (_buttenType&UIButtenTypeIconSideLeft){
            
            top = MAX(0, (height-__imageSize.height)/2);
            top = MAX(top, indsets.top);
            
            bottom = MAX(top, indsets.bottom);
            
            left = MAX(0, (width-__imageSize.width-textMargin-sizeText.width)/2);
            left = MAX(left, indsets.left);
            
            right = MAX(0, (width-__imageSize.width-left));
            right = MAX(right, indsets.right);
            
            _imageEdgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
            
            top = MAX(0, (height-sizeText.height)/2);
//            if (self.titleLabel.numberOfLines!=1) {
//                top = 0;
//            }
            top = MAX(top, indsets.top);
            bottom = MAX(top, indsets.bottom);
            
            right = MAX(left, indsets.right);
            left = left+__imageSize.width+self.textMargin;
            left = MAX(left, indsets.left);
            
            _titleEdgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
            
        }else if (_buttenType&UIButtenTypeIconSideTop){
            
            top = MAX(0, (height-__imageSize.height-sizeText.height-textMargin)/2);
            top = MAX(top, indsets.top);
            
            bottom = MAX(top+sizeText.height+textMargin, indsets.bottom);
            
            left = MAX(0, (width-__imageSize.width)/2);
            left = MAX(left, indsets.left);
            
            right = MAX(left, indsets.right);
            
            _imageEdgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
            
            
            top = MAX(top+__imageSize.height+textMargin, indsets.top);
            
            bottom = MAX(0, height-top-sizeText.height);
            bottom = MAX(bottom, indsets.bottom);
            
            
            left = MAX(0, (width-sizeText.width)/2);
            left = MAX(left, indsets.left);
            
            right = MAX(left, indsets.right);
            
            _titleEdgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
            
        }else if (_buttenType&UIButtenTypeIconSideBottom){
            
            bottom = MAX(0, (height-__imageSize.height-sizeText.height-textMargin)/2);
            bottom = MAX(bottom, indsets.bottom);
            
            top = MAX(bottom+sizeText.height+textMargin, indsets.top);
            
            left = MAX(0, (width-__imageSize.width)/2);
            left = MAX(left, indsets.left);
        
            right = MAX(left, indsets.right);
            
            _imageEdgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
            
            
            top = MAX(bottom, indsets.top);
            
            bottom = MAX(0, height-top-sizeText.height);
            bottom = MAX(bottom, indsets.bottom);
            
            
            left = MAX(0, (width-sizeText.width)/2);
            left = MAX(left, indsets.left);
            
            right = MAX(left, indsets.right);
            
            _titleEdgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
        }

    }
    
    if (_buttenType&UIButtenTypeContenSideLeft) {
        CGFloat left = MIN(_titleEdgeInsets.left, _imageEdgeInsets.left);
        left = CGSizeEqualToSize(__imageSize, CGSizeZero)?_titleEdgeInsets.left:left;
        left = CGSizeEqualToSize(sizeText, CGSizeZero)?_imageEdgeInsets.left:left;
        
        _titleEdgeInsets.left -= left;
        _titleEdgeInsets.right += left;
        _imageEdgeInsets.left -= left;
        _imageEdgeInsets.right += left;
    }else if (_buttenType&UIButtenTypeContenSideRight) {
        CGFloat right = MIN(_titleEdgeInsets.right, _imageEdgeInsets.right);
        right = CGSizeEqualToSize(__imageSize, CGSizeZero)?_titleEdgeInsets.right:right;
        right = CGSizeEqualToSize(sizeText, CGSizeZero)?_imageEdgeInsets.right:right;
        
        _titleEdgeInsets.right -= right;
        _titleEdgeInsets.left += right;
        _imageEdgeInsets.right -= right;
        _imageEdgeInsets.left += right;
    }else if (_buttenType&UIButtenTypeContenSideTop) {
        CGFloat top = MIN(_titleEdgeInsets.top, _imageEdgeInsets.top);
        top = CGSizeEqualToSize(__imageSize, CGSizeZero)?_titleEdgeInsets.top:top;
        top = CGSizeEqualToSize(sizeText, CGSizeZero)?_imageEdgeInsets.top:top;
        
        _titleEdgeInsets.top -= top;
        _titleEdgeInsets.bottom += top;
        _imageEdgeInsets.top -= top;
        _imageEdgeInsets.bottom += top;
    }else if (_buttenType&UIButtenTypeContenSideBottom) {
        CGFloat bottom = MIN(_titleEdgeInsets.bottom, _imageEdgeInsets.bottom);
        bottom = CGSizeEqualToSize(__imageSize, CGSizeZero)?_titleEdgeInsets.bottom:bottom;
        bottom = CGSizeEqualToSize(sizeText, CGSizeZero)?_imageEdgeInsets.bottom:bottom;
        
        _titleEdgeInsets.bottom -= bottom;
        _titleEdgeInsets.top += bottom;
        _imageEdgeInsets.bottom -= bottom;
        _imageEdgeInsets.top += bottom;
    }
//    CC(@"UIButten",NSStringFromUIEdgeInsets(_titleEdgeInsets),NSStringFromUIEdgeInsets(_imageEdgeInsets));
}


- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    if (self.contentHorizontalAlignment!=UIControlContentHorizontalAlignmentCenter||self.contentVerticalAlignment!=UIControlContentVerticalAlignmentCenter) {
        CGRect rect = [super imageRectForContentRect:contentRect];
        return rect;
    }
    CGRect rect = contentRect;//CGRectEdgeInsets(contentRect, UIEdgeInsetsVerAndHor(-contentRect.origin.y, -contentRect.origin.x));
    return CGRectEdgeInsets(rect, self.imageEdgeInsets);
}

- (CGRect)backgroundRectForBounds:(CGRect)bounds{
    if (!UIEdgeInsetsEqualToEdgeInsets(self.backgroundImageEdgeInsets, UIEdgeInsetsZero)) {
        return UIEdgeInsetsInsetRect(bounds, self.backgroundImageEdgeInsets);
    }
    return [super backgroundRectForBounds:bounds];
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    
    if (self.contentHorizontalAlignment!=UIControlContentHorizontalAlignmentCenter||self.contentVerticalAlignment!=UIControlContentVerticalAlignmentCenter) {
        CGRect rect = [super titleRectForContentRect:contentRect];
        return rect;
    }
    CGRect rect = CGRectEdgeInsets(contentRect, UIEdgeInsetsVerAndHor(-contentRect.origin.y, -contentRect.origin.x));
    return CGRectEdgeInsets(rect, self.titleEdgeInsets);
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
//    [super drawRect:rect];
//    CGRect titleRect = rect;
    HMUIStyleContext *context = [self drawStyleInRect:rect];
//    titleRect = context.contentFrame;
    
    if (context==nil) {
        [super drawRect:rect];
    }
}




@end

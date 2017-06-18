//
//  HMUITapbarView.m
//  GPSService
//
//  Created by Eric on 14-4-18.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUITapbarView.h"

@interface HMUITapbarView ()
@property (assign, nonatomic,readwrite) NSInteger preSelectedIndex;
@property (assign, nonatomic,readwrite) NSInteger lastSelectedIndex;
@property (nonatomic, HM_STRONG)NSMutableArray *currentItems;

@end


@implementation HMUITapbarView
{
    BOOL _isBuilded;
    NSMutableArray *_subItems;
    
    NSMutableDictionary *_subSpaces;
    
    BOOL            viewHasLoaded;
    CGSize          totalSize;
    CGSize          customSpace;
    BOOL            animating;
    BOOL            _showMask;
}
@synthesize selectedIndex=_selectedIndex,indentation,tail,space=_space,preSelectedIndex = _preSelectedIndex,showSelectedState=_showSelectedState;
@synthesize currentItems;
@synthesize slideview;
@synthesize slideStyle=_slideStyle;
@synthesize selectedColor=_selectedColor;
@synthesize slideviewColor = _slideviewColor;
@synthesize baseView;
@synthesize defaultColor=_defaultColor;
@synthesize slideHeight;
@synthesize barStyle=_barStyle;
@synthesize direction = _direction;
@synthesize lastSelectedIndex = _lastSelectedIndex;

DEF_SIGNAL(TAPCHANGED);
DEF_SIGNAL(TAPNOSELECTED);

- (id)init
{
    
    return [self initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initSelfDefault];
//        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib{
//    self.backgroundColor = [UIColor clearColor];
    [super awakeFromNib];
    [self initSelfDefault];
}


- (void)initSelfDefault{
    if (!_isBuilded) {
        _isBuilded = YES;
        
        _space = 0;
        indentation=0;
        _preSelectedIndex = 0;
        _selectedIndex = 0;
        _showSelectedState = YES;
        
        _subItems = [[NSMutableArray array]retain];
        _subSpaces = [[NSMutableDictionary dictionary]retain];
        
        self.selectedColor = [UIColor md_blue_400];
        self.defaultColor = [UIColor whiteColor];
        
        self.baseView = [[[UIScrollView alloc]initWithFrame:self.bounds]autorelease];
        self.baseView.backgroundColor = [UIColor clearColor];
        self.baseView.showsHorizontalScrollIndicator = NO;
        self.baseView.showsVerticalScrollIndicator = NO;
        self.baseView.clipsToBounds = NO;
        [self addSubview:self.baseView];
        
        self.clipsToBounds = YES;
        
        self.slideAnimateDuration = .25f;
        self.slideHeight = 1;
        self.slideview = [HMUIView spawn];
        self.slideStyle = UITapbarSlideStyleNone;
        self.slideview.backgroundColor = self.selectedColor;
        
        [self.baseView addSubview:self.slideview];
    }
    
}

- (void)showMask:(BOOL)show{
    _showMask = show;
    [self setNeedsDisplay];
}

- (void)dealloc
{
    self.selectedColor = nil;
    [_subSpaces removeAllObjects];
    [_subSpaces release];
    [_subItems removeAllObjects];
    [_subItems release];
    self.currentItems = nil;
    self.slideview = nil;
    self.defaultColor = nil;
    self.slideviewColor = nil;
    [self.baseView removeFromSuperview];
    self.baseView = nil;
    HM_SUPER_DEALLOC();
}

- (void)setSlideStyle:(UITapbarSlideStyle)slideStyle{
    _slideStyle = slideStyle;
    self.slideview.hidden=NO;
    if (self.direction==UITapbarDirectionVertical) {
        self.slideview.width = self.slideHeight;
        self.slideview.x = 0;
    }else{
        self.slideview.height = self.slideHeight;
        self.slideview.y = 0;
    }
    
    if (_slideStyle==UITapbarSlideStyleTop) {
        if (self.direction==UITapbarDirectionVertical) {
            self.slideview.x = self.width-self.slideHeight;
        }
    }else if (_slideStyle==UITapbarSlideStyleBottom){
        if (self.direction==UITapbarDirectionHorizontal) {
            self.slideview.y = self.height-self.slideHeight;
        }
    }else if (_slideStyle==UITapbarSlideStyleFull){
        if (self.direction==UITapbarDirectionVertical) {
            self.slideview.width = self.width;
        }else{
            self.slideview.height = self.height;
        }
    }else if (_slideStyle==UITapbarSlideStyleCenter){
        if (self.direction==UITapbarDirectionVertical) {
            self.slideview.x = (self.width - self.slideview.width)/2;
        }else{
            self.slideview.y = (self.height - self.slideview.height)/2;
        }
    }else{
        self.slideview.size = CGSizeZero;
        self.slideview.y = 0;
        self.slideview.hidden=YES;
    }
    
}

- (void)setBarStyle:(UITapbarStyle)barStyle{
    _barStyle = barStyle;
    
    [self setNeedsDisplay];
}

- (void)setSelectedColor:(UIColor *)selectedColor{
    [_selectedColor release];
    _selectedColor = [selectedColor retain];
    for (UIButten *btn in self.currentItems) {
        if ([btn isKindOfClass:[UIButten class]]) {
            [btn setTitleColor:selectedColor forState:UIControlStateSelected];
        }
    }
}

- (void)setSlideviewColor:(UIColor *)slideviewColor{
    [_slideviewColor release];
    _selectedColor = [slideviewColor retain];
    self.slideview.backgroundColor = _selectedColor;
}

- (void)setDefaultColor:(UIColor *)defaultColor{
    [_defaultColor release];
    _defaultColor = [defaultColor retain];
    for (UIButten *btn in self.currentItems) {
        if ([btn isKindOfClass:[UIButten class]]) {
            [btn setTitleColor:_defaultColor forState:UIControlStateNormal];
        }
    }
}

#pragma mark - 视图添加

- (void)addSpaceObj:(NSObject*)obj{
    NSString *string = [NSString stringWithFormat:@"%d",(int)_subItems.count];
    NSNumber *number = [_subSpaces valueForKey:string];
    CGFloat offset = [number isKindOfClass:[NSNumber class]]?number.floatValue:0;
    if (offset>0) {
        customSpace.width -= offset;
        customSpace.height -= 1;
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        customSpace.width += [(NSNumber*)obj floatValue];
        customSpace.height += 1;
    }
    
    [_subSpaces setValue:obj forKey:string];
}

- (void)addSpace:(CGFloat)space{
    [self addSpaceObj:@(space)];
}

- (void)addFlexible{
    [self addSpaceObj:@"flexible"];
}

- (void)addSpace{
    [self addSpaceObj:@"space"];
}

- (void)replaceIndex:(NSInteger)index WithView:(UIView*)content animated:(BOOL)animated{
    UIView *view = [_subItems safeObjectAtIndex:index];
    if (view==nil) {
        return;
    }
    [content setFrame:view.frame];
    if (content.superview!=self.baseView) {
        [self.baseView addSubview:content];
    }
    if (animated) {
        [UIView animateWithDuration:.25f animations:^{
            view.alpha = .0f;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
        content.alpha =.0f;
        [UIView animateWithDuration:.25f delay:.1f options:UIViewAnimationOptionCurveEaseIn animations:^{
            content.alpha =1.f;
        } completion:^(BOOL finished) {
            
        }];
    }else{
        [view removeFromSuperview];
        content.alpha =1.f;
    }
    
    [_subItems replaceObjectAtIndex:index withObject:content];
    
}

- (void)replaceIndex:(NSInteger)index WithTitle:(NSString*)title Name:(NSString *)name animated:(BOOL)animated{
    [self replaceIndex:index WithTitle:title Name:name background:YES animated:animated];
}

- (void)replaceIndex:(NSInteger)index WithTitle:(NSString*)title Name:(NSString *)name background:(BOOL)background animated:(BOOL)animated{
    
    index = MIN(index, _subItems.count);
    
    UIButten *button = [self buttonWithImageName:name title:title background:background];
    
    [self replaceIndex:index WithView:button animated:animated];
    
}
- (UIButten *)buttonWithImageName:(NSString*)name title:(NSString *)title{
    return  [self buttonWithImageName:name title:title background:YES];
}

- (UIButten *)buttonWithImageName:(NSString*)name title:(NSString *)title background:(BOOL)background{
    UIButten *button = [[[UIButten alloc]init]autorelease];
    button.tagString = @"__CustomTapBar";
    button.eventReceiver = self;
    if (name) {
        
        if (background) {
            [button setBackgroundImagePrefixName:name title:nil];
        }else{
            [button setImagePrefixName:name title:nil];
        }
            
    }
    if (title) {
        [button setTitle:title forState:UIControlStateNormal];
    }
    return  button;
}

- (void)addContentView:(UIView*)content size:(CGSize)size{
    [content setFrame:CGRectMakeBound(size.width, size.height)];
    [_subItems addObject:content];
    [self.baseView addSubview:content];
}

- (UIButten *)addItemWithTitle:(NSString *)title imageName:(NSString *)name size:(CGSize)size{
    return [self addItemWithTitle:title imageName:name size:size background:NO];
}

- (UIButten *)addItemWithTitle:(NSString*)title imageName:(NSString*)name size:(CGSize)size background:(BOOL)background{
    
    UIButten *button = [self buttonWithImageName:name title:title background:background];
    if (self.selectedColor) {
        [button setTitleColor:_selectedColor forState:UIControlStateSelected];
    }
    if (self.defaultColor) {
        [button setTitleColor:_defaultColor forState:UIControlStateNormal];
    }
    [button setFrame:CGRectMakeBound(size.width, size.height)];
    [_subItems addObject:button];
    [self.baseView addSubview:button];
    return button;
}

#pragma mark - 视图更新

- (void)clearData{
    [self.currentItems makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.currentItems removeAllObjects];
    [_subItems removeAllObjects];
}

- (void)updateItems{
    
   
    for (UIView *curent in self.currentItems) {
        if ([_subItems containsObject:curent]) {
            continue;
        }
        [curent removeFromSuperview];
    }

    self.currentItems = [NSMutableArray arrayWithArray:_subItems];
    
    if (_subItems.count==0) {
        return;
    }
    
    if (self.barStyle!=UITapbarStyleAutolayout) {
     
        if (CGSizeEqualToSize(self.size, CGSizeZero)) {
            return;
        }
        totalSize = CGSizeZero;//实体视图的大小
        
        
        if (self.direction==UITapbarDirectionVertical) {
            for (UIView *view in _subItems) {
                if (view.superview!=self.baseView) {
                    [self.baseView addSubview:view];
                }
                totalSize.width = MAX(totalSize.width, view.width);
                totalSize.height += view.height;
            }
        }else{
            for (UIView *view in _subItems) {
                if (view.superview!=self.baseView) {
                    [self.baseView addSubview:view];
                }
                totalSize.height = MAX(totalSize.height, view.height);
                totalSize.width += view.width;
            }
        }
        
        [self layoutInBound:self.size];
        
    }else{
        [self setNeedsUpdateConstraints];
        [self needsUpdateConstraints];
        [self layoutIfNeeded];
    }
    [self setSelectedIndex:self.selectedIndex witoutSignal:YES];
}


- (id)viewWithIndex:(NSInteger)index{
    return [_subItems safeObjectAtIndex:index];
}

//布局子视图
- (void)layoutInBound:(CGSize)bound{
    
    CGPoint orgin = CGPointZero;
    orgin.x =indentation;
    
    CGFloat space = self.space;
    CGFloat flex = 0;
    self.baseView.scrollEnabled = NO;
    CGSize contentsize = bound;
    CGFloat others = bound.width-totalSize.width;
    if (self.direction==UITapbarDirectionVertical) {
        others = bound.height-totalSize.height;
    }
    
    switch (self.barStyle) {
            
        case UITapbarStyleFitSpace:
            space = (others-indentation-tail)/(_subItems.count-1);
            space = ceil(space-0.5);
            
            break;
        case UITapbarStyleFitOrign:
            space = others/(_subItems.count+1);
            space = ceil(space-0.5);
            if (self.direction==UITapbarDirectionVertical){
                orgin.y = space;
            }else{
                orgin.x = space;
            }
            break;
        case UITapbarStyleFitSize:{
            CGFloat width = 0;
            space = 0;
            CGSize s;
            if (self.direction==UITapbarDirectionVertical){
                width = (bound.height-indentation-tail)/(_subItems.count);
                s = CGSizeMake(bound.width, width);
            }else{
                width = (bound.width-indentation-tail)/(_subItems.count);
                s = CGSizeMake(width, bound.height);
            }
                
            for (UIView *sub in _subItems) {
                sub.size = s;
            }
        }
            break;
        case UITapbarStyleFitWidth:{
            CGFloat width = 0;
            space = 0;
            
            if (self.direction==UITapbarDirectionVertical){
                width = (bound.height-indentation-tail)/(_subItems.count);
            }else{
                width = (bound.width-indentation-tail)/(_subItems.count);
            }
            
            for (UIView *sub in _subItems) {
                if (self.direction==UITapbarDirectionVertical) {
                     sub.height = width;
                }else{
                     sub.width = width;
                }
            }
        }
            break;
        case UITapbarStyleCanFlexible:{
            CGFloat actionSpace = 0;
            
            for (NSString *obj in _subSpaces.allValues) {
                if ([obj isKindOfClass:[NSNumber class]]) {
                    actionSpace += [obj floatValue];
                }else if ([obj isEqual:@"flexible"]){
                    flex+=1;
                }else{
                    actionSpace += space;
                }
            }
            flex = (others-actionSpace-indentation-tail)/flex;
            
        }
            break;
        case UITapbarStyleCenter:{
            
            CGFloat offset = (others-space*_subSpaces.count)/2;
            if (self.direction==UITapbarDirectionVertical){
                orgin.y = offset;
            }else{
                orgin.x = offset;
            }
        }
            break;
        case UITapbarStyleCustom:{
            self.baseView.scrollEnabled = YES;
            CGFloat actionSpace = 0;
            
            for (NSString *obj in _subSpaces.allValues) {
                if ([obj isKindOfClass:[NSNumber class]]) {
                    actionSpace += [obj floatValue];
                }else if ([obj isEqual:@"flexible"]){
                    flex+=1;
                }else{
                    actionSpace += space;
                }
            }
            
            if (self.direction==UITapbarDirectionVertical){
                contentsize.height = totalSize.height+actionSpace+indentation+tail;
            }else{
                contentsize.width = totalSize.width+actionSpace+indentation+tail;
            }
        }
            break;
            
        case UITapbarStyleCanScroll:
            self.baseView.scrollEnabled = YES;
            
            if (self.direction==UITapbarDirectionVertical){
                contentsize.height = totalSize.height+space*(_subItems.count-1)+indentation+tail;
            }else{
                contentsize.width = totalSize.width+space*(_subItems.count-1)+indentation+tail;
            }
            break;
        default:
            break;
    }
    self.baseView.contentSize = contentsize;
    
    for (NSInteger i = 0;i<_subItems.count;i++) {
        UIView *item = [_subItems safeObjectAtIndex:i];
        
        if (self.direction==UITapbarDirectionVertical){
            orgin.x = item.width>self.width?0:(self.width-item.width)/2;
        }else{
            orgin.y = item.height>self.height?(self.height-item.height):(self.height-item.height)/2;
        }
        NSString *key = [NSString stringWithFormat:@"%d",(int)i];
        
        if (self.barStyle == UITapbarStyleCustom
            || self.barStyle == UITapbarStyleCenter
            ||self.barStyle == UITapbarStyleCanFlexible) {
            NSNumber *number = [_subSpaces valueForKey:key];
            CGFloat offset = number==nil?0:([number isKindOfClass:[NSNumber class]]?number.floatValue:([number isEqual:@"flexible"]?flex:space));
            if (self.direction==UITapbarDirectionVertical){
                orgin.y += offset;
            }else{
                orgin.x += offset;
            }
            
        }else if(i>0){
            if (self.direction==UITapbarDirectionVertical){
                orgin.y += space;
            }else{
                orgin.x += space;
            }
            
        }
        
        
        CGRect rect =CGRectMake(orgin.x, orgin.y, item.width, item.height );
        [item setFrame:rect];
        if (self.direction==UITapbarDirectionVertical){
            orgin.y += rect.size.height;
        }else{
            orgin.x += rect.size.width;
        }
        
    }
    
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    UIView *newSuperview = self.superview;
    if (newSuperview) {
        viewHasLoaded = YES;
    }else{
        viewHasLoaded = NO;
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.slideStyle = self.slideStyle;
    self.baseView.size = self.size;
    
    [self updateItems];
    [self setmask];
    
}

- (void)setmask{
    if (!_showMask) {
        self.layer.mask = nil;
        return;
    }
    if (CGSizeEqualToSize([self bounds].size, CGSizeZero)) {
        return;
    }
    CAGradientLayer* gradientMask = [CAGradientLayer layer];
    gradientMask.bounds = self.layer.bounds;
    gradientMask.position = CGPointMake([self bounds].size.width / 2, [self bounds].size.height / 2);
    NSObject *transparent = (NSObject*) [[UIColor clearColor] CGColor];
    NSObject *opaque = (NSObject*) [[UIColor blackColor] CGColor];
    gradientMask.startPoint = CGPointMake(0.0, CGRectGetMidY(self.frame));
    gradientMask.endPoint = CGPointMake(1.0, CGRectGetMidY(self.frame));
    float fadePoint = (float)10/self.frame.size.width;
    [gradientMask setColors: [NSArray arrayWithObjects: transparent, opaque, opaque, transparent, nil]];
    [gradientMask setLocations: [NSArray arrayWithObjects:
                                 [NSNumber numberWithFloat: 0.0],
                                 [NSNumber numberWithFloat: fadePoint],
                                 [NSNumber numberWithFloat: 1 - fadePoint],
                                 [NSNumber numberWithFloat: 1.0],
                                 nil]];
    self.layer.mask = gradientMask;
}


#pragma mark - 选中设置

- (void)setSelectedIndex:(NSInteger)selectedIndex{
    
    UIButten *source = [_subItems safeObjectAtIndex:selectedIndex];
    if ([source isKindOfClass:[UIButten class]]) {
        [self sendSignal:UIButten.TOUCH_UP_INSIDE withObject:nil from:source];
    }
    _selectedIndex = selectedIndex;
}
- (void)targetSliderViewPosition:(UIView *)target{
    if (self.direction==UITapbarDirectionVertical) {
        self.slideview.height = [target height];
        self.slideview.y = [target y];
    }else{
        self.slideview.width = [target width];
        self.slideview.x = [target x];
    }
}
- (void)fromSliderViewPostion:(UIView*)target{
    if (self.direction==UITapbarDirectionVertical) {
        self.slideview.height = fabs(target.y-self.slideview.y)+target.height;
        self.slideview.y = MIN(target.y, self.slideview.y);
    }else{
        self.slideview.width = fabs(target.x-self.slideview.x)+target.width;
        self.slideview.x = MIN(target.x, self.slideview.x);
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex witoutSignal:(BOOL)yesOrNo{
    
    if (!yesOrNo) {
        [self setSelectedIndex:selectedIndex];
    }else{
        _preSelectedIndex = _selectedIndex;
        _selectedIndex = selectedIndex;
        
        if (_showSelectedState) {
            UIButten *source = [_subItems safeObjectAtIndex:selectedIndex];
            
            HMSignal *signal = nil;
            if ([source isKindOfClass:[UIButten class]]&&self.superview) {
                signal =  [self sendSignal:HMUITapbarView.TAPNOSELECTED withObject:source];
            }
            if (!signal.boolValue) {
                if (source&&[source respondsToSelector:@selector(setSelected:)]&&!(source.buttenType&UIButtenTypeAutoSelect)) {
                    [source setSelected:YES];
                }
                if (_lastSelectedIndex!=_selectedIndex) {
                    source = [_subItems safeObjectAtIndex:_lastSelectedIndex];
                    if (source&&[source respondsToSelector:@selector(setSelected:)]) {
                        [source setSelected:NO];
                    }
                }
                _lastSelectedIndex = _selectedIndex;
            }
            
            
        }
        
    }
     UIButten *target = [self viewWithIndex:selectedIndex];
    
    //选中动画设置
    if (_showSelectedState) {
       
        if (target&&[target respondsToSelector:@selector(setSelected:)]&&target.selected){
            [self.slideview.layer removeAllAnimations];
            [self.slideview.layer.sublayers makeObjectsPerformSelector:@selector(removeAllAnimations)];
            
            switch (self.slideAnimate) {
                case UITapbarSlideAnimatedNormal:
                    [UIView animateWithDuration:self.slideAnimateDuration animations:^{
                        [self targetSliderViewPosition:target];
                    }];
                    break;
                case UITapbarSlideAnimatedEarthworm:
                    [UIView animateWithDuration:self.slideAnimateDuration animations:^{
                        
                        [self fromSliderViewPostion:target];
                        
                    } completion:^(BOOL finished) {
                        if (finished) {
                            [UIView animateWithDuration:MAX(self.slideAnimateDuration/3, .15f) animations:^{
                                [self targetSliderViewPosition:target];
                            }];
                        }
                       
                    }];
                    break;
                default:
                    [self targetSliderViewPosition:target];
                    break;
            }
        }
    }
    
    //选中项居中
    if (self.autoSelectedCenter&&self.baseView.scrollEnabled) {
        
        CGPoint point = self.baseView.contentOffset;
        CGFloat half = 0;//可见区域居中的位置
        CGFloat currentHalf = 0;//目前居中位置
        CGFloat targetHalf = 0;//子视图居中的位置
        
        if (self.direction==UITapbarDirectionVertical) {
            half = self.baseView.height/2;
            targetHalf = target.y+target.height/2;
            currentHalf = targetHalf-half;
            point.y = currentHalf;
            point.y = MAX(point.y, 0);
            point.y = MIN(point.y, self.baseView.contentSize.height-half*2);
            
        }else{
            half = self.baseView.width/2;
            targetHalf = target.x+target.width/2;
            currentHalf = targetHalf-half;
            point.x = currentHalf;
            point.x = MAX(point.x, 0);
            point.x = MIN(point.x, self.baseView.contentSize.width-half*2);
            
        }
        
        [self.baseView setContentOffset:point animated:YES];
    }
    
}
ON_Button(signal){

    if ([signal is:UIButten.TOUCH_UP_INSIDE]) {
        UIButten *but = signal.source;
        
        [self setSelectedIndex:[_subItems indexOfObject:but] witoutSignal:YES];
        if (self.superview) {
            [self sendSignal:self.TAPCHANGED withObject:but];
        }
        
    }
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end

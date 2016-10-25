//
//  HMPhotoCell.m
//  EFExtend
//
//  Created by mac on 15/4/5.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import "HMPhotoCell.h"


#pragma mark -
#pragma mark HMPhotoItem
#pragma mark -

@interface HMPhotoItem ()
@property (nonatomic, readwrite) NSInteger         index;
@end

@implementation HMPhotoItem{
    UIImageView *_srcImageView;
}
@synthesize tag;
@synthesize imageSize;
@synthesize webUrl;
@synthesize localUrl;
@synthesize index;
@synthesize trueSize;

@synthesize srcImageView=_srcImageView;
@synthesize placeholder;
@synthesize captureImage;
@synthesize image;
@synthesize suggestNotLoad;
@synthesize indexPath;

@synthesize fullScreen;
@synthesize indent;
@synthesize space;
@synthesize leading;
@synthesize floatScreen;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self resetItem];
    }
    return self;
}

- (void)dealloc
{
    self.webUrl = nil;
    self.localUrl = nil;
    self.image = nil;
    self.srcImageView = nil;
    self.placeholder = nil;
    self.captureImage = nil;
    self.indexPath=nil;
    HM_SUPER_DEALLOC();
}
- (void)setSrcImageView:(UIImageView *)srcImageView
{
    if (_srcImageView!=srcImageView) {
        [_srcImageView release];
        _srcImageView = [srcImageView retain];
    }
    if (srcImageView) {
        UIImage *__image = [srcImageView isGif]?srcImageView.image.images.firstObject:srcImageView.image;
        self.placeholder = [__image blurryWithBlurLevel:.05];
    }
    
}

- (void)resetItem{
    indent = -1;
    space = -1;
    leading = -1;
}

@end


#pragma mark -
#pragma mark HMPhotoCell
#pragma mark -

@interface HMPhotoCell ()<UIScrollViewDelegate>
@property (HM_STRONG, nonatomic,readwrite) UIImageView * imageView;
@property (assign, nonatomic)   CGPoint touchCenter;
@property (assign, nonatomic)   CGPoint scaleCenter;
@property (assign, nonatomic)   BOOL    doubleTap;
@property (HM_STRONG, nonatomic,readwrite) NSTimer * touchTimer;

@end

@implementation HMPhotoCell{
    UIImageView * _imageView;
    UIView *      _descptionView;
    HMPhotoItem *  _photo;
    BOOL            _enableZoom;
}

@synthesize reuseId;
@synthesize loaded;
@synthesize reused;
@synthesize imageView=_imageView;
@synthesize descptionView=_descptionView;
@synthesize photo=_photo;
@synthesize defaultImage;
@synthesize dataSource;
@synthesize touchCenter,scaleCenter;
@synthesize enableZoom = _enableZoom;
@synthesize doubleTap;
@synthesize imageInsets=_imageInsets;
@synthesize touchTimer;
@synthesize index;
@synthesize enableDrag;

- (void)dealloc
{
    [self.touchTimer invalidate];
    self.touchTimer= nil;
    self.reuseId = nil;
    self.imageView = nil;
    self.descptionView = nil;
    self.dataSource = nil;
    self.defaultImage = nil;
    self.photo = nil;
    HM_SUPER_DEALLOC();
}
- (instancetype)init
{
    return  [self initWithFrame:CGRectZero];
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
    [self initSelfDefault];
}

- (instancetype)initWithReuseIdentifier:(NSString*)indentifer
{
    self = [super init];
    if (self) {
        [self initSelfDefault];
        self.reuseId = [indentifer empty]?@"afadfecCEll":indentifer;
    }
    return self;
}

- (void)initSelfDefault{
    self.backgroundColor = [UIColor clearColor];
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.clipsToBounds = YES;
}

#pragma mark 调整frame
- (void)adjustFrame
{
    if (_imageView.image == nil) return;
    
    // 基本尺寸参数
    CGSize boundsSize = self.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGSize imageSize = _imageView.image.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    
    if (CGSizeEqualToSize(boundsSize, CGSizeZero)||CGSizeEqualToSize(imageSize, CGSizeZero)) {
        return;
    }
    // 设置伸缩比例
    CGFloat scale = (boundsHeight<boundsWidth)?(imageHeight/boundsHeight):(imageWidth/boundsWidth);
    CGFloat minScale = 1.0;
    CGFloat maxScale = MAX(scale, 2);
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;
    
    CGRect imageFrame = (boundsHeight<boundsWidth)?CGRectMake(0, 0, imageWidth / scale , boundsHeight):CGRectMake(0, 0, boundsWidth, imageHeight / scale);
    
    // 内容尺寸
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.contentSize = imageFrame.size;
    [CATransaction commit];
    self.scrollEnabled = YES;
    
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)setEnableZoom:(BOOL)enableZoom{
    if (_enableZoom!=enableZoom) {
        
        _enableZoom = enableZoom;
        
    }
}


- (void)setFrame:(CGRect)frame{
    self.zoomScale = 1.0f;
    [super setFrame:frame];
    
    
}
- (void)layoutSubviews{
    [super layoutSubviews];

    if (self.zoomScale==1.0) {
        CGRect frame = self.bounds;
        frame.origin = CGPointZero;
        _imageView.frame = CGRectEdgeInsets(self.bounds, _imageInsets);
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.contentSize = frame.size;
        [CATransaction commit];

        _descptionView.y = self.height-_descptionView.height;
        _descptionView.width = self.width;
        [self bringSubviewToFront:_descptionView];
    }
    if (self.zoomScale==1.0) {
        if (_enableZoom) {
            [self adjustFrame];
        }
    }

}

- (void)loadImageIfNotExist{
    [self loadImageIfNotExist:NO];
}

- (void)loadImageIfNotExist:(BOOL)animated{
    if (self.photo.webUrl) {
        self.imageView.showProgress = YES;
        self.alpha = 1.f;
        [self.imageView setImageWithURLString:self.photo.webUrl placeholderImage:self.defaultImage useCache:YES Success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if (_enableZoom) {
                
                [self adjustFrame];
            }
            
            if (animated) {
                CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath:@"opacity"];
                basic.fromValue = @(.0f);
                basic.toValue = @(1.0f);
                basic.duration = .15f;
                basic.removedOnCompletion = YES;
                [self.imageView.layer addAnimation:basic forKey:@"fadeIn"];
            }else{
                [self.imageView.layer removeAnimationForKey:@"fadeIn"];
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
        
    }else{
        self.imageView.showProgress = NO;
    }
}
- (void)setImageInsets:(UIEdgeInsets)imageInsets{
    _imageInsets = imageInsets;
    
    self.imageView.frame = CGRectEdgeInsets(self.bounds, _imageInsets);
}

- (void)setPhoto:(HMPhotoItem *)photo{
    
    if (photo!=_photo) {
        [_photo release];
        _photo = [photo retain];
        
        [self resetImage:photo];
    }
    if (_enableZoom) {
        
        [self adjustFrame];
    }
    
}

- (void)resetImage:(HMPhotoItem *)photo{
    UIImage *image = nil;
    if (photo) {
        
        if (photo.localUrl) {
            if ([photo.localUrl isAbsolutePath]) {
                image = [UIImage imageWithContentsOfFile:photo.localUrl];
            }else{
                image = [UIImage imageNamed:photo.localUrl];
            }
            
        }
        if (!image) {
            image = photo.image;
        }
        
        if (!image) {
            image = photo.placeholder;
        }
        image = image==nil?self.defaultImage:image;
        
        image = [UIImage imageCachedWithURL:[NSURL URLWithString:photo.webUrl] defaultImage:image];
        [_imageView setImageWithImage:image];
        
    }else{
        _imageView.image = nil;
    }
}

- (void)setDescptionView:(UIView *)descptionView{
    if (_descptionView) {
        [_descptionView removeFromSuperview];
        [_descptionView release];
        _descptionView=nil;
    }
    _descptionView = [descptionView retain];
    if (descptionView) {
        [self addSubview:descptionView];
    }
}

- (UIView *)descptionView{
    if (_descptionView==nil) {
        _descptionView = [[UILabel spawn]retain];
        _descptionView.frame = CGRectMake(0, 0, self.width, 20);
        
        _descptionView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:.5];
        [self addSubview:_descptionView];
    }
    return _descptionView;
}

- (UIImageView *)imageView{
    if (_imageView==nil) {
        _imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.clipsToBounds = YES;
//        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (void)clearView{
    self.photo.webUrl = nil;
    [self resetImage:self.photo];
}


-(void)didPinch:(UIPinchGestureRecognizer*)pinch{
    if(pinch.state == UIGestureRecognizerStateBegan){
        self.scaleCenter = self.touchCenter;
    }else if ((pinch.state == UIGestureRecognizerStateEnded)||(pinch.state == UIGestureRecognizerStateCancelled)){
        
        if (self.imageView.frame.origin.x>0.1||self.imageView.frame.origin.y>0.1) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:.3f];
            self.imageView.transform = CGAffineTransformIdentity;
            [UIView commitAnimations];
            return;
        }
    }
    CGFloat deltaX = self.scaleCenter.x-self.imageView.bounds.size.width/2.0;
    CGFloat deltaY = self.scaleCenter.y-self.imageView.bounds.size.height/2.0;
    
    CGAffineTransform transform =  CGAffineTransformTranslate(self.imageView.transform, deltaX, deltaY);
    transform = CGAffineTransformScale(transform, pinch.scale, pinch.scale);
    transform = CGAffineTransformTranslate(transform, -deltaX, -deltaY);
    
    self.imageView.transform = transform;
    
    pinch.scale = 1;
}

-(void)didPan:(UIPanGestureRecognizer*)recognizer{
    
    CGPoint translation = [recognizer translationInView:self.imageView];
    CGAffineTransform transform = CGAffineTransformTranslate( self.imageView.transform, translation.x, translation.y);
    self.imageView.transform = transform;
    
    if (self.imageView) {
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.imageView];
    }else{
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.imageView];
    }
    
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    doubleTap = YES;
    if ([self.dataSource respondsToSelector:@selector(photoCellDoubleTouchIn:)]) {
        if (![self.dataSource photoCellDoubleTouchIn:self])return;
    }
    CGPoint touchPoint = [tap locationInView:self];
    if (self.zoomScale == self.maximumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        [self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
    }
}

#pragma mark Touches

- (void)handleTouches:(NSSet*)touches
{
    self.touchCenter = CGPointZero;
    UITouch *tt = [touches anyObject];
    
    if(touches.count < 2){
        static CGPoint startPoint;
        static BOOL moved = NO;
        if ([tt phase] == UITouchPhaseBegan){
            startPoint = [tt locationInView:self];
            moved= NO;
            if ([self.dataSource respondsToSelector:@selector(photoCellTouchBegin:)]) {
                [self.dataSource photoCellTouchBegin:self];
            }
        }else if ([tt phase] == UITouchPhaseMoved) {
            CGPoint endPoint = [tt locationInView:self];
            if (fabs(endPoint.x - startPoint.x)>10||fabs(endPoint.y - startPoint.y)>10) {
                moved = YES;
                if (self.enableDrag) {
                    
                }
            }
        }
        
        if (!_enableZoom) {
            
            if ([tt phase] == UITouchPhaseBegan){
                self.alpha = .6f;
                
            }else if (([tt phase] == UITouchPhaseEnded)||([tt phase] == UITouchPhaseCancelled)){
                self.alpha = 1.f;
            }
            
            if ([tt phase] == UITouchPhaseEnded) {
                
                if (!moved&&[self.dataSource respondsToSelector:@selector(photoCellTouchIn:)]) {
                    [self.dataSource photoCellTouchIn:self];
                }
            }
        }else{
            if (tt.phase == UITouchPhaseBegan) {
                if (self.touchTimer!=nil) {
                    [self.touchTimer invalidate];
                    self.touchTimer = nil;
                }
                self.touchTimer = [NSTimer scheduledTimerWithTimeInterval:0.8f target:self selector:@selector(longTouch:) userInfo:tt repeats:NO];
                
            }else if ([tt phase] == UITouchPhaseEnded) {
                NSTimeInterval delaytime = 0.3;//自己根据需要调整
                
                switch ([tt tapCount]) {
                    case 1:
                    {
                        if (self.touchTimer!=nil) {
                            [self.touchTimer invalidate];
                        }
                        self.touchTimer = [NSTimer scheduledTimerWithTimeInterval:delaytime target:self selector:@selector(singleTouch:) userInfo:tt repeats:NO];
                    }
                        break;
                    case 2:{
                        if (self.touchTimer!=nil) {
                            [self.touchTimer invalidate];
                            self.touchTimer= nil;
                        }
                        [self doubleTouch:tt];
                        
                    }
                        break;
                    default:
                        if (self.touchTimer!=nil) {
                            [self.touchTimer invalidate];
                            self.touchTimer = nil;
                        }
                        break;
                }
            }else{
                if (self.touchTimer!=nil) {
                    [self.touchTimer invalidate];
                    self.touchTimer = nil;
                }
            }
        }
        if (([tt phase] == UITouchPhaseEnded)||([tt phase] == UITouchPhaseCancelled)){

            if ([self.dataSource respondsToSelector:@selector(photoCellTouchEnd:)]) {
                [self.dataSource photoCellTouchEnd:self];
            }
        }
        return;//处理多点触摸时的纠正中点位置，给捏和旋转提供参考
    }
    
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        UITouch *touch = (UITouch*)obj;
        CGPoint touchLocation = [touch locationInView:self];
        self.touchCenter = CGPointMake(self.touchCenter.x + touchLocation.x, self.touchCenter.y +touchLocation.y);
        
    }];
    self.touchCenter = CGPointMake(self.touchCenter.x/touches.count, self.touchCenter.y/touches.count);
}

- (void)singleTouch:(UITouch*)touch{
    if ([self.dataSource respondsToSelector:@selector(photoCellTouchIn:)]) {
        [self.dataSource photoCellTouchIn:self];
    }
}

- (void)longTouch:(UITouch*)touch{
    if ([self.dataSource respondsToSelector:@selector(photoCellLongTouchIn:)]) {
        [self.dataSource photoCellLongTouchIn:self];
    }
}


- (void)doubleTouch:(UITouch*)touch{
    if ([self.dataSource respondsToSelector:@selector(photoCellDoubleTouchIn:)]) {
        if (![self.dataSource photoCellDoubleTouchIn:self])return;
    }
    CGPoint touchPoint = [touch locationInView:self];
    if (self.zoomScale == self.maximumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        [self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouches:[event allTouches]];

}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self handleTouches:[event allTouches]];

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouches:[event allTouches]];

}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouches:[event allTouches]];

}

@end

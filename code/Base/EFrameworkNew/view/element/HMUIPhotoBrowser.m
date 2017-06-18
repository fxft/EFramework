//
//  HMPhotoBrowserBoard.m
//  WestLuckyStar
//
//  Created by Eric on 14-5-10.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIPhotoBrowser.h"
#import "HMPhotoCell.h"

#define kPhotoViewTagOffset 10000
#define PhotoViewIndex(photoView) ([photoView index] - kPhotoViewTagOffset)
#define PhotoViewSetIndex(photoView,tag) ([photoView setIndex:((tag)+ kPhotoViewTagOffset)])

@interface HMUIPhotoBrowser ()<HMPhotoCellDelegate,UIScrollViewDelegate>
{
    // 滚动的view
    UIScrollView *_photoScrollView;
    
    NSMutableArray *_curViews;
    
    // 一开始的状态栏
    BOOL _statusBarHiddenInited;
    NSInteger scrollPage;
    
    CGFloat offsetx;
    
    NSInteger _prePhotoIndex;
    BOOL    _allowOriententation;
    
    NSTimeInterval elapsedTmp;
    BOOL _timerAdded;
    
    NSTimer *_timer;
    
}

@property (nonatomic, HM_STRONG) UILabel *textlabel;
@property (nonatomic,assign) UIInterfaceOrientation orientaionDeviceNext;
@property (nonatomic,HM_WEAK) UIView *ssssuperView;
@property (nonatomic,HM_STRONG) UIView *baseWindow;
@property (nonatomic,HM_STRONG) UIView *roateWindow;
@property (nonatomic,HM_STRONG)NSMutableDictionary *clazzes;

@end

@implementation HMUIPhotoBrowser{
    NSUInteger count;
    BOOL canBounces;
    NSInteger prePage;
    BOOL roating;
    BOOL loaded;
}
@synthesize allowGifPlay;
@synthesize allowOriententation = _allowOriententation;
@synthesize allowAutoScroll=_allowAutoScroll;
@synthesize showText=_showText;
@synthesize textlabel=_textlabel;
@synthesize allowZoom=_allowZoom;
@synthesize currentPhotoIndex=_currentPhotoIndex;
@synthesize padding=_padding;
@synthesize photoContentMode;
@synthesize photos=_photos;
@synthesize delegate=_delegate;
@synthesize autoScrollInteval=_autoScrollInteval;
@synthesize orientaionDeviceNext;
@synthesize dataSource=_dataSource;
@synthesize circulation;
@synthesize baseWindow=_baseWindow;

- (void)initSelfDefault{
    [self viewDidLoad];
}
#pragma mark - Lifecycle

- (void)viewDidLoad
{
    _allowZoom = NO;
    _padding = 10;
    _autoScrollInteval = 5.f;
    _prePhotoIndex = -1;
    circulation = YES;
    self.photoContentMode = UIViewContentModeScaleAspectFit;
    self.backgroundColor = [UIColor clearColor];
    self.autoresizesSubviews = YES;
    self.clazzes = [NSMutableDictionary dictionary];
    
    // 1.创建UIScrollView
    [self createScrollView];
    
    // 2.创建工具条
    [self createToolbar];
    
}

- (void)createScrollView
{
    CGRect frame = self.frame;
   
    if (CGRectEqualToRect(CGRectZero, frame)) {
        return;
    }
    
    frame.origin = CGPointZero;
    frame.origin.x -= self.padding;
    frame.size.width += (2 * self.padding);
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (_photoScrollView==nil) {
        _photoScrollView = [[UIScrollView alloc] initWithFrame:frame];
        _photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _photoScrollView.pagingEnabled = YES;
        _photoScrollView.delegate = self;
        _photoScrollView.showsHorizontalScrollIndicator = NO;
        _photoScrollView.showsVerticalScrollIndicator = NO;
        _photoScrollView.backgroundColor = [UIColor clearColor];
        _photoScrollView.bounces = NO;
        [self addSubview:_photoScrollView];
        
    }
    if (!CGRectEqualToRect(_photoScrollView.frame, frame)) {
        _photoScrollView.frame = frame;
    }
    [CATransaction commit];
}

- (UIImageView *)backgroundBaseView{
    return self.baseWindow.backgroundImageView;
}

- (void)hidden{
    
    [self removeWhenTouched];
    
}

- (void)show{
    
    [self showAnimated:YES];
    
}

- (void)showAnimated:(BOOL)animated
{
    
    [self showFromView:nil animated:animated];
    
}

- (void)showHumbFrom:(CGRect)from image:(UIImage*)image willAnimated:(void (^)(UIImageView *))willAnimated step1Animated:(void (^)(UIImageView *))step1Animated  step2Animated:(void (^)(UIImageView *))step2Animated compeleAnimated:(void (^)(void))compeleAnimated{

    if (image==nil) {
        NSAssert(YES, @"image is nil");
    }
    
    UIImageView *imagev = [self.baseWindow viewWithTag:11111111];
    if (imagev==nil) {
        imagev = [[[UIImageView alloc]initWithImage:image] autorelease];
        imagev.contentMode = self.photoContentMode;
        imagev.frame = from;
        imagev.tag = 11111111;
        imagev.backgroundColor = [UIColor clearColor];
        [self.baseWindow addSubview:imagev];
    }
    
    
    if (willAnimated) {
        willAnimated(imagev);
    }
    
    [UIView animateWithDuration:.25f animations:^{
        
        if (step1Animated) {
            step1Animated(imagev);
        }
        
    } completion:^(BOOL finished) {
        
        if (step2Animated) {
            [UIView animateWithDuration:.20f animations:^{
                step2Animated(imagev);
            } completion:^(BOOL finished) {
                imagev.hidden = YES;
                [imagev removeFromSuperview];
                if (compeleAnimated) {
                    compeleAnimated();
                }
            }];
        }else{
            imagev.hidden = YES;
            [imagev removeFromSuperview];
            
            if (compeleAnimated) {
                compeleAnimated();
            }
        }
        
        
    }];
}

- (void)showHumbHide:(BOOL)hide{
    CGRect frame=CGRectZero;
    UIImage *image = nil;
    if ([self.dataSource respondsToSelector:@selector(photoBrowser:sourceAtIndex:)]) {
        
        image = [self.dataSource photoBrowser:self sourceAtIndex:self.currentPhotoIndex];
        
        if ([image isKindOfClass:[UIImageView class]]) {
            
            frame = [(UIImageView*)image frameInWindow];
            image = [(UIImageView*)image image];
        }else if ([image isKindOfClass:[UIView class]]) {
            
            frame = [(UIView*)image frameInWindow];
            image = [(UIView*)image screenshot];
        }
        if ([self.dataSource respondsToSelector:@selector(photoBrowser:frameAtIndex:)]){
            frame = [self.dataSource photoBrowser:self frameAtIndex:self.currentPhotoIndex];
        }
    }
//    if (image==nil) {
//        NSAssert(YES, @"image is nil");
//    }
//    
    WS(weakSelf)
    CGRect to = self.superview.bounds;
    CGAffineTransform affine = [self orientationAffineFor:self.orientaionDeviceNext];
    CGRect framebase = [self.baseWindow frameInWindow];
    if (hide) {
        
        to = CGRectMake(frame.origin.x-framebase.origin.x, frame.origin.y-framebase.origin.y, frame.size.width, frame.size.height);
        frame = self.superview.frame;
    }
    
    
    [self showHumbFrom:frame image:image willAnimated:^(UIImageView *imagev) {

        if ([weakSelf.delegate respondsToSelector:@selector(photoBrowser:willshowHumbImageView:atIndex:)]){
            [weakSelf.delegate photoBrowser:weakSelf willshowHumbImageView:imagev atIndex:weakSelf.currentPhotoIndex];
        }
        
        weakSelf.alpha = 0.f;
        if (!hide) {
            weakSelf.roateWindow.alpha = 0.f;
            weakSelf.backgroundBaseView.alpha = 0.f;
            weakSelf.frame = to;
            imagev.frame = CGRectMake(frame.origin.x-framebase.origin.x, frame.origin.y-framebase.origin.y, frame.size.width, frame.size.height);
        }else{
            imagev.transform = affine;
            imagev.frame = frame;
        }
        
        [_curViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
    } step1Animated:^(UIImageView *imagev) {
        if (hide) {
            imagev.transform = CGAffineTransformIdentity;
            weakSelf.roateWindow.alpha = 0.f;
            weakSelf.backgroundBaseView.alpha = 0.f;
        }else{
            weakSelf.roateWindow.alpha = 1.f;
            weakSelf.backgroundBaseView.alpha = 1.f;
        }
        imagev.frame = to;
        
    } step2Animated:^(UIImageView *imagev) {
        weakSelf.alpha = hide?0.0f:1.f;
    } compeleAnimated:^{
        if (hide) {
            
            [weakSelf.baseWindow removeFromSuperview];
            [weakSelf removeFromSuperview];
        }else{
            [weakSelf reloadData];
        }
       
    }];
}


- (void)showFromView:(UIView *)view animated:(BOOL)animated{
    
    UIWindow *window = nil;
    if (![HMUIApplication sharedInstance].window) {
        window = [UIApplication sharedApplication].keyWindow;
    }else{
        window = [HMUIApplication sharedInstance].window;
    }
    if (view) {
        window = (id)view;
    }
    self.ssssuperView = window;
    
    if (self.baseWindow.superview!=self.ssssuperView) {
        [self.ssssuperView addSubview:self.baseWindow];
    }
    
    
    if (self.superview!=self.roateWindow) {
        [self.roateWindow addSubview:self];
        self.frame = self.roateWindow.bounds;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }

    if (!animated) {
        self.alpha = 1.f;
        [self reloadData];
    }else{
        if (self.allowHumb) {
            [self showHumbHide:NO];
        }else{
            self.alpha = 0.f;
            
            [UIView animateWithDuration:.28f
                             animations:^{
                                 self.alpha = 1.f;
                             } completion:^(BOOL finished) {
                                 [self reloadData];
                                 
                             }];
        
        
        }
    }
    
    
}


- (void)dealloc
{
    if (_allowOriententation) {
        self.allowOriententation = NO;
    }
    self.textlabel = nil;
    [_photoScrollView release];
    for (HMPhotoCell *cell in _curViews) {
        cell.dataSource = nil;
    }
    [self.clazzes removeAllObjects];
    self.clazzes = nil;
    [_curViews removeAllObjects];
    [_curViews release];
    self.roateWindow = nil;
    self.photos = nil;
    self.delegate = nil;
    self.dataSource = nil;
    self.baseWindow = nil;
    self.ssssuperView = nil;
    HM_SUPER_DEALLOC();
}

- (UIView *)baseWindow{
    if (_baseWindow==nil) {
        BOOL roated = NO;
        if ([self.delegate respondsToSelector:@selector(photoBrowserWindowRoated:)]){
            roated = [self.delegate photoBrowserWindowRoated:self];
        }
        if (roated) {
            _baseWindow = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        }else{
            if (UIInterfaceOrientationIsPortrait((UIInterfaceOrientation)[UIDevice currentDevice].orientation)) {
                _baseWindow = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
            }else if (UIInterfaceOrientationIsLandscape((UIInterfaceOrientation)[UIDevice currentDevice].orientation)) {
                _baseWindow = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
            }else{
                
                _baseWindow = [[UIView alloc]initWithFrame:CGRectMake(0, 0, MIN([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width), MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width))];
            }

        }
//        _baseWindow.frame = CGRectMake(100, 100, 200, 300);
        _baseWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _baseWindow.tagString = @"photoBWindow";
        _baseWindow.backgroundImageView.backgroundColor = [UIColor blackColor];
    }
    return _baseWindow;
}

- (UIView *)roateWindow{
    if (_roateWindow==nil) {
        
        _roateWindow = [[UIView alloc]initWithFrame:self.baseWindow.bounds];
//        _roateWindow.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:.4f];
        [_roateWindow EFOwner:self.baseWindow];
    }
    return _roateWindow;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview!=nil) {
        [self createScrollView];
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow{
    [super willMoveToWindow:newWindow];
    
    if (newWindow==nil) {
        if (self.allowAutoScroll) {
            [self stopTimer];
        }
    }else{
        if (self.allowAutoScroll) {
            [self startTimer];
        }
    }
    
}

- (void)setPadding:(CGFloat)padding{
    _padding = padding;
    [self createScrollView];
}



- (void)setDataSource:(id<HMUIPhotoBrowserDatasource>)dataSource
{
    if (_dataSource != dataSource)
    {
        _dataSource = dataSource;
        if (_dataSource)
        {
            [self reloadData];
        }
    }
}

- (void)setDelegate:(id<HMUIPhotoBrowserDelegate>)delegate
{
    if (_delegate != delegate)
    {
        _delegate = delegate;
        if (_delegate && _dataSource)
        {
            [self setNeedsLayout];
        }
    }
}
#pragma mark - 自动滚动

- (void)stopTimer{
    if (_timerAdded) {
        _timerAdded= NO;
        [[HMTicker sharedInstance] removeReceiver:self];
        [_timer invalidate];
        [_timer  release];
        _timer = nil;
    }
    
}

- (void)startTimer{
    if (!_timerAdded&&count>1) {
        elapsedTmp = 0;
        _timerAdded = YES;
        [[HMTicker sharedInstance] addReceiver:self];
    }
}

ON_Tick(elapsed){
    
    if (!self.allowAutoScroll) {
        return;
    }
    
    @synchronized(_curViews){
        elapsedTmp += elapsed;
        if (self.autoScrollInteval<=elapsedTmp) {
            elapsedTmp = 0;
            
            [self nextPhotoIndexAnimated:YES];
        }
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self removeWhenTouched];
}

- (void)setAllowAutoScroll:(BOOL)allowAutoScroll{
    _allowAutoScroll = allowAutoScroll;
    if (_allowAutoScroll) {
        [self startTimer];
    }else{
        [self stopTimer];
    }
}

#pragma mark - 支持反转

- (void)setAllowOriententation:(BOOL)allowOriententation{
    if (_allowOriententation == allowOriententation) {
        return;
    }
    _allowOriententation = allowOriententation;
    if (allowOriententation) {
        [self observeNotification:UIDeviceOrientationDidChangeNotification];

    }else{
        [self unobserveNotification:UIDeviceOrientationDidChangeNotification];

    }
}

ON_NOTIFICATION(__notification){
    if (![__notification is:UIDeviceOrientationDidChangeNotification]) {
        return;
    }
    
    if (!self.allowOriententation) {
        return;
    }
    if (!UIInterfaceOrientationIsPortrait((UIInterfaceOrientation)[UIDevice currentDevice].orientation)&&!UIInterfaceOrientationIsLandscape((UIInterfaceOrientation)[UIDevice currentDevice].orientation)) {
        return;
    }
    self.orientaionDeviceNext = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
   
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(orientationUpdate:) object:self];
    [self performSelector:@selector(orientationUpdate:) withObject:self afterDelay:.25f inModes:@[NSRunLoopCommonModes]];
}

- (void)orientationUpdate:(id)obj{
    if (roating) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(orientationUpdate:) object:self];
        [self performSelector:@selector(orientationUpdate:) withObject:self afterDelay:.25f inModes:@[NSRunLoopCommonModes]];
        return;
    }
    roating = YES;
    self.userInteractionEnabled = NO;
    CGAffineTransform affine = [self orientationAffineFor:self.orientaionDeviceNext];
    BOOL roated = NO;
    if ([self.delegate respondsToSelector:@selector(photoBrowserWindowRoated:)]){
        roated = [self.delegate photoBrowserWindowRoated:self];
    }
    
    BOOL orientaionLandscape = UIInterfaceOrientationIsLandscape(self.orientaionDeviceNext);
    
    if (roated) {
        affine = CGAffineTransformIdentity;
//        orientaionLandscape = YES;
    }
    
    
    WS(weakSelf)
    CGRect frame = CGRectZero;
    frame = weakSelf.baseWindow.bounds;
    HMPhotoCell *cell = weakSelf.currentPhotoView;
    
    [UIView animateWithDuration:.25f animations:^{
        weakSelf.superview.transform = affine;//旋转一个角度，不旋转baseview
        weakSelf.textlabel.alpha = .0f;
    } completion:^(BOOL finished) {
        if (finished) {
            //制造一个截屏，放置到baseview
            [weakSelf showHumbFrom:frame image:cell.imageView.image willAnimated:^(UIImageView * imagev) {
               //初始化位置和方向
                 weakSelf.hidden = YES;
                if (orientaionLandscape){
                    imagev.frame = frame;
                    imagev.transform = affine;
                }else{
                    imagev.frame = CGRectMake((-cell.width+frame.size.width)/2, (-cell.height+frame.size.height)/2, cell.width, cell.height);
                    imagev.transform = affine;
                }
            } step1Animated:^(UIImageView *imagev) {
                imagev.frame = frame;
                weakSelf.superview.frame = frame;
            } step2Animated:^(UIImageView *imagev) {
                weakSelf.hidden = NO;
                weakSelf.textlabel.alpha = 1.0f;
            } compeleAnimated:^{
//                weakSelf.superview.transform = affine;
                
//                weakSelf.superview.center = weakSelf.baseWindow.center;
//                cell.hidden = NO;
//                weakSelf.transform = CGAffineTransformIdentity;
                weakSelf.userInteractionEnabled = YES;
                
//                if (orientaionLandscape) {
//                    weakSelf.superview.frame = CGRectMake(0, 0, frame.size.height, frame.size.width);
//                }else{
//                    weakSelf.superview.frame = frame;
//                }
                roating = NO;
            }];
        }else{
//            weakSelf.superview.transform = affine;
            weakSelf.superview.frame = frame;
            cell.hidden = NO;
//            weakSelf.transform = CGAffineTransformIdentity;
            weakSelf.userInteractionEnabled = YES;
            
//            if (orientaionLandscape) {
//                weakSelf.frame = CGRectMake(0, 0, frame.size.height, frame.size.width);
//            }else{
//                weakSelf.frame = frame;
//            }
            roating = NO;
        }
    }];
}

#pragma mark - 私有方法

- (void)setShowText:(BOOL)showText{
    _showText = showText;
    if (showText&&self.textlabel==nil) {
        self.textlabel = [UILabel spawn];
        self.textlabel.font = [UIFont systemFontOfSize:20];
        self.textlabel.textColor = [UIColor grayColor];
        [self addSubview:self.textlabel];
        self.textlabel.text = [NSString stringWithFormat:@"%d/%d",(int)MIN(_currentPhotoIndex+1,count),(int)count];
    }
    
    [self resetLabelFrame];
    
    if (!showText) {
        [self.textlabel removeFromSuperview];
        self.textlabel = nil;
    }
}

- (void)resetLabelFrame{
    if (!_showText) {
        return;
    }
    [self bringSubviewToFront:self.textlabel];
    [self.textlabel sizeToFit];
    self.textlabel.y = 10;//self.height-self.textlabel.height-22;
    self.textlabel.x = (self.width-self.textlabel.width)/2;
    
}
#pragma mark 创建工具条
- (void)createToolbar
{
    [self updateTollbarState];
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self createScrollView];

    if (!loaded) {
        [self reloadData];
    }else{
        _prePhotoIndex = -1;
        [self showPhotos];
    }
}


- (void)updatePhotos{
    
    [self resetContentsize];
    
    for (int i = 0; i<count; i++) {
        HMPhotoItem *photo = _photos[i];
        photo.tag = i;
    }
}

#pragma mark 设置选中的图片

- (HMPhotoCell *)currentPhotoView{
    
    for (HMPhotoCell *cell in _curViews) {
        if (PhotoViewIndex(cell)==_currentPhotoIndex) {
            return cell;
        }
    }
    return nil;
//    return [_curViews safeObjectAtIndex:_curViews.count>1?1:0];
}
- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;
    
    // 显示所有的相片
    [self showPhotos];
    
}

- (void)nextPhotoIndexAnimated:(BOOL)animated{
    if (count<3&&(count==2&&!self.circulation)) {
        return;
    }
    
    [_curViews enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
        obj.hidden = NO;
    }];
    
    if (!self.circulation) {
        
        if (_currentPhotoIndex==count-1) {
            _currentPhotoIndex=count;
            prePage = -1;
            [_photoScrollView setContentOffset:CGPointMake(0, 0) animated:animated];
            
            return;
        }else if (_currentPhotoIndex==0){
            [_photoScrollView setContentOffset:CGPointMake(1 * (ceilf(self.width)+2*self.padding), 0) animated:animated];
            return;
        }
        
    }
    
    [_photoScrollView setContentOffset:CGPointMake(2 * (ceilf(self.width)+2*self.padding), 0) animated:animated];
    
    
    
}

- (void)prePhotoIndexAnimated:(BOOL)animated{
    if (count<2) {
        return;
    }
    if (!self.circulation) {
        
        if (_currentPhotoIndex==0) {
            prePage = 5;
            [_photoScrollView setContentOffset:CGPointMake(2 * (ceilf(self.width)+2*self.padding), 0) animated:animated];
            
            return;
        }
        
    }
    [_photoScrollView setContentOffset:CGPointMake(0, 0) animated:animated];
    
}


#pragma mark - MJPhotoView代理
- (BOOL)photoCellDoubleTouchIn:(HMPhotoCell *)cell{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didDoubbleTouchedIndex:)]) {
       return [self.delegate photoBrowser:self didDoubbleTouchedIndex:PhotoViewIndex(cell)];
    }
    return YES;
}

- (void)photoCellLongTouchIn:(HMPhotoCell *)cell{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didLongTouchedIndex:)]) {
        [self.delegate photoBrowser:self didLongTouchedIndex:PhotoViewIndex(cell)];
    }
}

- (void)photoCellTouchIn:(HMPhotoCell *)cell
{
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didTouchedIndex:)]) {

        if ([self.delegate photoBrowser:self didTouchedIndex:PhotoViewIndex(cell)]) {
            return;
        }
    }
    [self removeWhenTouched];
    
}

- (void)photoCellTouchBegin:(HMPhotoCell *)cell{
    if (_allowAutoScroll) {
        [self stopTimer];
    }
}

-(void)photoCellTouchEnd:(HMPhotoCell *)cell{
    if (_allowAutoScroll) {
        [self startTimer];
    }
}
- (void)removeWhenTouched
{
    [self showHumbHide:YES];
}

#pragma mark 显示照片
- (void)showPhotos
{
    if ([self.dataSource respondsToSelector:@selector(photoBrowserNumbers:)]) {
        count = [self.dataSource photoBrowserNumbers:self];
    }
    if (self.allowAutoScroll) {
        if (count<=1) {
            [self stopTimer];
        }else{
            [self startTimer];
        }
    }
    if (_currentPhotoIndex >count-1) {
        _currentPhotoIndex = 0;
    }
    if (count==0) {
        [_curViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        return;
    }
    
    [self resetContentsize];
    [self loadDataAnimated:NO];
    
}

- (void)reloadData{
    loaded = YES;
    _prePhotoIndex = -1;
    
    prePage = -1;
    [_curViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_curViews removeAllObjects];
    [self showPhotos];
}

- (void)resetContentsize{
    if (count <= 1) {
        _photoScrollView.scrollEnabled = NO;
    }else{
        _photoScrollView.scrollEnabled = YES;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (self.circulation) {
        _photoScrollView.contentSize = CGSizeMake(_photoScrollView.width * 3, 0);
    }else{
        _photoScrollView.contentSize = CGSizeMake(_photoScrollView.width * MIN(count, 3), 0);
    }
    [CATransaction commit];
}

- (void)loadDataAnimated:(BOOL)animated
{
    if (_currentPhotoIndex==_prePhotoIndex) {
        return;
    }
    _prePhotoIndex = _currentPhotoIndex;
    
    NSInteger index = _currentPhotoIndex;

    //102 》213
    [self getDisplayCellsWithCurpage:index];
    
    if (scrollPage>1) {
        if (!self.circulation) {
            [_curViews sortUsingComparator:^NSComparisonResult(HMPhotoCell* obj1, HMPhotoCell* obj2) {
                return obj1.index>obj2.index?NSOrderedDescending:(obj1.index==obj2.index?NSOrderedSame:NSOrderedAscending);
            }];
            
        }
    }
    
    [self resetFrame:animated];
    
    self.textlabel.text = [NSString stringWithFormat:@"%d/%d",(int)MIN(_currentPhotoIndex+1,count),(int)count];
    [self resetLabelFrame];
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didChangedToPageAtIndex:)]) {
        
        [self.delegate photoBrowser:self didChangedToPageAtIndex:_currentPhotoIndex];
    }
}

- (void)resetFrame:(BOOL)animated{

    CGRect photoViewFrame = self.bounds;
    CGPoint point = CGPointZero;

    for (int i = 0; i < _curViews.count; i++) {
        HMPhotoCell *v = [_curViews objectAtIndex:i];
        photoViewFrame.origin.x = (photoViewFrame.size.width * i) + (2*i+1)*self.padding;
        
        v.frame = photoViewFrame;
        if (PhotoViewIndex(v)!=_currentPhotoIndex) {
            v.hidden = YES;
        }else{
            v.hidden = NO;
            point = CGPointMake(v.origin.x-self.padding, v.origin.y);
        }
    }

    
    
//    point = CGPointMake(_photoScrollView.width,0);
    prePage = 1;
    if (!self.circulation) {//不循环
        if (_currentPhotoIndex==0) {//最前
            point = CGPointZero;
            prePage = 0;
        }else if (_currentPhotoIndex==count-1){//最后
            point = CGPointMake(_currentPhotoIndex*(photoViewFrame.size.width+2*self.padding), 0);
            prePage = _currentPhotoIndex;
        }
       
    }else{
        if (_curViews.count<=2) {
            prePage = _currentPhotoIndex;
            point = CGPointMake(_currentPhotoIndex*_photoScrollView.width, 0);
        }
    }
    
    
    [_photoScrollView setContentOffset:point animated:animated];
}

- (void)getDisplayCellsWithCurpage:(NSUInteger)page {
    
    @synchronized(_curViews){
        if (!_curViews) {
            _curViews = [[NSMutableArray alloc] init];
        }
        [_curViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        scrollPage = 1;
        
        if (count>1) {
            NSInteger pre = [self validPageValue:page-1];
            
            [self addPage:pre];
            scrollPage = 2;
        }
        [self addPage:page];
            
        if (count>2||self.circulation) {
            NSInteger last = [self validPageValue:page+1];
            [self addPage:last];
            scrollPage = 3;
        }
        
    }
}
- (id)dequeueReusableCell{
    
    for (UIView *cell in _curViews) {
        if (cell.superview==nil) {
            return cell;
        }
    }
    return nil;
}

- (HMPhotoCell *)addPage:(NSUInteger)page{
    HMPhotoItem *photo = nil;
    if ([self.dataSource respondsToSelector:@selector(photoBrowser:itemAtIndex:)]) {
        photo = [self.dataSource photoBrowser:self itemAtIndex:page];
    }else{
        photo = [_photos safeObjectAtIndex:page];
    }
    if (photo==nil) {
        return nil;
    }
    HMPhotoCell * photoView = nil;
    if ([self.dataSource respondsToSelector:@selector(photoBrowser:forItem:)]) {
        photoView = [self.dataSource photoBrowser:self forItem:photo];
        if (![_curViews containsObject:photoView]) {
            [_curViews addObject:photoView];
        }
        if (photoView.superview!=_photoScrollView) {
            [_photoScrollView addSubview:photoView];
        }
    }
    
    PhotoViewSetIndex(photoView,page);
    
    if (photoView!=nil) {
        if ([self.delegate respondsToSelector:@selector(photoBrowser:didLoadCell:atIndex:)]) {
            [self.delegate photoBrowser:self didLoadCell:photoView atIndex:page];
        }
        return photoView;
    }
    
    photoView = [self dequeueReusableCell];
    
    if (!photoView) {
#if  __has_feature(objc_arc)
        photoView = [[HMPhotoCell alloc] init];
#else
        photoView = [[[HMPhotoCell alloc] init]autorelease];
#endif
        
        photoView.dataSource = self;
        photoView.eventReceiver = self;
        [_curViews addObject:photoView];
    }
    
    if (photoView.superview!=_photoScrollView) {
        [_photoScrollView addSubview:photoView];
    }
    
    // 调整当期页的frame

    PhotoViewSetIndex(photoView,page);
    
    photoView.enableZoom = self.allowZoom;
    photoView.imageView.contentMode = self.photoContentMode;
    photoView.photo = photo;
    photoView.imageView.showProgress = YES;
    [photoView loadImageIfNotExist:NO];
    
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didLoadCell:atIndex:)]) {
        [self.delegate photoBrowser:self didLoadCell:photoView atIndex:page];
    }
    return photoView;
}

- (HMPhotoCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier{
    for (HMPhotoCell *cell in _curViews) {
        if (cell.superview==nil&&[cell.reuseId isEqualToString:identifier]) {
            return cell;
        }
    }
    if (identifier) {
        Class cellClass = [self.clazzes valueForKey:identifier];
        return [[cellClass alloc]initWithReuseIdentifier:identifier];
    }
    
    return nil;
}

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier{
    if (!cellClass||!identifier) {
        return;
    }
    if (![cellClass isSubclassOfClass:[HMPhotoCell class]]) {
        NSAssert(false, @"must be HMPhotoCell");
        return;
    }
    @synchronized(self.clazzes){
        [self.clazzes setValue:cellClass forKey:identifier];
    }
}

#pragma mark 更新toolbar状态
- (void)updateTollbarState
{
    _currentPhotoIndex = _photoScrollView.contentOffset.x / (self.width+2*self.padding);
    //    _toolbar.currentPhotoIndex = _currentPhotoIndex;
}

#pragma mark - UIScrollView Delegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    if (_allowAutoScroll) {
        [self stopTimer];
    }
    
    [_curViews enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
        obj.hidden = NO;
    }];
    
    if (self.allowGifPlay) {
        HMPhotoCell *cell = [self currentPhotoView];
        if (cell) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell.imageView setGifPlay:NO];
            });
            
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self resetSubViews:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self resetSubViews:scrollView];
    
}

- (void)resetSubViews:(UIScrollView*)scrollView{
    CGFloat x = scrollView.contentOffset.x;
    CGFloat page = x/scrollView.width;
    page  = ceilf(page);
    //往下翻一张 index 增加
    if (prePage>page) {//往上翻 index 减少
        _currentPhotoIndex = [self validPageValue:_currentPhotoIndex-1];
        
    }else if (prePage<page){//往下翻一张 index 增加
        _currentPhotoIndex = [self validPageValue:_currentPhotoIndex+1];
        
    }
    if (prePage==page) {
        for (int i = 0; i < _curViews.count; i++) {
            HMPhotoCell *v = [_curViews objectAtIndex:i];
            
            if (PhotoViewIndex(v)!=_currentPhotoIndex) {
                v.hidden = YES;
            }else{
                v.hidden = NO;
            }
        }
    }else{
        [self loadDataAnimated:NO];
    }
   
    HMPhotoCell *cell = [self currentPhotoView];

    if (cell&&self.allowGifPlay) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.imageView setGifPlay:YES];
        });
    }
    if (_allowAutoScroll) {
        [self startTimer];
    }
}

- (NSInteger)validPageValue:(NSInteger)value {
    
    if(value <= -1) value = count - 1;
    if(value >= count) value = 0;
    
    return value;
    
}
@end



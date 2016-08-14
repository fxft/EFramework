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
@property (nonatomic,HM_STRONG) UIWindow *baseWindow;

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
@synthesize textlabel;
@synthesize allowZoom=_allowZoom;
@synthesize currentPhotoIndex=_currentPhotoIndex;
@synthesize padding=_padding;
@synthesize photoContentMode;
@synthesize photos=_photos;
@synthesize delegate;
@synthesize autoScrollInteval=_autoScrollInteval;
@synthesize orientaionDeviceNext;
@synthesize dataSource=_dataSource;
@synthesize removeWhenTouch;
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
    self.backgroundColor = [UIColor whiteColor];
    self.autoresizesSubviews = YES;
    
    // 1.创建UIScrollView
    [self createScrollView];
    
    // 2.创建工具条
    [self createToolbar];
    
}

- (void)createScrollView
{
    CGRect frame = self.frame;
    frame.origin = CGPointZero;
    frame.origin.x -= self.padding;
    frame.size.width += (2 * self.padding);
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (_photoScrollView==nil) {
        _photoScrollView = [[UIScrollView alloc] initWithFrame:frame];
        _photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _photoScrollView.pagingEnabled = YES;
        _photoScrollView.delegate = self;
        _photoScrollView.showsHorizontalScrollIndicator = NO;
        _photoScrollView.showsVerticalScrollIndicator = NO;
        _photoScrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:_photoScrollView];
//        _photoScrollView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
        
    }
    if (!CGRectEqualToRect(_photoScrollView.frame, frame)) {
        _photoScrollView.frame = frame;
    }
    [CATransaction commit];
}

- (void)hidden{
    [self removeWhenTouched];
}

- (void)show
{
    UIWindow *window = nil;
    if (![HMUIApplication sharedInstance].window) {
        window = [UIApplication sharedApplication].keyWindow;
    }else{
        window = [HMUIApplication sharedInstance].window;
    }

    self.ssssuperView = window;
    
    self.backgroundColor = [UIColor blackColor];
    
    if (self.superview!=self.baseWindow) {
        [self.baseWindow addSubview:self];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    }
    self.baseWindow.hidden = NO;
    
    if (CGRectEqualToRect(self.frame, CGRectZero)) {
        
        self.frame = [UIScreen mainScreen].bounds;
    }
    
    self.alpha = 0.f;
    [UIView animateWithDuration:.28f
                     animations:^{
                         self.alpha = 1.f;
                     } completion:^(BOOL finished) {
                         if (self.allowOriententation) {
                          self.ssssuperView.hidden = YES;
                         }
                         
                     }];
    self.showText = YES;
    removeWhenTouch = YES;
    [self reloadData];
}
- (void)showFromView:(UIView *)view forImage:(UIImage*)image{
    CGRect from = [view frameInWindow];
    UIWindow *window = nil;
    if (![HMUIApplication sharedInstance].window) {
        window = [UIApplication sharedApplication].keyWindow;
    }else{
        window = [HMUIApplication sharedInstance].window;
    }

    self.ssssuperView = window;
    
    
    UIImageView *imagev = [[[UIImageView alloc]initWithImage:image] autorelease];
    imagev.contentMode = self.photoContentMode;
    self.baseWindow.hidden = NO;
    imagev.frame = from;
    [self.baseWindow addSubview:imagev];
    self.alpha = 0.f;
    self.backgroundColor = [UIColor blackColor];
    
    if (CGRectEqualToRect(self.frame, CGRectZero)) {
        
        self.frame = [UIScreen mainScreen].bounds;
    }
    
    if (self.superview!=self.baseWindow) {
        [self.baseWindow addSubview:self];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    }
    [_curViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    

    [UIView animateWithDuration:0.35f animations:^{
        imagev.frame = [UIScreen mainScreen].bounds;
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        imagev.hidden = YES;
        [imagev removeFromSuperview];
        if (self.allowOriententation) {
            self.ssssuperView.hidden = YES;
        }
        
        self.showText = YES;
        removeWhenTouch = YES;
        [self reloadData];
    }];
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
    [_curViews removeAllObjects];
    [_curViews release];
    self.photos = nil;
    self.delegate = nil;
    self.dataSource = nil;
    self.baseWindow = nil;
    self.ssssuperView = nil;
    HM_SUPER_DEALLOC();
}

- (UIWindow *)baseWindow{
    if (_baseWindow==nil) {
        _baseWindow = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _baseWindow.windowLevel = UIWindowLevelStatusBar + 8;
        _baseWindow.tagString = @"photoBWindow";
        _baseWindow.backgroundColor = [UIColor clearColor];
        //        baseWindow.layer.anchorPoint = CGPointMake(0.5, 0.5);
    }
    return _baseWindow;
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

- (void)setDataSource:(id<HMUIPhotoBrowserDatasource>)dataSource{
    _dataSource = dataSource;
    
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
    if (roating) {
        return;
    }
    self.orientaionDeviceNext = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;//[HMDeviceCapacity sharedInstance].orientaionDeviceNext;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(orientationUpdate:) object:self];
        [self performSelector:@selector(orientationUpdate:) withObject:self afterDelay:.1f inModes:@[NSRunLoopCommonModes]];
    });
}

- (void)orientationUpdate:(id)obj{
    roating = YES;
    self.userInteractionEnabled = NO;
    CGAffineTransform affine = [self orientationAffineFor:self.orientaionDeviceNext];
    if (!CGAffineTransformEqualToTransform(self.superview.transform, affine)) {
  
        [UIView animateWithDuration:.35f animations:^{
            self.superview.transform = affine;
            self.superview.frame = [[UIScreen mainScreen] bounds];
            self.textlabel.alpha = .0f;
        } completion:^(BOOL finished) {
           self.textlabel.alpha = 1.0f;
           roating = NO;
            self.userInteractionEnabled = YES;
        }];
        
        
    }else{
        self.userInteractionEnabled = YES;
        roating = NO;
    }
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
    [self.textlabel sizeToFit];
    self.textlabel.y = self.height-self.textlabel.height-22;
    self.textlabel.x = (self.width-self.textlabel.width)/2;
    
}
#pragma mark 创建工具条
- (void)createToolbar
{
    [self updateTollbarState];
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    
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


- (void)resetContentsize{
    if (count <= 1) {
        _photoScrollView.scrollEnabled = NO;
    }else{
        _photoScrollView.scrollEnabled = YES;
    }

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (self.circulation) {
        _photoScrollView.contentSize = CGSizeMake(_photoScrollView.width * 3, 1);
    }else{
        _photoScrollView.contentSize = CGSizeMake(_photoScrollView.width * MIN(count, 3), 1);
    }
    [CATransaction commit];
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
            [_photoScrollView setContentOffset:CGPointMake(1 * (self.width+2*self.padding), 0) animated:animated];
            return;
        }
        
    }
    
    [_photoScrollView setContentOffset:CGPointMake(2 * (self.width+2*self.padding), 0) animated:animated];
    
    
    
}

- (void)prePhotoIndexAnimated:(BOOL)animated{
    if (count<2) {
        return;
    }
    if (!self.circulation) {
        
        if (_currentPhotoIndex==0) {
            prePage = 5;
            [_photoScrollView setContentOffset:CGPointMake(2 * (self.width+2*self.padding), 0) animated:animated];
            
            return;
        }
        
    }
    [_photoScrollView setContentOffset:CGPointMake(0, 0) animated:animated];
    
}


#pragma mark - MJPhotoView代理
- (void)photoCellDoubleTouchIn:(HMPhotoCell *)cell{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didDoubbleTouchedIndex:)]) {
        [self.delegate photoBrowser:self didDoubbleTouchedIndex:PhotoViewIndex(cell)];
    }
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
    if (removeWhenTouch) {
        self.allowOriententation = NO;
        
        if ([self.superview.tagString is:@"photoBWindow"]) {
            self.ssssuperView.hidden = NO;
        }
        
        [UIView animateWithDuration:.35f animations:^{
            self.alpha = 0.f;
        } completion:^(BOOL finished) {
            
            [self removeFromSuperview];
            
            self.alpha = 1.f;
            if ([self.superview.tagString is:@"photoBWindow"]) {
                self.superview.hidden = YES;
            }
            
        }];
    }
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
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    for (int i = 0; i < _curViews.count; i++) {
        HMPhotoCell *v = [_curViews objectAtIndex:i];
        photoViewFrame.origin.x = (photoViewFrame.size.width * i) + (2*i+1)*self.padding;
        v.frame = photoViewFrame;
        if (PhotoViewIndex(v)!=_currentPhotoIndex) {
            v.hidden = YES;
        }else{
            v.hidden = NO;
        }
    }
    [CATransaction commit];
    
    CGPoint point = CGPointMake(photoViewFrame.size.width+2*self.padding, 0);
    prePage = 1;
    if (!self.circulation) {
        if (_currentPhotoIndex==0) {
            point = CGPointZero;
            prePage = 0;
        }else if (_currentPhotoIndex==count-1){
            point = CGPointMake(2*(photoViewFrame.size.width+2*self.padding), 0);
            
            prePage = 2;
        }
       
    }
    
    if (_curViews.count<=2) {
        prePage = _currentPhotoIndex;
        point = CGPointMake(_currentPhotoIndex*(photoViewFrame.size.width+2*self.padding), 0);
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
        photoView = [[[HMPhotoCell alloc] init]autorelease];
        photoView.dataSource = self;
        photoView.eventReceiver = self;
        photoView.backgroundColor = [UIColor clearColor];
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
    int x = scrollView.contentOffset.x;
    int page = x/scrollView.width;
    
    //往下翻一张 index 增加
    if (prePage>page) {//往上翻 index 减少
        _currentPhotoIndex = [self validPageValue:_currentPhotoIndex-1];
        
    }else if (prePage<page){//往下翻一张 index 增加
        _currentPhotoIndex = [self validPageValue:_currentPhotoIndex+1];
        
    }
    
    [self loadDataAnimated:NO];
   
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



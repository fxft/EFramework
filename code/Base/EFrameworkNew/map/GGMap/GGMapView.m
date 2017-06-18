//
//  GGMapView.m
//  LuckyStar
//
//  Created by chen Eric on 13-9-21.
//  Copyright (c) 2013年 Eric. All rights reserved.
//

#import "GGMapView.h"
#import "HMViewCategory.h"

#define TEST 0

@implementation HMPointAnnotation
@synthesize tagString=_tagString,indexPath=_indexPath,ID,iconId,degree;
@synthesize tag,name,data;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (void)dealloc
{
    self.data = nil;
    self.name = nil;
    SAFE_RELEASE(ID);
    SAFE_RELEASE(iconId);
    SAFE_RELEASE(_indexPath);
    SAFE_RELEASE(_tagString);
    HM_SUPER_DEALLOC();
}
@end



@implementation HMPinCalloutView{
    
}

@synthesize gridCell=_gridCell,minSize;
@synthesize selected;
@synthesize contentRect=_contentRect;
@synthesize shadowOffset;
@synthesize solidFillColor=_solidFillColor;
@synthesize shadowColor=_shadowColor;
@synthesize borderColor=_borderColor;

- (CGSize)minSize{
    return [self styleMinBounds].size;
}

- (void)setContentRect:(CGRect)contentRect{
    _contentRect = contentRect;
    [self initSelfDefault];
}

- (UIView *)gridCell{
    if (!_gridCell) {
        _gridCell = [[UIView alloc]init];
        [self addSubview:_gridCell];
    }
    return _gridCell;
}

- (void)setGridCell:(UIView *)gridCell{
    
    if ( _gridCell != gridCell )
	{
        if (_gridCell.superview == self) {
            [_gridCell removeFromSuperview];
            
        }
        [_gridCell release];
		_gridCell = [gridCell retain];
        
		if ( gridCell.superview != self )
		{
			[gridCell removeFromSuperview];
		}
        if (_gridCell) {
            [self addSubview:_gridCell];
            
            [self resetFrame];
        }
		
	}
}


- (void)resetFrame{

    CGRect rect = [self styleForBounds:self.bounds];
    self.gridCell.origin = rect.origin;
    
    self.backgroundColor = [UIColor clearColor];
    [self initStyle];
    
    [self setNeedsDisplay];
}

-(void)setFrame:(CGRect)frame{
    
    [super setFrame:frame];
    
    [self resetFrame];
}

- (void)initStyle{
    UIEdgeInsets inset = UIEdgeInsetsTBAndHor(10, 15, 5);
    if (!CGRectEqualToRect(_contentRect, CGRectZero)) {
        if (CGRectEqualToRect(self.bounds, _contentRect)) {
            self.style__ = nil;
            self.shadowOffset = CGSizeZero;
            return;
        }
    }
    CGFloat shadow = 5;
    self.shadowOffset = CGSizeMake(0, 5);
    
    
    self.style__ =   [HMUIShapeStyle styleWithShape:
                     [HMUISpeechBubbleShape shapeBottomWithRadius:5 arrow:.5 pointSize:CGSizeMake(20,10)] next:
                     
                     //shadow
                     [HMUIShadowStyle styleWithColor:_shadowColor blur:shadow offset:CGSizeMake(0, 3) next:
                      //fill color
                      [HMUIInsetStyle styleWithInset:UIEdgeInsetsAll(.25) next:
                       [HMUISolidFillStyle styleWithColor:_solidFillColor next:
                        [HMUIInsetStyle styleWithInset:UIEdgeInsetsAll(-.25) next:
                        
                              // border
                              [HMUISolidBorderStyle styleWithColor:_borderColor width:1 next:
                               
                               //box
                               [HMUIShapeStyle styleWithShape:[HMUIRoundedRectangleShape shapeWithRadius:2.5] next:
                                //inset save for new frame
                                [HMUIInsetStyle styleWithSaveForInset:UIEdgeInsetsAll(2) butWidth:0 height:8 next:
                                 [HMUILinearGradientFillStyle styleWithColor1:RGBGLASSA color2:RGBGLASSB next:
                                  //inset save end
                                  [HMUIInsetStyle styleWithRestoreNext:
                                   //box end
                                   
                               [HMUIInsetStyle styleWithInset:inset next:
                                
                                
                                nil]]]]]]]]]]//]]]]]
                    ];
}

- (void)initSelfDefault{
    self.backgroundColor = [UIColor clearColor];
    self.solidFillColor = RGBA(255, 255, 255, .7);
    self.shadowColor = RGBA(114, 156, 202, .7);
    self.borderColor = RGBA(100, 136, 182, .7);
    
    [self resetFrame];
    
}

- (void)dealloc
{
    self.solidFillColor = nil;
    self.shadowColor = nil;
    self.borderColor = nil;
    [_gridCell release];
    HM_SUPER_DEALLOC();
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    
}
- (void)updateCenter{
    //    BeeLog(@"%@",self.superview);
}

@end

@interface MKAnnotationView ()
- (void)_didUpdatePosition;
@end

@interface HMPointAnnotationView ()

@property (nonatomic,HM_STRONG,readwrite)    HMPinCalloutView *calloutView;
@property (nonatomic,HM_STRONG,readwrite)    UILabel *remark;
@property (nonatomic,HM_WEAK) MSOMapView *  mapview;
@property (nonatomic,HM_WEAK) UIView *  container;
@end

@implementation HMPointAnnotationView{
    
    CGRect callOutFrame;
    BOOL canCallOutView;
}
@synthesize calloutView=_calloutView,
remark=_remark,
tagString=_tagString,
delegate,
calloutCustom = _calloutCustom;
@synthesize mapview,container;
@synthesize annotation=_annotation;

- (void)setCalloutViewUserInterface:(BOOL)is{
    _calloutView.userInteractionEnabled = is;
}

-(id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        if (_calloutView==nil) {
            callOutFrame = CGRectZero;
            _calloutView = [[HMPinCalloutView spawn]retain];
            
        }
       
    }
    return self;
}

- (void)_didUpdatePosition{
    [super _didUpdatePosition];
    [self updateCalloutView];
}

- (void)dealloc
{
    [_tagString release];
    [_calloutView removeFromSuperview];
    [_calloutView release];
    [_remark removeFromSuperview];
    [_remark release];
    [self.container removeFromSuperview];
    self.container = nil;
    [_annotation release];
    _annotation= nil;
    HM_SUPER_DEALLOC();
}
-(UIView *)calloutViewCell{
    return _calloutView.gridCell;
}

-(UILabel *)remark{
    if (!_remark) {
        _remark = [[UILabel alloc]init];
        _remark.font = [UIFont systemFontOfSize:12];
        _remark.backgroundColor = [UIColor whiteColor];
        _remark.layer.borderWidth=1;
        _remark.layer.borderColor = [UIColor redColor].CGColor;
        [self addSubview:_remark];
    }
    return _remark;
}

-(void)setCanShowCallout:(BOOL)canShowCallout{
    canCallOutView=canShowCallout;
    [super setCanShowCallout:NO];
}

- (void)setCalloutView:(UIView *)grid custom:(BOOL)yes{
    
    if (yes) {
        _calloutView.style__ = nil;
    }
    [_calloutView setGridCell:grid];
    
}

- (void)resetCalloutViewFrame:(UIView*) grid{
    CGSize size = _calloutView.minSize;
    CGSize sizeGrid;
    
    if (!grid.translatesAutoresizingMaskIntoConstraints) {
        sizeGrid = [grid systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    }else{
        sizeGrid = grid.size;
    }
    _calloutView.frame = CGRectMakeBound(sizeGrid.width+size.width, sizeGrid.height+size.height);
    callOutFrame = _calloutView.bounds;
    callOutFrame.origin.y += _calloutView.shadowOffset.height+self.calloutOffset.y;
    callOutFrame.origin.x += _calloutView.shadowOffset.width+self.calloutOffset.x;
}

- (BOOL)isSelected{
    return [super isSelected];
}
#if MAMAPKIT
-(void)setSelected:(BOOL)selected{
    
    [self setSelected:selected animated:YES];
    
}
#endif
- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    if (canCallOutView&&selected!=self.selected) {
        
        [self show:selected animate:animated];
    }
    
    [super setSelected:selected animated:animated];
    
}
- (void)willMoveToSuperview:(UIView *)newSuperview{
    if (newSuperview==nil) {
        [self setSelected:NO animated:NO];
        mapview = nil;
        container = nil;
//        [(NSObject*)self.annotation removeObserver:self forKeyPath:@"coordinate" context:nil
//         ];
    }else{
//         [(NSObject*)self.annotation addObserver:self forKeyPath:@"coordinate" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
   
}

- (void)setAnnotation:(id<MKAnnotation>)annotation{
    if (_annotation!=annotation) {
        [(NSObject*)_annotation removeObserver:self forKeyPath:@"coordinate" context:nil
         ];
        [(NSObject *)_annotation release];
        if (annotation) {
            [(NSObject*)annotation addObserver:self forKeyPath:@"coordinate" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        }
        _annotation = (id)[(NSObject*)annotation retain];
    }
    
    [super setAnnotation:annotation];
    
}

- (void)didMoveToSuperview{

    if (_remark&&[_remark.text length]) {
        
        CGRect frame = CGRectZero;
        frame.size = [self.image size];
        
        CGRect rect= [_remark textRectForBounds:CGRectMakeBound(100, 99999) limitedToNumberOfLines:_remark.numberOfLines];
        rect.origin.x = frame.size.width;
        rect.origin.y = (frame.size.height-rect.size.height)/2;
        [_remark setFrame:rect];
    }else{
        _remark.frame = CGRectZero;
    }
}

- (void)show:(BOOL)isShow animate:(BOOL)animate{

    UIView *view = self;
    while (view) {
        
        
        #if TEST
        logMethodForClass(view.superclass);
        #endif
        
#if  (MAMAPKIT | BMKMAPKIT)
        if ([view isKindOfClass:[UIScrollView class]]) {
            container = view;
        }
#else
        Class cls = NSClassFromString(@"MKAnnotationContainerView");
        if ([view isKindOfClass:cls]) {
            container = view;
        }
#endif
        if ([view isKindOfClass:[MSOMapView class]]) {
            mapview  = (MSOMapView*)view;
            
            break;
        }
        view = view.superview;
    }

    
#if  MAMAPKIT
    container = self.superview;
    
    mapview = (GGMapView*)container.superview;
#else
//    container = self.superview;
//    if (container==nil) {
//        container = _calloutView.superview;
//    }
//    mapview = (GGMapView*)container.superview.superview.superview;
#endif
    
    //mamap 2.0.6
    if (container==nil||mapview==nil) {
        return;
    }
#if  (MAMAPKIT | BMKMAPKIT)
    if (!isShow) {
        [container removeObserver:self forKeyPath:@"contentOffset" context:nil];
    }else{
        [container addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
#else
    if (!isShow) {
        [mapview removeObserver:self forKeyPath:@"zoomLevel" context:nil];
       
    }else{
        [mapview addObserver:self forKeyPath:@"zoomLevel" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
#endif
//    NSLog(@"%@",container.subviews);
    if (!isShow) {
        if (_calloutView.superview) {
            [_calloutView removeFromSuperview];
           
            if ([delegate respondsToSelector:@selector(mapPointView:)]) {
                _calloutView.gridCell = nil;
            }
        }
        return;
    }
    
    if (!_calloutView.superview) {
        [container addSubview:_calloutView];
    }
    [container bringSubviewToFront:_calloutView];
    
    if ([delegate respondsToSelector:@selector(mapPointView:)]) {
        UIView *cell = [delegate mapPointView:self];
        if (cell) {
            [self setCalloutView:cell custom:_calloutCustom];
            if ([delegate respondsToSelector:@selector(mapPointViewLayout:)]) {
                [delegate mapPointViewLayout:self ];
            }
            [self resetCalloutViewFrame:cell];
        }
        
    }
    
   
    CGPoint poitContainer =[mapview convertCoordinate:[self.annotation coordinate] toPointToView:container];
    
    CGRect rect = callOutFrame;
    poitContainer.x -=rect.size.width/2-self.centerOffset.x;
    poitContainer.y -=rect.size.height+self.bounds.size.height/2-rect.origin.y-self.centerOffset.y;
    rect.origin = poitContainer;
//#if (__ON__ == __HM_DEVELOPMENT__)
//    CC( @"MAP",@">>>>[%.1f,%.1f]>>[%.1f,%.1f]",rect.origin.x,rect.origin.y,self.frame.origin.x,self.frame.origin.y);
//#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    [_calloutView setFrame:rect];
    
    if (animate) {
        _calloutView.alpha=0.f;
        [UIView animateWithDuration:.25f animations:^{
            _calloutView.alpha=1.f;
        }];
    }
    
}
- (void)bringToFront{
    [_calloutView.superview bringSubviewToFront:_calloutView];
}
- (void)updateCalloutView{
    if (canCallOutView&&self.isSelected) {
        
        CGRect rect = callOutFrame;
        rect.origin =self.frame.origin;
        rect.origin.x -=rect.size.width/2-callOutFrame.origin.x;
        rect.origin.y -=rect.size.height+self.bounds.size.height/2-callOutFrame.origin.y;
        rect.origin.x +=self.frame.size.width/2;
        rect.origin.y +=self.frame.size.height/2;
        [_calloutView setFrame:rect];
        if (_calloutView.superview==nil) {
            [self show:YES animate:NO];
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(bringToFront) object:self];
        [self performSelector:@selector(bringToFront) withObject:self afterDelay:.02];
        
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath is:@"contentOffset"]||[keyPath is:@"zoomLevel"]||[keyPath is:@"coordinate"]) {
        if (self.dragState == MKAnnotationViewDragStateDragging || self.dragState == MKAnnotationViewDragStateStarting) {
            return;
        }
        
        if ([keyPath is:@"coordinate"]) {
            
            if (canCallOutView&&self.isSelected){
                [self show:NO animate:NO];
            }
            if ([delegate respondsToSelector:@selector(annotationViewReload:)]) {
                [delegate annotationViewReload:self];
            }
        }
        if (canCallOutView&&self.isSelected){
            [self updateCalloutView];
            
        }
    }
}
@end


#pragma mark -
#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395

static NSInteger zoomLevelMIN =  3;
static NSInteger zoomLevelMAX =  17;


@interface GGMapView ()<MKMapViewDelegate,HMPointAnnotationViewDelegate>

@property (assign, nonatomic)   NSInteger tmpZoomLevel;

@end


@implementation GGMapView{
    NSInteger _tmpZoomLevel;
}

@synthesize zoomLevel=_zoomLevel,tmpZoomLevel=_tmpZoomLevel;
@synthesize centerLocationFirst;

DEF_SINGLETON(GGMapView)

DEF_SIGNAL2(LOADING,GGMapView)
DEF_SIGNAL2(LOADED,GGMapView)
DEF_SIGNAL2(ZOOMIN ,GGMapView)
DEF_SIGNAL2(ZOOMOUT ,GGMapView)

DEF_SIGNAL2(REGIONWILLCHANGE ,GGMapView)
DEF_SIGNAL2(REGIONDIDCHANGE ,GGMapView)

DEF_SIGNAL2(USERLOCATIONSUCCESS ,GGMapView)
DEF_SIGNAL2(USERLOCATIONFAIL ,GGMapView)

DEF_SIGNAL2(VIEWFORANNOTATION ,GGMapView)
DEF_SIGNAL2(VIEWFORCALLOUT ,GGMapView)
DEF_SIGNAL2(VIEWFORCALLOUTRESET ,GGMapView)
DEF_SIGNAL2(ANNOVIEWRELOAD, GGMapView)
DEF_SIGNAL2(SELECTANNOTATIONVIEW ,GGMapView)
DEF_SIGNAL2(DESELECTANNOTATIONVIEW ,GGMapView)

DEF_SIGNAL2(VIEWFOROVERLAY ,GGMapView)

DEF_SIGNAL2(CHANGEDRAGSTATE ,GGMapView)

DEF_NOTIFICATION(ZoomLevelChanged)


-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;
    }
    return self;
}
- (id)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
    }
    return self;
}

+ (instancetype)spawnInView:(UIView*)view{
    
    MSOMapView *map = [[[MSOMapView alloc]initWithFrame:view.bounds]autorelease];
    dispatch_async(dispatch_get_main_queue(), ^{
        [view insertSubview:map atIndex:0];
        [map sendSignal:[GGMapView LOADING]];
        map.alpha = .0f;
        map.userInteractionEnabled = NO;
        [UIView animateWithDuration:.4 delay:.3 options:UIViewAnimationOptionCurveLinear animations:^{
            map.alpha = 1.0f;
        } completion:^(BOOL finished) {
            map.userInteractionEnabled = YES;
        }];
    });
    
    return map;
}

+ (void)spawnInView:(UIView*)view ok:(void(^)(GGMapView*))ok{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        MSOMapView *map = [[[MSOMapView alloc]initWithFrame:view.bounds]autorelease];
        [view insertSubview:map atIndex:0];
        [map sendSignal:[GGMapView LOADING]];
        map.alpha = .0f;
        map.userInteractionEnabled = NO;
        [UIView animateWithDuration:.4 delay:.3 options:UIViewAnimationOptionCurveLinear animations:^{
            map.alpha = 1.0f;
        } completion:^(BOOL finished) {
            map.userInteractionEnabled = YES;
        }];
        if (ok) {
            ok(map);
        }
    });
}

#pragma mark -
#pragma mark Map conversion methods

- (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

- (double)latitudeToPixelSpaceY:(double)latitude
{
    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}

- (double)pixelSpaceXToLongitude:(double)pixelX
{
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

- (double)pixelSpaceYToLatitude:(double)pixelY
{
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}

#pragma mark -
#pragma mark Helper methods


- (MKCoordinateSpan)coordinateSpanWithMapView:(MKMapView *)mapView
                             centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                 andZoomLevel:(NSUInteger)zoomLevel
{
    // convert center coordiate to pixel space
    double centerPixelX = [self longitudeToPixelSpaceX:centerCoordinate.longitude];
    double centerPixelY = [self latitudeToPixelSpaceY:centerCoordinate.latitude];
    
    // determine the scale value from the zoom level
    NSInteger zoomExponent = 20 - zoomLevel;
    double zoomScale = pow(2, zoomExponent);
    
    // scale the map’s size in pixel space
    CGSize mapSizeInPixels = mapView.bounds.size;
    double scaledMapWidth = mapSizeInPixels.width * zoomScale;
    double scaledMapHeight = mapSizeInPixels.height * zoomScale;
    
    // figure out the position of the top-left pixel
    double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
    double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    
    // find delta between left and right longitudes
    CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
    CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
    CLLocationDegrees longitudeDelta = maxLng - minLng;
    
    // find delta between top and bottom latitudes
    CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
    CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
    
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
}

#pragma mark -
- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    if (self.superview) {
        CLLocationCoordinate2D coor=kCLLocationCoordinate2DInvalid;
        NSString *coors = [[ NSUserDefaults standardUserDefaults] objectForKey:@"LastUserCoordinate"];
        if (coors.length) {
            NSArray *arr = [coors componentsSeparatedByString:@","];
            if (arr.count==3) {
                coor.latitude = [[arr objectAtIndex:0]floatValue];
                coor.longitude = [[arr objectAtIndex:1]floatValue];
                NSInteger _zoomlevel = [[arr objectAtIndex:2]integerValue];
                
                if (CLLocationCoordinate2DIsValid(coor)) {
                    [UIView animateWithDuration:.05 animations:^{
                        
                    } completion:^(BOOL finished) {
                        [self setCenterCoordinate:coor zoomLevel:_zoomlevel animated:NO];
                        [UIView animateWithDuration:.1 animations:^{
                            
                        } completion:^(BOOL finished) {
                            [self sendSignal:[GGMapView LOADED]];
                        }];
                    }];
                }
            }
        }else{
            
            if (CLLocationCoordinate2DIsValid(self.centerCoordinate)) {
                [self setCenterCoordinate:self.centerCoordinate zoomLevel:self.zoomLevel animated:NO];
            }
            
            [UIView animateWithDuration:.1 animations:^{
                
            } completion:^(BOOL finished) {
                [self sendSignal:[GGMapView LOADED]];
            }];
        }
    }
}

-(void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    
    CLLocationCoordinate2D coor=kCLLocationCoordinate2DInvalid;
    if (newSuperview==nil) {

        if (CLLocationCoordinate2DIsValid(self.userLocation.location.coordinate)) {
            coor = self.userLocation.location.coordinate;
        }else{
            coor = self.centerCoordinate;
        }
        
        if (CLLocationCoordinateIsValid(coor)) {
            
            NSString *coors = [NSString stringWithFormat:@"%f,%f,%ld",self.centerCoordinate.latitude,self.centerCoordinate.longitude,(long)self.zoomLevel];
            [[NSUserDefaults standardUserDefaults] setObject:coors forKey:@"LastUserCoordinate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

#pragma mark Public methods
-(NSInteger)tmpZoomLevel{
    _tmpZoomLevel =20-round(log2(self.region.span.longitudeDelta * MERCATOR_RADIUS * M_PI / (180.0 * self.bounds.size.width)));

    return _tmpZoomLevel;
}

-(void)setZoomLevel:(NSInteger)zoomLevel animated:(BOOL)animated{
    
//    if (zoomLevel==self.tmpZoomLevel) {
//        return;
//    }
//    self.zoomLevel = self.tmpZoomLevel;
//#if (__ON__ == __HM_DEVELOPMENT__)
//    CC( @"MAP",@"zoomLevel:%d to %d",_zoomLevel,zoomLevel);
//#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(safeSetZoomLevel:) object:@{@"zoomLevel": [NSNumber numberWithInteger:zoomLevel],@"animated": [NSNumber numberWithBool:animated]}];
    
    [self performSelector:@selector(safeSetZoomLevel:)
               withObject:@{@"zoomLevel": [NSNumber numberWithInteger:zoomLevel],@"animated": [NSNumber numberWithBool:animated]}
               afterDelay:.1f];
}

-(void)safeSetZoomLevel:(NSDictionary*)p{
    
    int zoomLevel = [[p valueForKey:@"zoomLevel"] intValue];
    BOOL animated = [[p valueForKey:@"animated"] boolValue];
    
    [self setCenterCoordinate:self.centerCoordinate zoomLevel:zoomLevel animated:animated];
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated
{
    // clamp large numbers to 28
//    if (zoomLevel<zoomLevelMIN) {
//        zoomLevel=zoomLevelMIN;
//    }
    zoomLevel = MAX(zoomLevel, zoomLevelMIN);
    zoomLevel = MIN(zoomLevel, zoomLevelMAX);
    self.zoomLevel = zoomLevel;
    
    // use the zoom level to compute the region
    MKCoordinateSpan span = [self coordinateSpanWithMapView:self centerCoordinate:centerCoordinate andZoomLevel:zoomLevel];
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    
    // set the region like normal
    [self setRegion:region animated:animated];
}

- (BOOL)zoomIn{
    if ((self.tmpZoomLevel>=zoomLevelMAX) && (self.zoomLevel==zoomLevelMAX)) {
        return NO;
    }
    [self setZoomLevel:_tmpZoomLevel+1 animated:YES];
    return YES;
}
- (BOOL)zoomOut{
    if ((self.tmpZoomLevel<=zoomLevelMIN) && (self.zoomLevel==zoomLevelMIN)) {
        return NO;
    }
    [self setZoomLevel:_tmpZoomLevel-1 animated:YES];
    return YES;
}

+(void)setZoomLevelMax:(NSInteger)max{
    zoomLevelMAX = max;
}
+(void)setZoomLevelMin:(NSInteger)min{
    zoomLevelMIN = min;
}


-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState{
    
    [self sendSignal:GGMapView.CHANGEDRAGSTATE withObject:@{@"new":[NSNumber numberWithInteger:newState],@"old":[NSNumber numberWithInteger:oldState]} from:view];
    
    if ([view.annotation isKindOfClass:[MKPointAnnotation class]]) {
        
    }
    
    
}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    //    BeeLog(@"didAddAnnotationViews");
}

-(void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews{
    //    BeeLog(@"didAddOverlayViews");
}
-(void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated{
    //    BeeLog(@"didChangeUserTrackingMode");
//    [self sendSignal:GGMapView.DESELECTANNOTATIONVIEW withObject:nil from:mapView];
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    //    [view setSelected:NO];
    [self sendSignal:GGMapView.DESELECTANNOTATIONVIEW withObject:view from:mapView];
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    //    BeeLog(@"%d",    view.selected);
    [self sendSignal:GGMapView.SELECTANNOTATIONVIEW withObject:view from:mapView];
    //    NSLog(@"");
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    self.zoomLevel = self.tmpZoomLevel;
    [self sendSignal:GGMapView.REGIONDIDCHANGE withObject:[NSNumber numberWithBool:animated] from:mapView];
    
}

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    self.zoomLevel = self.tmpZoomLevel;
    [self sendSignal:GGMapView.REGIONWILLCHANGE withObject:[NSNumber numberWithBool:animated] from:mapView];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    userLocation.title = @"当前位置";
    [self sendSignal:GGMapView.USERLOCATIONSUCCESS withObject:userLocation from:mapView];
    
    if (self.centerLocationFirst) {
        self.centerLocationFirst = NO;
        [self setCenterCoordinate:userLocation.location.coordinate zoomLevel:(self.zoomLevel<14?14:self.zoomLevel) animated:YES];
    }
    
}

-(void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error{
    
    [self sendSignal:GGMapView.USERLOCATIONFAIL withObject:error from:mapView];
    
}

#pragma mark overlay
- (UIView *)mapPointView:(MKAnnotationView *)view{
    HMSignal *signal =[self sendSignal:GGMapView.VIEWFORCALLOUT withObject:view];
    if ([signal.returnValue isKindOfClass:[UIView class]]) {
        return (id)signal.returnValue;
    }
    return nil;
}

- (void)mapPointViewLayout:(MKAnnotationView *)view{
    [self sendSignal:GGMapView.VIEWFORCALLOUTRESET withObject:view];
}


- (void)annotationViewReload:(MKAnnotationView *)view{
    [self sendSignal:GGMapView.ANNOVIEWRELOAD withObject:view];
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {

        return nil;
    }
    
    NSString *viewIdentifier = @"MKAnnotationView";
    if ([annotation isKindOfClass:[HMPointAnnotation class]]) {
        HMPointAnnotation *ann = (HMPointAnnotation*)annotation;
        if ([ann.tagString length]) {
            viewIdentifier = ann.tagString;
        }
        
        HMPointAnnotationView *anView = [[[HMPointAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:viewIdentifier]autorelease];
        anView.delegate = self;
        anView.tagString = viewIdentifier;
        anView.canShowCallout = YES;
        [anView setCalloutViewUserInterface:NO];
        
        HMSignal *signal =[self sendSignal:GGMapView.VIEWFORANNOTATION withObject:anView from:mapView];
        
        if ([signal.returnValue isKindOfClass:[MKAnnotationView class]]) {
            anView = (id)signal.returnValue;
        }
        return anView;
    }else{
        HMSignal *signal =[self sendSignal:GGMapView.VIEWFORANNOTATION withObject:annotation from:mapView];
        if (signal.returnValue) {
            return (id)signal.returnValue;
        }
    }
    
    return nil;
    
}

//-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
//    
//    if ([overlay isKindOfClass:[MKPolyline class]])
//    {
//        MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
//        polylineView.strokeColor = [UIColor blueColor];
//        polylineView.lineWidth = 3.f;
//        polylineView.lineCap = kCGLineCapRound;
//        [self sendSignal:GGMapView.VIEWFOROVERLAY withObject:polylineView from:mapView];
//        
//        return [polylineView autorelease];
//    }else if ([overlay isKindOfClass:[MKCircle class]])
//    {
//        MKCircleView *cirecleView = [[MKCircleView alloc] initWithCircle:overlay];
//        cirecleView.strokeColor = [UIColor blueColor];
//        cirecleView.lineWidth = 3.f;
//        cirecleView.lineCap = kCGLineCapRound;
//        [self sendSignal:GGMapView.VIEWFOROVERLAY withObject:cirecleView from:mapView];
//        
//        return [cirecleView autorelease];
//    }else if ([overlay isKindOfClass:[MKPolygon class]])
//    {
//        MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:overlay];
//        polygonView.strokeColor = [UIColor blueColor];
//        polygonView.lineWidth = 3.f;
//        polygonView.lineCap = kCGLineCapRound;
//        [self sendSignal:GGMapView.VIEWFOROVERLAY withObject:polygonView from:mapView];
//        
//        return [polygonView autorelease];
//    }
//    else {
//        HMSignal *signal = [self sendSignal:GGMapView.VIEWFOROVERLAY withObject:overlay from:mapView];
//        if (signal.returnValue) {
//            return (id)signal.returnValue;
//        }
//    }
//    
//    return nil;
//}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer *renderer=[[[MKPolylineRenderer alloc]initWithOverlay:overlay] autorelease];
        renderer.strokeColor=[[UIColor redColor]colorWithAlphaComponent:0.5];
        renderer.lineWidth=3.0;
        renderer.lineCap = kCGLineCapRound;
        HMSignal *signal = [self sendSignal:GGMapView.VIEWFOROVERLAY withObject:renderer from:mapView];
        
        return signal.returnValue?signal.returnValue:renderer;

    }
    if([overlay isKindOfClass:[MKCircle class]])
    {
        MKCircleRenderer *circle = [[[MKCircleRenderer alloc]initWithOverlay:overlay] autorelease];
        circle.lineWidth = 3.0;
        circle.strokeColor = [UIColor blueColor];
        circle.fillColor = [[UIColor blueColor]colorWithAlphaComponent:0.5];
        circle.lineCap = kCGLineCapRound;
        HMSignal *signal = [self sendSignal:GGMapView.VIEWFOROVERLAY withObject:circle from:mapView];
        
        return signal.returnValue?signal.returnValue:circle;
    }
    if([overlay isKindOfClass:[MKPolygon class]])
    {
        MKPolygonRenderer *polygon = [[[MKPolygonRenderer alloc]initWithOverlay:overlay] autorelease];
        polygon.lineWidth = 3.0;
        polygon.strokeColor = [UIColor yellowColor];
        polygon.fillColor = [[UIColor yellowColor]colorWithAlphaComponent:0.5];
        polygon.lineCap = kCGLineCapRound;
       HMSignal *signal = [self sendSignal:GGMapView.VIEWFOROVERLAY withObject:polygon from:mapView];
        
        return signal.returnValue?signal.returnValue:polygon;
    }else {
        HMSignal *signal = [self sendSignal:GGMapView.VIEWFOROVERLAY withObject:overlay from:mapView];
        if (signal.returnValue) {
            return (id)signal.returnValue;
        }
    }
    return nil;
}

@end

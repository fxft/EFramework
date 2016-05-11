//
//  GGMapView.h
//  LuckyStar
//
//  Created by chen Eric on 13-9-21.
//  Copyright (c) 2013年 Eric. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "HMMacros.h"
#import "HMFoundation.h"
#import "HMUIView.h"

/**
 *  自定义的地图📍
 */
@interface HMPointAnnotation : MKPointAnnotation
@property (copy, nonatomic)     NSString *name;
@property (copy, nonatomic)     NSString *ID;//可用于poi点ID
@property (copy, nonatomic)     NSString *iconId;//可用于图片显示
@property (nonatomic,HM_STRONG)    NSIndexPath *indexPath;//可用于对poi点进行分组
@property (nonatomic,copy)      NSString *tagString;
@property (nonatomic)      NSInteger tag;
///路线相对正北的角度
@property (nonatomic) CGFloat degree;
@property (nonatomic,HM_STRONG)    id data;//可用于用户数据

@end

/**
 *  默认📍的弹出框
 */
@interface HMPinCalloutView : HMUIView
@property (nonatomic,HM_STRONG)    UIView *     gridCell;
@property (nonatomic, readonly) CGSize  minSize;
@property (nonatomic) CGRect            contentRect;//如果设置成self.bounds且不为zero 则忽略style背景
@property (nonatomic,getter = isSelected)   BOOL selected;
@property (nonatomic) CGSize shadowOffset;
@property (nonatomic,HM_STRONG) UIColor *solidFillColor;//default RGBA(255, 255, 255, .7);
@property (nonatomic,HM_STRONG) UIColor *shadowColor;//default RGBA(114, 156, 202, .7);
@property (nonatomic,HM_STRONG) UIColor *borderColor;//default RGBA(100, 136, 182, .7);

@end

@protocol HMPointAnnotationViewDelegate <NSObject>

- (UIView *)mapPointView:(MKAnnotationView*)view;
- (void)mapPointViewLayout:(MKAnnotationView *)view;
- (void)annotationViewReload:(MKAnnotationView*)view;

@end

@interface HMPointAnnotationView : MKAnnotationView
@property (nonatomic,copy)                  NSString *tagString;
@property (nonatomic,HM_STRONG,readonly)       UILabel *remark;
@property (nonatomic)  BOOL            calloutCustom;//设置为YES时弹出框的
@property (HM_WEAK, nonatomic)               id<HMPointAnnotationViewDelegate>  delegate;
/**
 *  弹出框载体，支持边框属性定制；支持calloutOffset，支持canShowCallout
 */
@property (nonatomic,HM_STRONG,readonly)    HMPinCalloutView *calloutView;

- (UIView *)calloutViewCell;
- (void)setCalloutView:(UIView *)grid custom:(BOOL)yes;
- (void)setCalloutViewUserInterface:(BOOL)is;

@end

#pragma mark -
#undef ON_MapView
#define ON_MapView( signal ) ON_SIGNAL2(GGMapView, signal)

@protocol ON_MapView_handle <NSObject>

ON_MapView( signal );

@end

/**
 *  苹果地图，事件处理可以在ON_MapView()中获取到
 */
@interface GGMapView : MKMapView

@property (nonatomic) NSInteger zoomLevel;
@property (nonatomic) BOOL centerLocationFirst;

AS_SINGLETON(GGMapView)

AS_SIGNAL(LOADING)/*地图正在加载*/
AS_SIGNAL(LOADED)/*地图已经加载*/
AS_SIGNAL(ZOOMIN)/*地图缩小*/
AS_SIGNAL(ZOOMOUT)/*地图放大*/

AS_SIGNAL(REGIONWILLCHANGE)/*地图将要移动，object（animated*/
AS_SIGNAL(REGIONDIDCHANGE)/*地图结束移动，object（animated）*/

AS_SIGNAL(USERLOCATIONSUCCESS)/*定位成功，object（MKUserLocation）*/
AS_SIGNAL(USERLOCATIONFAIL)/*定位失败，object（NSError）*/

AS_SIGNAL(VIEWFORANNOTATION)/*antation视图，objct（HMPointAnnotationView）*/
AS_SIGNAL(VIEWFORCALLOUT)/*antation弹出视图，objct（MKAnnotationView）*/
AS_SIGNAL(VIEWFORCALLOUTRESET)/*callout view 被添加到视图后触发*/
AS_SIGNAL(ANNOVIEWRELOAD)/*antation视图被刷新*/
AS_SIGNAL(SELECTANNOTATIONVIEW)/*antation选中，objct（MKAnnotationView）*/
AS_SIGNAL(DESELECTANNOTATIONVIEW)/*antation不选中，objct（MKAnnotationView）*/

AS_SIGNAL(VIEWFOROVERLAY)/*overlay视图，object（MKOverlayRenderer）可以return（MKOverlayRenderer）*/

AS_SIGNAL(CHANGEDRAGSTATE)/*地图拖动状态,object(@"new"和@"old"键值对)*/

AS_NOTIFICATION(ZoomLevelChanged)/*地图等级变化，object(@"new"和@"old"键值对)*/

+ (instancetype)spawnInView:(UIView*)view;//同步添加地图到view
+ (void)spawnInView:(UIView*)view ok:(void(^)(GGMapView*))ok;//异步添加地图到view
//建议最小3级
+(void)setZoomLevelMin:(NSInteger)min;
//建议最大17级
+(void)setZoomLevelMax:(NSInteger)max;

-(void)setZoomLevel:(NSInteger)zoomLevel animated:(BOOL)animated;
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;
//3-17级,放大－级
- (BOOL)zoomIn;
//3-17级,缩小一级
- (BOOL)zoomOut;

@end

#define MSOMapView          GGMapView
#define MSOMapViewDelegate  MKMapViewDelegate

#define MSOPointAnnotation  HMPointAnnotation
#define MSOAnnotationView   HMPointAnnotationView

#define MSOOverlay          MKOverlay
#define MSOOverlayView      MKOverlayPathRenderer
#define MSOPolyline         MKPolyline
#define MSOPolylineView     MKPolylineRenderer
#define MSOCircle           MKCircle
#define MSOCircleView       MKCircleRenderer
#define MSOPolygon          MKPolygon
#define MSOPolygonView      MKPolygonRenderer

#define MSOAnnotationViewDragState  MKAnnotationViewDragState

#define MSOSearchTool       GDMASearchTool
#define MSOSearch            GDMASearch
#define MSOSearchDelegate     MASearchDelegate
#define MSOPoiSearchOption   MAPoiSearchOption
#define MSOReverseGeocodingSearchOption  MAReverseGeocodingSearchOption
#define MSOReverseGeocodingInfo  MAReverseGeocodingInfo
#define MSOReverseGeocodingSearchResult  MAReverseGeocodingSearchResult
#define MSOPoiSearchResult   MAPoiSearchResult
#define MSOPOI               MAPOI
#define MSORGCSearchOption   MARGCSearchOption
#define MSORGCSearchResult   MARGCSearchResult
#define MSORGCItem           MARGCItem
//#define MSOAddrInfo         MKAddrInfo


#define MSOUserLocation     MKUserLocation

//enum
#define MSOMapRect           MKMapRect
#define MSOMapPoint          MKMapPoint

//method
#define MSOMapPointForCoordinate MKMapPointForCoordinate
#define MSOMapRectMake           MKMapRectMake

//protol
#define MSOAnnotation           MKAnnotation

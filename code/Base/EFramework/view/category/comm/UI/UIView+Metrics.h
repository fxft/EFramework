
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import "HMMacros.h"

#pragma mark -

#undef LOGFRAME
#define LOGFRAME(_view) CC(@"FRAME",@"x[%.2f] y[%.2f] w[%.2f] h[%.2f]",_view.frame.origin.x,_view.frame.origin.y,_view.frame.size.width,_view.frame.size.height)
#undef LOGFRAMEFormat
#define LOGFRAMEFormat(frame) [NSString stringWithFormat:@"x[%.2f] y[%.2f] w[%.2f] h[%.2f]",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height]

#undef LOGSIZE
#define LOGSIZE(_size) CC(@"FRAME",@"w[%.2f] h[%.2f]",_size.width,_size.height)
#undef LOGSIZEFormat
#define LOGSIZEFormat(_size) [NSString stringWithFormat:@"w[%.2f] h[%.2f]",_size.width,_size.height]

#undef LOGORIGIN
#define LOGORIGIN(_origin) CC(@"FRAME",@"x[%.2f] y[%.2f]",_origin.x,_origin.y)
#undef LOGORIGINFormat
#define LOGORIGINFormat(_origin) [NSString stringWithFormat:@"x[%.2f] y[%.2f]",_origin.x,_origin.y]

#undef LOGCOOR
#define LOGCOOR(_coor) CC(@"FRAME",@"lat[%.2f] lng[%.2f]",_coor.latitude,_coor.longitude)
#undef LOGCOORFormat
#define LOGCOORFormat(_coor) [NSString stringWithFormat:@"lat[%.2f] lng[%.2f]",_coor.latitude,_coor.longitude]

#define degrees2Radians(degrees) ((degrees) * M_PI / 180)//角度转弧度
#define radians2Degrees(radians) ((radians) * 180 / M_PI)//弧度转角度

/**
 *  视图大小、位置快捷属性获取、运算、变更
 */

@interface UIView(Metrics)

@property (assign, nonatomic) CGFloat	top;
@property (assign, nonatomic) CGFloat	bottom;
@property (assign, nonatomic) CGFloat	left;
@property (assign, nonatomic) CGFloat	right;

@property (assign, nonatomic) CGPoint	offset;
@property (assign, nonatomic) CGPoint	position;

@property (assign, nonatomic) CGFloat	x;
@property (assign, nonatomic) CGFloat	y;
@property (assign, nonatomic) CGFloat	w;
@property (assign, nonatomic) CGFloat	h;

@property (assign, nonatomic) CGFloat	width;
@property (assign, nonatomic) CGFloat	height;
@property (assign, nonatomic) CGSize	size;

@property (assign, nonatomic) CGFloat	centerX;
@property (assign, nonatomic) CGFloat	centerY;
@property (assign, nonatomic) CGPoint	origin;
@property (readonly, nonatomic) CGPoint	boundsCenter;
@property (readonly, nonatomic) CGRect  frameInWindow;

#pragma mark -
/**
 *  对 autolayout的支持，如果有限制 宽、高 需要进行计算
 *
 *   size 需要被重新计算宽高的大小
 *
 *   return 经过限制条件计算后的size
 */
- (CGSize)autolayoutForSize:(CGSize)size;

@end

HM_EXTERN const CGSize	CGSizeAuto;
HM_EXTERN const CGRect	CGRectAuto;


#pragma mark -

HM_EXTERN CGSize	AspectFitSizeByWidth( CGSize size, CGFloat width );
HM_EXTERN CGSize	AspectFitSizeByHeight( CGSize size, CGFloat height );

HM_EXTERN CGSize	AspectFillSizeByWidth( CGSize size, CGFloat width );
HM_EXTERN CGSize	AspectFillSizeByHeight( CGSize size, CGFloat height );

HM_EXTERN CGSize	AspectFitSize( CGSize size, CGSize bound );
HM_EXTERN CGRect	AspectFitRect( CGRect rect, CGRect bound );

HM_EXTERN CGSize	AspectFillSize( CGSize size, CGSize bound );
HM_EXTERN CGRect	AspectFillRect( CGRect rect, CGRect bound );

HM_EXTERN CGRect	CGRectFromString( NSString * str );

HM_EXTERN CGPoint	CGPointZeroNan( CGPoint point );
HM_EXTERN CGSize	CGSizeZeroNan( CGSize size );
HM_EXTERN CGRect	CGRectZeroNan( CGRect rect );

HM_EXTERN CGRect	CGRectAlignX( CGRect rect1, CGRect rect2 );				// rect1向rect2的X轴中心点对齐
HM_EXTERN CGRect	CGRectAlignY( CGRect rect1, CGRect rect2 );				// rect1向rect2的Y轴中心点对齐
HM_EXTERN CGRect	CGRectAlignCenter( CGRect rect1, CGRect rect2 );		// rect1向rect2的中心点对齐

HM_EXTERN CGRect	CGRectAlignTop( CGRect rect1, CGRect rect2 );			// 右边缘对齐
HM_EXTERN CGRect	CGRectAlignBottom( CGRect rect1, CGRect rect2 );		// 下边缘对齐
HM_EXTERN CGRect	CGRectAlignLeft( CGRect rect1, CGRect rect2 );			// 左边缘对齐
HM_EXTERN CGRect	CGRectAlignRight( CGRect rect1, CGRect rect2 );			// 上边缘对齐

HM_EXTERN CGRect	CGRectAlignLeftTop( CGRect rect1, CGRect rect2 );		// 右边缘对齐
HM_EXTERN CGRect	CGRectAlignLeftBottom( CGRect rect1, CGRect rect2 );	// 下边缘对齐
HM_EXTERN CGRect	CGRectAlignRightTop( CGRect rect1, CGRect rect2 );		// 右边缘对齐
HM_EXTERN CGRect	CGRectAlignRightBottom( CGRect rect1, CGRect rect2 );	// 下边缘对齐

HM_EXTERN CGRect	CGRectCloseToTop( CGRect rect1, CGRect rect2 );			// 与上边缘靠近
HM_EXTERN CGRect	CGRectCloseToBottom( CGRect rect1, CGRect rect2 );		// 与下边缘靠近
HM_EXTERN CGRect	CGRectCloseToLeft( CGRect rect1, CGRect rect2 );		// 与左边缘靠近
HM_EXTERN CGRect	CGRectCloseToRight( CGRect rect1, CGRect rect2 );		// 与右边缘靠近

HM_EXTERN CGRect	CGRectReduceWidth( CGRect rect, CGFloat pixels );		// 变宽
HM_EXTERN CGRect	CGRectReduceHeight( CGRect rect, CGFloat pixels );		// 变高

HM_EXTERN CGRect	CGRectMoveCenter( CGRect rect1, CGPoint offset );		// 移动中心点
HM_EXTERN CGRect	CGRectMakeBound( CGFloat w, CGFloat h );

HM_EXTERN CGRect	CGSizeMakeBound( CGSize size );
HM_EXTERN CGRect	CGRectToBound( CGRect frame );

HM_EXTERN CGSize	CGRectGetDistance( CGRect rect1, CGRect rect2 );		// 获取rect1与rect2的`dx`和`dy`

HM_EXTERN CGRect CGRectContract(CGRect rect, CGFloat dx, CGFloat dy);
HM_EXTERN CGRect CGRectShift(CGRect rect, CGFloat dx, CGFloat dy);
HM_EXTERN CGRect CGRectEdgeInsets(CGRect rect, UIEdgeInsets insets);//inset with left right top bottom
HM_EXTERN CGRect CGRectMakeScale( CGRect rect ,CGFloat scale);
HM_EXTERN CGSize CGSizeMakeScale( CGSize size ,CGFloat scale);

HM_EXTERN UIEdgeInsets UIEdgeInsetsUnion(UIEdgeInsets insets1, UIEdgeInsets insets2);
HM_EXTERN UIEdgeInsets UIEdgeInsetsAll(CGFloat inset);
HM_EXTERN UIEdgeInsets UIEdgeInsetsVerAndLR(CGFloat ver,CGFloat left ,CGFloat right);
HM_EXTERN UIEdgeInsets UIEdgeInsetsTBAndHor(CGFloat top ,CGFloat bottom,CGFloat hor );
HM_EXTERN UIEdgeInsets UIEdgeInsetsVerAndHor(CGFloat ver,CGFloat hor );

//top left bottom right 不设置的请填写 CGFLOAT_MIN
HM_EXTERN UIEdgeInsets UIEdgeInsetsContainsCenterTopRight(CGRect contain, CGSize size, CGFloat top, CGFloat right);
HM_EXTERN UIEdgeInsets UIEdgeInsetsContainsCenterTopLeft(CGRect contain, CGSize size, CGFloat top, CGFloat left);
HM_EXTERN UIEdgeInsets UIEdgeInsetsContainsCenterBottomLeft(CGRect contain, CGSize size, CGFloat bottom, CGFloat left);
HM_EXTERN UIEdgeInsets UIEdgeInsetsContainsCenterBottomRight(CGRect contain, CGSize size, CGFloat bottom, CGFloat right);
HM_EXTERN UIEdgeInsets UIEdgeInsetsContainsCenter(CGRect contain, CGSize size);

//在一些存在.5像素问题的布局中图像和文字会模糊问题
HM_EXTERN CGRect CGRectNormalize(CGRect rect);
HM_EXTERN CGSize CGSizeNormalize(CGSize size);
HM_EXTERN CGPoint CGPointNormalize(CGPoint point);

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

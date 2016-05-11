
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import "UIView+Metrics.h"


const CGSize CGSizeAuto = { 0.0f, 0.0f };
const CGRect CGRectAuto = { { 0.0f, 0.0f }, { 0.0f, 0.0f } };

#pragma mark -

#undef	LAYOUT_MAX_WIDTH
#define LAYOUT_MAX_WIDTH	(99999.0f)

#undef	LAYOUT_MAX_HEIGHT
#define LAYOUT_MAX_HEIGHT	(99999.0f)

#undef  FLOORF
#define FLOORF(v) (v)
//#define FLOORF(v) floorf(v)

#pragma mark -

@implementation UIView(Metrics)

@dynamic top;
@dynamic bottom;
@dynamic left;
@dynamic right;

@dynamic width;
@dynamic height;

@dynamic offset;
@dynamic position;
@dynamic size;

@dynamic x;
@dynamic y;
@dynamic w;
@dynamic h;

@dynamic frameInWindow;

- (CGFloat)top
{
	return self.frame.origin.y;
}

- (void)setTop:(CGFloat)top
{
	CGRect frame = self.frame;
	frame.origin.y = top;
	self.frame = frame;
}

- (CGFloat)left
{
	return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)left
{
	CGRect frame = self.frame;
	frame.origin.x = left;
	self.frame = frame;
}

- (CGFloat)width
{
	return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
	CGRect frame = self.frame;
	frame.size.width = width;
	self.frame = frame;
}

- (CGFloat)height
{
	return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
	CGRect frame = self.frame;
	frame.size.height = height;
	self.frame = frame;
}

- (CGFloat)bottom
{
    return self.frame.size.height + self.frame.origin.y;
}

- (void)setBottom:(CGFloat)bottom
{
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
	self.frame = frame;
}

- (CGFloat)right
{
    return self.frame.size.width + self.frame.origin.x;
}

- (void)setRight:(CGFloat)right
{
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
	self.frame = frame;
}

- (CGFloat)x
{
	return self.frame.origin.x;
}

- (void)setX:(CGFloat)value
{
	CGRect frame = self.frame;
	frame.origin.x = value;
	self.frame = frame;
}

- (CGFloat)y
{
	return self.frame.origin.y;
}

- (void)setY:(CGFloat)value
{
	CGRect frame = self.frame;
	frame.origin.y = value;
	self.frame = frame;
}

- (CGFloat)w
{
	return self.frame.size.width;
}

- (void)setW:(CGFloat)width
{
	CGRect frame = self.frame;
	frame.size.width = width;
	self.frame = frame;
}

- (CGFloat)h
{
	return self.frame.size.height;
}

- (void)setH:(CGFloat)height
{
	CGRect frame = self.frame;
	frame.size.height = height;
	self.frame = frame;
}

- (CGPoint)offset
{
	CGPoint		point = CGPointZero;
	UIView *	view = self;

	while ( view )
	{
		point.x += view.frame.origin.x;
		point.y += view.frame.origin.y;
		
		view = view.superview;
	}
	
	return point;
}

- (void)setOffset:(CGPoint)offset
{
	UIView * view = self;
	if ( nil == view )
		return;

	CGPoint point = offset;

	while ( view )
	{
		point.x += view.superview.frame.origin.x;
		point.y += view.superview.frame.origin.y;

		view = view.superview;
	}

    CGRect frame = self.frame;
	frame.origin = point;
	self.frame = frame;
}

- (CGPoint)position
{
	return self.frame.origin;
}

- (void)setPosition:(CGPoint)pos
{
    CGRect frame = self.frame;
	frame.origin = pos;
	self.frame = frame;
}

- (CGSize)size
{
	return self.frame.size;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
	frame.size = size;
	self.frame = frame;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)boundsCenter
{
    return CGPointMake( CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) );
}

- (CGRect)frameInWindow{
    UIView *view = self;
    CGRect frame = self.frame;
    frame.origin = CGPointZero;
    do {
        frame.origin.y += view.y;
        frame.origin.x += view.x;
        view = view.superview;
        if ([view isKindOfClass:[UIScrollView class]]) {

            frame.origin.y -= [(UIScrollView *)view contentOffset].y;
            frame.origin.x -= [(UIScrollView *)view contentOffset].x;
//#if (__ON__ == __HM_DEVELOPMENT__)
//            CC( @"FrameInWindow",@"x:%.2f y:%.2f",[(UIScrollView *)view contentOffset].x,[(UIScrollView *)view contentOffset].y);
//#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
        }
    } while (view);
    if ( UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
        &&[[[UIDevice currentDevice] systemVersion] compare:@"7.0"] == NSOrderedAscending ) {
        if (![UIApplication sharedApplication].statusBarHidden) {
            frame.origin.y += 20;
        }
    }

    return frame;
}

- (CGSize)autolayoutForSize:(CGSize)size{
    CGSize maxsize = CGSizeZero;
    CGSize minsize = CGSizeZero;
    if (!self.translatesAutoresizingMaskIntoConstraints) {
        NSArray *constrs = self.constraints;

        BOOL hi=NO;
        BOOL wi=NO;
        for (NSLayoutConstraint *layout in constrs) {
            
            if (layout.firstAttribute == NSLayoutAttributeHeight) {
                if (layout.relation==NSLayoutRelationGreaterThanOrEqual) {
                    minsize.height = layout.constant;
                    maxsize.height = MAX(maxsize.height, minsize.height);
                }else if (layout.relation==NSLayoutRelationLessThanOrEqual){
                    maxsize.height = layout.constant;
                    minsize.height = MIN(minsize.height, maxsize.height);
                }else if (layout.relation==NSLayoutRelationEqual){
                    maxsize.height = layout.constant;
                    minsize.height = layout.constant;
                }
                hi = YES;
            }else if (layout.firstAttribute == NSLayoutAttributeWidth){
                if (layout.relation==NSLayoutRelationGreaterThanOrEqual) {
                    minsize.width = layout.constant;
                    maxsize.width = MAX(maxsize.width, minsize.width);
                }else if (layout.relation==NSLayoutRelationLessThanOrEqual){
                    maxsize.width = layout.constant;
                    minsize.width = MIN(minsize.width, maxsize.width);
                }else if (layout.relation==NSLayoutRelationEqual){
                    maxsize.width = layout.constant;
                    minsize.width = layout.constant;
                }
                wi = YES;
            }
        }
        // min <= x <= max
        size.height = !hi?size.height:(MIN(maxsize.height, MAX(minsize.height, size.height)));
        size.width = !wi?size.width:(MIN(maxsize.width, MAX(minsize.width, size.width)));
    }
    return size;
}

@end

#pragma mark -
HM_EXTERN_C_BEGIN
CGSize AspectFitSizeByWidth( CGSize size, CGFloat width )
{
	float scale = size.width / width;
	return CGSizeMake( size.width / scale, size.height / scale );
}

CGSize AspectFitSizeByHeight( CGSize size, CGFloat height )
{
	float scale = size.height / height;
	return CGSizeMake( size.width / scale, size.height / scale );
}

CGSize AspectFillSizeByWidth( CGSize size, CGFloat width )
{
	float scale = width / size.width;
	
	size.width *= scale;
	size.height *= scale;
	size.width = FLOORF( size.width );
	size.height = FLOORF( size.height );
	
	return size;
}

CGSize AspectFillSizeByHeight( CGSize size, CGFloat height )
{
	float scale = height / size.height;
	
	size.width *= scale;
	size.height *= scale;
	size.width = FLOORF( size.width );
	size.height = FLOORF( size.height );
	
	return size;
}

CGSize AspectFitSize( CGSize size, CGSize bound )
{
	if ( size.width == 0 || size.height == 0 )
		return CGSizeZero;
	
	CGSize newSize = size;
	CGFloat newScale = 1.0f;
	
	float scaleX = bound.width / newSize.width;
	float scaleY = bound.height / newSize.height;
	
	newScale = fminf( scaleX, scaleY );
	
	newSize.width *= newScale;
	newSize.height *= newScale;
	
	newSize.width = FLOORF( newSize.width );
	newSize.height = FLOORF( newSize.height );
	
	return newSize;
}

CGRect AspectFitRect( CGRect rect, CGRect bound )
{
	CGSize newSize = AspectFitSize( rect.size, bound.size );
	newSize.width = FLOORF( newSize.width );
	newSize.height = FLOORF( newSize.height );
	
	CGRect newRect;
	newRect.origin.x = (bound.size.width - newSize.width) / 2;
	newRect.origin.y = (bound.size.height - newSize.height) / 2;
	newRect.size.width = newSize.width;
	newRect.size.height = newSize.height;
	
	return newRect;
}

CGSize AspectFillSize( CGSize size, CGSize bound )
{
	CGSize newSize = size;
	CGFloat newScale = 1.0f;
	
	float scaleX = bound.width / newSize.width;
	float scaleY = bound.height / newSize.height;
	
	newScale = fmaxf( scaleX, scaleY );
	
	newSize.width *= newScale;
	newSize.height *= newScale;
	newSize.width = FLOORF( newSize.width );
	newSize.height = FLOORF( newSize.height );
	
	return newSize;
}

CGRect AspectFillRect( CGRect rect, CGRect bound )
{
	CGSize newSize = AspectFillSize( rect.size, bound.size );
	newSize.width = FLOORF( newSize.width );
	newSize.height = FLOORF( newSize.height );
	
	CGRect newRect;
	newRect.origin.x = (bound.size.width - newSize.width) / 2;
	newRect.origin.y = (bound.size.height - newSize.height) / 2;
	newRect.size.width = newSize.width;
	newRect.size.height = newSize.height;
	
	return newRect;
}

CGRect CGRectFromString( NSString * str )
{
	CGRect rect = CGRectZero;
	
	NSArray * array = [str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if ( array && array.count == 4 )
	{
		NSString *	x = [array objectAtIndex:0];
		NSString *	y = [array objectAtIndex:1];
		NSString *	w = [array objectAtIndex:2];
		NSString *	h = [array objectAtIndex:3];
		
		rect.origin.x = x.floatValue;
		rect.origin.y = y.floatValue;
		rect.size.width = w.floatValue;
		rect.size.height = h.floatValue;
	}
	
	return rect;
}

CGPoint CGPointZeroNan( CGPoint point )
{
	point.x = isnan( point.x ) ? 0.0f : point.x;
	point.y = isnan( point.y ) ? 0.0f : point.y;
	return point;
}

CGSize CGSizeZeroNan( CGSize size )
{
	size.width = isnan( size.width ) ? 0.0f : size.width;
	size.height = isnan( size.height ) ? 0.0f : size.height;
	return size;
}

CGRect CGRectZeroNan( CGRect rect )
{
	rect.origin = CGPointZeroNan( rect.origin );
	rect.size = CGSizeZeroNan( rect.size );
	return rect;
}

CGRect CGRectMakeBound( CGFloat w, CGFloat h )
{
	CGRect rect;
	rect.origin = CGPointZero;
	rect.size.width = w;
	rect.size.height = h;
	return rect;
}


CGRect CGRectAlignX( CGRect rect1, CGRect rect2 )
{
	rect1.origin.x = CGRectGetMidX( rect2 ) - rect1.size.width / 2.0f;
	return rect1;
}

CGRect CGRectAlignY( CGRect rect1, CGRect rect2 )
{
	rect1.origin.y = CGRectGetMidY( rect2 ) - rect1.size.height / 2.0f;
	return rect1;
}

CGRect CGRectAlignCenter( CGRect rect1, CGRect rect2 )
{
	rect1.origin.x = (CGRectGetWidth( rect2 ) - rect1.size.width) / 2.0f;
	rect1.origin.y = (CGRectGetHeight( rect2 ) - rect1.size.height) / 2.0f;
	return rect1;
}

CGRect CGRectAlignTop( CGRect rect1, CGRect rect2 )
{
	rect1.origin.y = rect2.origin.y;
	return rect1;
}

CGRect CGRectAlignBottom( CGRect rect1, CGRect rect2 )
{
	rect1.origin.y = CGRectGetMaxY( rect2 ) - rect1.size.height;
	return rect1;
}

CGRect CGRectAlignLeft( CGRect rect1, CGRect rect2 )
{
	rect1.origin.x = rect2.origin.x;
	return rect1;
}

CGRect CGRectAlignRight( CGRect rect1, CGRect rect2 )
{
	rect1.origin.x = CGRectGetMaxX( rect2 ) - rect1.size.width;
	return rect1;
}

CGRect CGRectAlignLeftTop( CGRect rect1, CGRect rect2 )
{
	rect1.origin.x = rect2.origin.x;
	rect1.origin.y = rect2.origin.y;
	return rect1;
}

CGRect CGRectAlignLeftBottom( CGRect rect1, CGRect rect2 )
{
	rect1.origin.x = rect2.origin.x;
	rect1.origin.y = CGRectGetMaxY( rect2 ) - rect1.size.height;
	return rect1;
}

CGRect CGRectAlignRightTop( CGRect rect1, CGRect rect2 )
{
	rect1.origin.x = CGRectGetMaxX( rect2 ) - rect1.size.width;
	rect1.origin.y = rect2.origin.y;
	return rect1;
}

CGRect CGRectAlignRightBottom( CGRect rect1, CGRect rect2 )
{
	rect1.origin.x = CGRectGetMaxX( rect2 ) - rect1.size.width;
	rect1.origin.y = CGRectGetMaxY( rect2 ) - rect1.size.height;
	return rect1;
}

CGRect CGRectCloseToTop( CGRect rect1, CGRect rect2 )
{
	rect1.origin.y = CGRectGetMaxY( rect2 );
	return rect1;
}

CGRect CGRectCloseToBottom( CGRect rect1, CGRect rect2 )
{
	rect1.origin.y = rect2.origin.y - rect1.size.height;
	return rect1;
}

CGRect CGRectCloseToLeft( CGRect rect1, CGRect rect2 )
{
	rect1.origin.x = CGRectGetMaxX( rect2 );
	return rect1;
}

CGRect CGRectCloseToRight( CGRect rect1, CGRect rect2 )
{
	rect1.origin.x = rect2.origin.x - rect1.size.width;
	return rect1;
}

CGRect CGRectReduceWidth( CGRect rect, CGFloat pixels )
{
	CGRect temp = rect;
	temp.size.width = (temp.size.width > pixels) ? (temp.size.width - pixels) : 0.0f;
	return temp;
}

CGRect CGRectReduceHeight( CGRect rect, CGFloat pixels )
{
	CGRect temp = rect;
	temp.size.height = (temp.size.height > pixels) ? (temp.size.height - pixels) : 0.0f;
	return temp;
}

CGRect CGRectMoveCenter( CGRect rect1, CGPoint offset )
{
	rect1.origin.x = offset.x - rect1.size.width / 2.0f;
	rect1.origin.y = offset.y - rect1.size.height / 2.0f;
	return rect1;
}

CGRect CGSizeMakeBound( CGSize size )
{
	CGRect rect;
	rect.origin = CGPointZero;
	rect.size = size;
	return rect;
}

CGRect CGRectToBound( CGRect frame )
{
	CGRect rect;
	rect.origin = CGPointZero;
	rect.size = frame.size;
	return rect;
}

CGSize CGRectGetDistance( CGRect rect1, CGRect rect2 )
{
    CGSize size;
    size.width = rect2.origin.x - rect1.origin.x;
    size.height = rect2.origin.y - rect1.origin.y;
    return size;
}

CGRect CGRectContract(CGRect rect, CGFloat dx, CGFloat dy) {
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width - dx, rect.size.height - dy);
}

CGRect CGRectShift(CGRect rect, CGFloat dx, CGFloat dy) {
    return CGRectOffset(CGRectContract(rect, dx, dy), dx, dy);
}

CGRect CGRectEdgeInsets(CGRect rect, UIEdgeInsets insets) {
    return CGRectMake(rect.origin.x + insets.left, rect.origin.y + insets.top,
                      rect.size.width - (insets.left + insets.right),
                      rect.size.height - (insets.top + insets.bottom));
}

CGRect CGRectMakeScale( CGRect rect ,CGFloat scale){
    return CGRectMake(rect.origin.x*scale, rect.origin.y*scale, rect.size.width*scale, rect.size.height*scale);
}

CGSize CGSizeMakeScale( CGSize size ,CGFloat scale){
    return CGSizeMake(size.width*scale, size.height*scale);
}

UIEdgeInsets UIEdgeInsetsAll(CGFloat inset){
    
    return  UIEdgeInsetsMake(inset, inset, inset, inset);
    
}

UIEdgeInsets UIEdgeInsetsVerAndHor(CGFloat ver,CGFloat hor ){
    
    return  UIEdgeInsetsMake(ver, hor, ver, hor);
    
}

UIEdgeInsets UIEdgeInsetsVerAndLR(CGFloat ver,CGFloat left ,CGFloat right){
    
    return  UIEdgeInsetsMake(ver, left, ver, right);
    
}

UIEdgeInsets UIEdgeInsetsTBAndHor(CGFloat top ,CGFloat bottom,CGFloat hor ){
    
    return  UIEdgeInsetsMake(top, hor, bottom, hor);
    
}

UIEdgeInsets UIEdgeInsetsUnion(UIEdgeInsets insets1, UIEdgeInsets insets2) {
    return UIEdgeInsetsMake(insets1.top+insets2.top, insets1.left+insets2.left,
                            insets1.bottom+insets2.bottom, insets1.right+insets2.right);
}



UIEdgeInsets UIEdgeInsetsContainsAll(CGRect contain, CGSize size, CGFloat top, CGFloat left, CGFloat bottom, CGFloat right){
    if (CGRectEqualToRect(contain, CGRectZero)||CGSizeEqualToSize(size, CGSizeZero)) {
        return UIEdgeInsetsAll(0);
    }
    CGFloat tc = (contain.size.height - size.height)/2;
    CGFloat bc = tc;
    CGFloat lc = (contain.size.width - size.width)/2;
    CGFloat rc = lc;
    if (top != CGFLOAT_MIN) {
        bc += tc-top;
        tc = top;
    }else if (bottom != CGFLOAT_MIN) {
        tc += bc-bottom;
        bc = bottom;
    }
    if (left != CGFLOAT_MIN) {
        rc += lc-left;
        lc = left;
    }else if (right != CGFLOAT_MIN) {
        lc += rc-right;
        rc = right;
    }
    
    return  UIEdgeInsetsMake(tc, lc, bc, rc);
}

UIEdgeInsets UIEdgeInsetsContainsCenterTopRight(CGRect contain, CGSize size, CGFloat top, CGFloat right){
    
    return UIEdgeInsetsContainsAll(contain, size, top, CGFLOAT_MIN, CGFLOAT_MIN, right);
}

UIEdgeInsets UIEdgeInsetsContainsCenterTopLeft(CGRect contain, CGSize size, CGFloat top, CGFloat left){
    
    return UIEdgeInsetsContainsAll(contain, size, top, left, CGFLOAT_MIN, CGFLOAT_MIN);
}

UIEdgeInsets UIEdgeInsetsContainsCenterBottomLeft(CGRect contain, CGSize size, CGFloat bottom, CGFloat left){
    
    return UIEdgeInsetsContainsAll(contain, size, CGFLOAT_MIN, left, bottom, CGFLOAT_MIN);
}

UIEdgeInsets UIEdgeInsetsContainsCenterBottomRight(CGRect contain, CGSize size, CGFloat bottom, CGFloat right){
    
    return UIEdgeInsetsContainsAll(contain, size, CGFLOAT_MIN, CGFLOAT_MIN, bottom, right);
}

UIEdgeInsets UIEdgeInsetsContainsCenter(CGRect contain, CGSize size){
    
    return UIEdgeInsetsContainsAll(contain, size, CGFLOAT_MIN, CGFLOAT_MIN, CGFLOAT_MIN, CGFLOAT_MIN);
}


CGSize CGSizeNormalize(CGSize size){
    CGSize newsize;
    newsize.width = ceilf(size.width);
    newsize.height = ceilf(size.height);
    return newsize;
}

CGPoint CGPointNormalize(CGPoint point){
    CGPoint newpoint;
    newpoint.x = ceilf(point.x);
    newpoint.y = ceilf(point.y);
    return newpoint;
}

CGRect CGRectNormalize(CGRect rect){
    CGRect newRect;
    newRect.origin.x = ceilf(rect.origin.x);
    newRect.origin.y = ceilf(rect.origin.y);
    newRect.size.width = ceilf(rect.size.width);
    newRect.size.height = ceilf(rect.size.height);
    return newRect;
}



HM_EXTERN_C_END

#pragma mark -



#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

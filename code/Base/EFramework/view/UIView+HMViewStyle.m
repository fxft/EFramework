    //
//  UIView+HMViewStyle.m
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "UIView+HMViewStyle.h"

#import "HMViewCategory.h"

#pragma mark -
#pragma mark --------------------------黑了UILabel-适配view  style---------------------------------------
#pragma mark -
#pragma mark -

@implementation UILabel (HMViewStyle)

static void (*_drawRectLabel)( id, SEL, CGRect );
static CGSize (*_sizeThatFits)( id, SEL, CGSize);
static CGSize (*_systemLayoutSizeFittingSize)( id, SEL, CGSize);
static void (*_dealloc_)( id, SEL);
static void (*_setText)( id, SEL, NSString* );

+ (void)hook
{
	static BOOL __swizzled = NO;
	if ( NO == __swizzled )
	{
		Method method;
		IMP implement;
        
        method = class_getInstanceMethod( [UILabel class], @selector(drawTextInRect:) );
		_drawRectLabel = (void *)method_getImplementation( method );
		
		implement = class_getMethodImplementation( [UILabel class], @selector(myDrawRect:) );
		method_setImplementation( method, implement );
        
        method = class_getInstanceMethod( [UILabel class], @selector(sizeThatFits:) );
		_sizeThatFits = (void *)method_getImplementation( method );
		
		implement = class_getMethodImplementation( [UILabel class], @selector(mySizeThatFits:) );
		method_setImplementation( method, implement );
        
        method = class_getInstanceMethod( [UILabel class], @selector(systemLayoutSizeFittingSize:) );
        _systemLayoutSizeFittingSize = (void *)method_getImplementation( method );
        
        implement = class_getMethodImplementation( [UILabel class], @selector(mySystemLayoutSizeFittingSize:) );
        method_setImplementation( method, implement );
        
#if __has_feature(objc_arc)
#else
        method = class_getInstanceMethod( [UILabel class], @selector(dealloc) );
		_dealloc_ = (void *)method_getImplementation( method );

		implement = class_getMethodImplementation( [UILabel class], @selector(myDealloc) );
		method_setImplementation( method, implement );
#endif  
        method = class_getInstanceMethod( [UILabel class], @selector(setText:) );
		_setText = (void *)method_getImplementation( method );
		
		implement = class_getMethodImplementation( [UILabel class], @selector(mySetText:) );
		method_setImplementation( method, implement );
        
		__swizzled = YES;
	}
}

- (void)mySetText:(NSString*)text{
    if (_setText) {
        _setText(self, _cmd, text);
    }

    if ([self respondsToSelector:@selector(dectecedText:)]) {
        [self dectecedText:text];
    }
    
}

- (void)myDealloc{
    [self unload_link];
    if (_dealloc_) {
        _dealloc_(self,_cmd);
    }
}

- (CGSize)mySizeThatFits:(CGSize)size{
    CGSize size1 = _sizeThatFits(self, _cmd, size);
    
    CGSize size3 = size1;
    if (self.style__!=nil) {
        CGSize size2 = [self.style__ addToSize:size1 context:nil];
    
        size3 = size2;
    }
    return size3;
}

- (CGSize)mySystemLayoutSizeFittingSize:(CGSize)targetSize{
    CGSize size = _systemLayoutSizeFittingSize(self,_cmd,targetSize);
    
    return size;
}

- (void)myDrawRect:(CGRect)rect{
    CGRect titleRect = rect;
    HMUIStyleContext *context = [self drawStyleInRect:rect];
    if (context!=nil) {
        titleRect = context.contentFrame;
    }
    if (_drawRectLabel) {
//        NSAttributedString *att = self.attributedText;
//        CGRect newRect = [att boundingRectWithSize:CGSizeMake(titleRect.size.width, 9999.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
//        CGRect textRect = [self textRectForBounds:titleRect limitedToNumberOfLines:self.numberOfLines];
        CGSize size = titleRect.size;
//        if (self.numberOfLines!=1) {
////            NSAttributedString *att = self.attributedText;
////            CGRect newRect = [att boundingRectWithSize:CGSizeMake(textRect.size.width, 9999.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil];//[[self.attributedText string] sizeWithFont:self.font byWidth:textRect.size.width];
//            size = newRect.size;
//        }else{
//            size = textRect.size;
//        }
        if (self.textAlignment==UITextAlignmentCenter) {
            
            titleRect.origin.y += ceilf((titleRect.size.height - size.height)/2);
            titleRect.origin.x += ceilf((titleRect.size.width - size.width)/2);
            
        }else if (self.textAlignment==UITextAlignmentRight){
            
            titleRect.origin.y += ceilf((titleRect.size.height - size.height)/2);
            titleRect.origin.x += ceilf((titleRect.size.width - size.width));
        }else{            
            titleRect.origin.y += ceilf((titleRect.size.height - size.height)/2);
        }
        
        titleRect.size = size;
        
        self.contentFrame = titleRect;
#if (__ON__ == __HM_DEVELOPMENT__)
        if ([HMUIConfig sharedInstance].showViewBorder) {
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextSaveGState(ctx);
//            CGContextStrokeRect(ctx, titleRect);
            CGContextSetStrokeColorWithColor(ctx, [[UIColor grayColor] colorWithAlphaComponent:.6f].CGColor);
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, &CGAffineTransformIdentity, titleRect.origin.x, titleRect.origin.y);
            CGPathAddLineToPoint(path, &CGAffineTransformIdentity, titleRect.origin.x+titleRect.size.width, titleRect.origin.y);
            CGPathAddLineToPoint(path, &CGAffineTransformIdentity, titleRect.origin.x+titleRect.size.width, titleRect.origin.y+titleRect.size.height);
            CGPathAddLineToPoint(path, &CGAffineTransformIdentity, titleRect.origin.x, titleRect.origin.y);
            CGPathAddLineToPoint(path, &CGAffineTransformIdentity, titleRect.origin.x, titleRect.origin.y+titleRect.size.height);
            CGPathAddLineToPoint(path, &CGAffineTransformIdentity, titleRect.origin.x+titleRect.size.width, titleRect.origin.y);
            CGPathMoveToPoint(path, &CGAffineTransformIdentity, titleRect.origin.x, titleRect.origin.y+titleRect.size.height);
            CGPathAddLineToPoint(path, &CGAffineTransformIdentity, titleRect.origin.x+titleRect.size.width, titleRect.origin.y+titleRect.size.height);
            CGContextAddPath(ctx, path);
            CGContextStrokePath(ctx);
            
            CGContextRestoreGState(ctx);
            if (context!=nil) {
                CGContextSaveGState(ctx);
                CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
                CGContextStrokeRect(ctx, rect);
                CGContextRestoreGState(ctx);
            }
        }
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)

        _drawRectLabel(self, _cmd, titleRect);
       
    }
    
}

@end

#pragma mark -
#pragma mark --------------------------黑了UIView-适配view  style---------------------------------------
#pragma mark -
@implementation UIView (HMViewStyle)

@dynamic style__;

static int __style__KEY;
- (HMUIStyle *)style__
{
	NSObject * obj = objc_getAssociatedObject( self, &__style__KEY );
	if ( obj && [obj isKindOfClass:[HMUIStyle class]] )
		return (HMUIStyle *)obj;
	
	return nil;
}

- (void)setStyle__:(HMUIStyle *)style
{
	objc_setAssociatedObject( self, &__style__KEY, style, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

- (UIView*)addViewStyle:(HMUIStyle *)style{
    if (self.style__) {
        HMUIStyle *ss = self.style__;
        while (ss.next) {
            ss = ss.next;
        }
        ss.next = style;
    }else{
        self.style__ = style;
    }
    return self;
}

- (UIView*)clearViewStyle{
    self.style__ = nil;
    [self setNeedsDisplay];
    return self;
}

- (UIView*)updateViewStyle{

    [self setNeedsDisplay];
    return self;
}

- (HMUIStyleContext *)drawStyleInRect:(CGRect)rect{
    
    HMUIStyleContext *context = nil;
    if (self.style__!=nil) {
        
        context = [[HMUIStyleContext alloc]init];
        context.frame = rect;
        context.contentFrame = rect;
        context.layer = self.layer;
        [self.style__ draw:context];
        [context autorelease];
    }
    return context;
}

- (UIEdgeInsets)styleInsets{
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if (self.style__) {
        
        inset = [self.style__ addToInsets:inset forSize:CGSizeZero];
    }
    return inset;
}

- (CGRect)styleMinBounds{
    if (self.style__) {
        UIEdgeInsets inset = UIEdgeInsetsZero;
        inset = [self.style__ addToInsets:inset forSize:CGSizeZero];
        return CGRectMake(0, 0, inset.left+inset.right,inset.top+inset.bottom);
    }
    return CGRectZero;
}

- (CGRect)styleForBounds:(CGRect)bounds{
    if (self.style__) {
        
        UIEdgeInsets inset = UIEdgeInsetsZero;
        inset = [self.style__ addToInsets:inset forSize:bounds.size];
        return CGRectEdgeInsets(bounds, inset);
    }
    return bounds;
}


@end




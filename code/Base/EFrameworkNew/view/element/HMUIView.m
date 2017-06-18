//
//  HMUIView.m
//  CarAssistant
//
//  Created by Eric on 14-3-11.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIView.h"
#import "HMViewCategory.h"


@implementation HMUIView{

}
- (BOOL)is:(NSString *)string{
    return [self.tagString isEqualToString:string];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        [self initSelfDefault];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)init
{
    return [self initWithFrame:CGRectZero];
}

- (void)dealloc
{
    self.style__ = nil;
    [self unload];
    HM_SUPER_DEALLOC();
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    [self initSelfDefault];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (self.style__) {
        [self setNeedsDisplay];
    }
    
}

- (void)drawRect:(CGRect)rect{

    
    [super drawRect:rect];
#if (__ON__ == __HM_DEVELOPMENT__)
    if ([HMUIConfig sharedInstance].showViewBorder) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        CGRect titleRect = rect;
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
        CGPathRelease(path);
    }
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    [self drawStyleInRect:rect];
}

- (CGSize)sizeThatFits:(CGSize)size{
    CGSize size1 = [super sizeThatFits:size];
    CGSize size3 = size1;
    if (self.style__!=nil) {
        CGSize size2 = [self.style__ addToSize:size1 context:nil];
        size3 = size2;
    }
    return size3;
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

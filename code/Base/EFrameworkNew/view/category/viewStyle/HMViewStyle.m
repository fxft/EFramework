//
//  HMViewStyle.m
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMViewStyle.h"

inline void openPath(CGContextRef context,CGRect rect) {
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextBeginPath(context);
}

inline void closePath(CGContextRef context,CGRect rect) {
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

inline void roundedRectangle(CGContextRef context,CGRect rect,CGFloat radius){
    openPath(context,rect);
    CGFloat fw = rect.size.width;
    CGFloat fh = rect.size.height;

    CGContextMoveToPoint(context, fw, floor(fh/2));
    CGContextAddArcToPoint(context, fw, fh, floor(fw/2), fh, RD(radius));
    CGContextAddArcToPoint(context, 0, fh, 0, floor(fh/2), RD(radius));
    CGContextAddArcToPoint(context, 0, 0, floor(fw/2), 0, RD(radius));
    CGContextAddArcToPoint(context, fw, 0, fw, floor(fh/2), RD(radius));
    
    closePath(context,rect);
}

@implementation HMViewStyle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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

//
//  HMUIInsetStyle.m
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIInsetStyle.h"


typedef NS_ENUM(int, _INSETSTYLE){
    INSETSTYLE_normal = 0,
    INSETSTYLE_restroe = 1,
    INSETSTYLE_saveForFrame = 2,
    INSETSTYLE_saveForInset = 3,
    
}INSETSTYLE;


@implementation HMUIInsetStyle

@synthesize inset = _inset;
@synthesize stackContentFrame = _stackContentFrame;
@synthesize stackFrame = _stackFrame;
@synthesize stackInset = _stackInset;
@synthesize stackSize = _stackSize;
@synthesize state = _state;
@synthesize newFrame = _newFrame;
@synthesize tag = _tag;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNext:(HMUIStyle*)next {
	self = [super initWithNext:next];
    if (self) {
        _inset = UIEdgeInsetsZero;
        _stackContentFrame = CGRectZero;
        _stackFrame = CGRectZero;
        _stackInset = UIEdgeInsetsZero;
        _stackSize = CGSizeZero;
        _state = INSETSTYLE_normal;
        self.tag = 0;
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (HMUIInsetStyle*)styleWithInset:(UIEdgeInsets)inset next:(HMUIStyle*)next {
    HMUIInsetStyle* style = [[[self alloc] initWithNext:next] autorelease];
    style.inset = inset;
    return style;
}

+ (HMUIInsetStyle *)styleWithSaveForNewFrame:(CGRect)frame next:(HMUIStyle *)next{
    HMUIInsetStyle* style = [[[self alloc] initWithNext:next] autorelease];
    style.newFrame = frame;
    style.state = INSETSTYLE_saveForFrame;
    return style;
}

+ (HMUIInsetStyle *)styleWithSaveForInset:(UIEdgeInsets)inset butWidth:(CGFloat)width height:(CGFloat)height next:(HMUIStyle *)next{
    HMUIInsetStyle* style = [[[self alloc] initWithNext:next] autorelease];
    style.inset = inset;
    style.newFrame = CGRectMakeBound(width, height);
    style.state = INSETSTYLE_saveForInset;
    
    return style;
}

+ (HMUIInsetStyle *)styleWithRestoreNext:(HMUIStyle *)next{
    HMUIInsetStyle* style = [[[self alloc] initWithNext:next] autorelease];
    style.state = INSETSTYLE_restroe;
    return style;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTStyle


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)draw:(HMUIStyleContext*)context {

    if ((_state==INSETSTYLE_saveForFrame)||(_state==INSETSTYLE_saveForInset)) {//saving
        //lookup the restore inset
        HMUIStyle *style = self.next;
        int jump=0;
        do {
            
            HMUIInsetStyle *inset = [style firstStyleOfClass:[HMUIInsetStyle class]];
            
            if (inset.state==INSETSTYLE_restroe) {
                
                if (jump>0) {
                    inset.tag = jump;
//#if (__ON__ == __HM_DEVELOPMENT__)
//                    CC( @"STYLE",@"jump tag:%d",jump);
//#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
                    
                    jump--;
                    style = inset.next;
                    continue;
                }
                
                inset.stackFrame = context.frame;
                inset.stackContentFrame = context.contentFrame;
//#if (__ON__ == __HM_DEVELOPMENT__)
//                CC( @"STYLERestore",@"state:%d-%d stackFrame: origin=(x=%.1f, y=%.1f) size=(width=%.1f, height=%.1f)\n stackContent: origin=(x=%.1f, y=%.1f) size=(width=%.1f, height=%.1f)",
//                   _state,inset.state,context.frame.origin.x,context.frame.origin.y,context.frame.size.width,context.frame.size.height,
//                   context.contentFrame.origin.x,context.contentFrame.origin.y,context.contentFrame.size.width,context.contentFrame.size.height);
//#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
                if (_state==INSETSTYLE_saveForFrame) {
                    context.frame = _newFrame;
                    context.contentFrame = _newFrame;
                }else{
                    CGRect frame = CGRectEdgeInsets(context.frame, _inset);
                    if (_newFrame.size.width > 0.f) {
                        frame.size.width = _newFrame.size.width;
                    }
                    if (_newFrame.size.height > 0.f) {
                        frame.size.height = _newFrame.size.height;
                    }
                    context.frame = frame;
                    
                    frame = CGRectEdgeInsets(context.contentFrame, _inset);
                    if (_newFrame.size.width > 0.f) {
                        frame.size.width = _newFrame.size.width;
                    }
                    if (_newFrame.size.height > 0.f) {
                        frame.size.height = _newFrame.size.height;
                    }
                    context.contentFrame = frame;
                }
                
                break;
            }else if (inset.state > INSETSTYLE_restroe){

                jump++;
                inset.tag = jump;
//#if (__ON__ == __HM_DEVELOPMENT__)
//                CC( @"STYLE",@"jump:%d  for sub:%d",jump,inset.state);
//#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
            }
            style = inset.next;
        } while (style);
//#if (__ON__ == __HM_DEVELOPMENT__)
//        CC( @"STYLE",@"next sytle:%@",[style class]);
//#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    }else if (_state==INSETSTYLE_restroe) {//restoring
        
        context.frame = _stackFrame;
        context.contentFrame = _stackContentFrame;
        
    }else{
        context.frame = CGRectEdgeInsets(context.frame, _inset);
        context.contentFrame = CGRectEdgeInsets(context.contentFrame, _inset);
    }
//#if (__ON__ == __HM_DEVELOPMENT__)
//    CC( @"STYLEDrawn",@"[%d]state:%d frame: origin=(x=%.2f, y=%.2f) size=(width=%.2f, height=%.2f)\n contentFrame: origin=(x=%.2f, y=%.2f) size=(width=%.2f, height=%.2f)",
//       _tag,_state,context.frame.origin.x,context.frame.origin.y,context.frame.size.width,context.frame.size.height,
//       context.contentFrame.origin.x,context.contentFrame.origin.y,context.contentFrame.size.width,context.contentFrame.size.height);
//#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    [self.next draw:context];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)addToInsets:(UIEdgeInsets)insets forSize:(CGSize)size {
    if ((_state==INSETSTYLE_saveForFrame)||(_state==INSETSTYLE_saveForInset)) {//saving
        //lookup the restore inset
        HMUIStyle *style = self.next;
        int jump= 0;
        do {
            
            HMUIInsetStyle *inset = [style firstStyleOfClass:[HMUIInsetStyle class]];
            
            if (inset.state==INSETSTYLE_restroe) {
                if (jump>0) {
                    jump--;
                    style = inset.next;
                    continue;
                }
                inset.stackInset = insets;
                insets = UIEdgeInsetsZero;
                
                break;
            }else if (inset.state > INSETSTYLE_restroe){
                jump++;
            }
            style = inset.next;
        } while (style);
        
    }else if (self.state==INSETSTYLE_restroe) {//restoring
        
        insets = _stackInset;
        
    }else{
        insets.top += _inset.top;
        insets.right += _inset.right;
        insets.bottom += _inset.bottom;
        insets.left += _inset.left;
    }
    if (self.next) {
        return [self.next addToInsets:insets forSize:size];
        
    } else {
        return insets;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)addToSize:(CGSize)size context:(HMUIStyleContext*)context {
    if ((_state==INSETSTYLE_saveForFrame)||(_state==INSETSTYLE_saveForInset)) {//saving
        //lookup the restore inset
        HMUIStyle *style = self.next;
        int jump= 0;
        do {
            
            HMUIInsetStyle *inset = [style firstStyleOfClass:[HMUIInsetStyle class]];
            
            if (inset.state==INSETSTYLE_restroe) {
                if (jump>0) {
                    jump--;
                    style = inset.next;
                    continue;
                }
                inset.stackSize = size;
                
                break;
            }else if (inset.state > INSETSTYLE_restroe){
                jump++;
            }
            style = inset.next;
        } while (style);
        
    }else if (self.state==INSETSTYLE_restroe) {//restoring
        
        size = _stackSize;
        
    }else{
        size.width += _inset.left + _inset.right;
        size.height += _inset.top + _inset.bottom;
    }
    if (_next) {
     
        return [self.next addToSize:size context:context];
        
    }
    
    return size;
}

@end

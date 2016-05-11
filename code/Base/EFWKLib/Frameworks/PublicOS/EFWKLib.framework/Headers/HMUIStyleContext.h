//
//  HMUIStyleContext.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMMacros.h"

extern const NSInteger kDefaultLightSource;
@class HMUIShape;

@interface HMUIStyleContext : NSObject{
    CGRect    _frame;
    CGRect    _contentFrame;
    
    HMUIShape*  _shape;
    
    UIFont*   _font;
    
    BOOL      _didDrawContent;
    
//    id<TTStyleDelegate> _delegate;
}

@property (nonatomic)         CGRect    frame;
@property (nonatomic)         CGRect    contentFrame;
@property (nonatomic, HM_STRONG) HMUIShape*  shape;
@property (nonatomic, HM_STRONG) UIFont*   font;
@property (nonatomic)         BOOL      didDrawContent;
@property (nonatomic, HM_WEAK) CALayer*   layer;
//@property (nonatomic, assign) id<TTStyleDelegate> delegate;

@end

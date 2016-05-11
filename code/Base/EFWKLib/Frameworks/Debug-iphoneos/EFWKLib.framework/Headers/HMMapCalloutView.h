//
//  HMMapCalloutView.h
//  GPSService
//
//  Created by Eric on 14-4-10.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIView.h"
#import "HMMacros.h"

typedef enum{
    CALLOUTVIEWTYPE_DEFAULT=0,
    CALLOUTVIEWTYPE_SUBTITLEFULL=1,
    
}CALLOUTVIEWTYPE;

@interface HMMapCalloutView : HMUIView
@property (HM_STRONG, nonatomic, readonly) UILabel *  title;
@property (HM_STRONG, nonatomic, readonly) UILabel *  subtitle;
@property (HM_STRONG, nonatomic) UIView *   leftView;
@property (HM_STRONG, nonatomic) UIView *   rightView;
@property (nonatomic,assign) CGFloat maxSubtitleWidth;
- (void)resetView;
+ (instancetype)spawnWithType:(CALLOUTVIEWTYPE)type;

@end

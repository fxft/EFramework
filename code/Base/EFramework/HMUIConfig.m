//
//  HMUIConfig.m
//  CarAssistant
//
//  Created by Eric on 14-3-14.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIConfig.h"


@implementation HMUIConfig{
    HMUIInterfaceMode _interfaceMode;
}
@synthesize interfaceMode = _interfaceMode;
@synthesize statusBarStyle = _statusBarStyle;
@synthesize allowControlerGestureBack=_allowControlerGestureBack;
@synthesize allowedPortrait;
@synthesize allowedPortraitUpside;
@synthesize allowedLandscape;
@synthesize allowedLandscapeRight;
@synthesize allowControlerGestureAutoControl=_allowControlerGestureAutoControl;
@synthesize showViewBorder;
@synthesize localizable;
@synthesize includesOpaque;
@synthesize defaultNavigationBarColor=_defaultNavigationBarColor;
@synthesize defaultNavigationBarImage=_defaultNavigationBarImage;
@synthesize defaultNavigationTitleColor = _defaultNavigationTitleColor;
@synthesize defaultNavigationBarOriginalColor = _defaultNavigationBarOriginalColor;
@synthesize defaultNavigationBarTranslucent = _defaultNavigationBarTranslucent;
@synthesize defaultNavigationTitleFont = _defaultNavigationTitleFont;
@synthesize defaultNavigationBarShadowImage = _defaultNavigationBarShadowImage;

DEF_SINGLETON(HMUIConfig)
- (id)init
{
    self = [super init];
    if (self) {
        _interfaceMode = HMUIInterfaceMode_iOS6;
        _statusBarStyle = UIStatusBarStyleDefault;
        self.localizable = [HMSystemInfo currentLanguage];
        self.allowedPortrait  = YES;
        self.allowedLandscapeRight = YES;
        _allowedLogWebDataLength = 20480;
    }
    return self;
}

- (void)setAllowControlerGestureAutoControl:(BOOL)allowControlerGestureAutoControl{
    
    if (_allowControlerGestureAutoControl!=allowControlerGestureAutoControl) {
        _allowControlerGestureAutoControl = allowControlerGestureAutoControl;
        [self postNotification:@"allowControlerGestureBackChanged"];
    }
    
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle{
    _statusBarStyle = statusBarStyle;
     [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle animated:YES];
}



- (void)setDefaultNavigationTitleFont:(UIFont *)defaultNavigationTitleFont{
    
    [_defaultNavigationTitleFont release];
    _defaultNavigationTitleFont = [defaultNavigationTitleFont retain];
    
    NSMutableDictionary * attrs = [NSMutableDictionary dictionary];

    if (_defaultNavigationTitleFont) {
        [attrs setObject:_defaultNavigationTitleFont forKey:NSFontAttributeName];
    }
    if (_defaultNavigationTitleColor) {
        [attrs setObject:_defaultNavigationTitleColor forKey:NSForegroundColorAttributeName];
    }
    
    [[UINavigationBar appearance] setTitleTextAttributes:attrs];
    [self postNotification:[HMUINavigationBar STYLE_CHANGED]];
}

- (void)setDefaultNavigationTitleColor:(UIColor *)defaultNavigationTitleColor{
    
    [_defaultNavigationTitleColor release];
    _defaultNavigationTitleColor = [defaultNavigationTitleColor retain];
    
    
    NSMutableDictionary * attrs = [NSMutableDictionary dictionary];
    
    if (_defaultNavigationTitleFont) {
        [attrs setObject:_defaultNavigationTitleFont forKey:NSFontAttributeName];
    }
    if (_defaultNavigationTitleColor) {
        [attrs setObject:_defaultNavigationTitleColor forKey:NSForegroundColorAttributeName];
    }
    
    [[UINavigationBar appearance] setTitleTextAttributes:attrs];
    [self postNotification:[HMUINavigationBar STYLE_CHANGED]];
}

- (void)setDefaultNavigationBarImage:(UIImage *)defaultNavigationBarImage{

    [_defaultNavigationBarImage release];
    _defaultNavigationBarImage = [defaultNavigationBarImage retain];
    
    [[UINavigationBar appearance] setBackgroundImage:defaultNavigationBarImage forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    [self postNotification:[HMUINavigationBar STYLE_CHANGED]];
}

- (void)setDefaultNavigationBarShadowImage:(UIImage *)defaultNavigationBarShadowImage{
    
    [_defaultNavigationBarShadowImage release];
    _defaultNavigationBarShadowImage = [defaultNavigationBarShadowImage retain];
    
    [[UINavigationBar appearance] setShadowImage:defaultNavigationBarShadowImage];
    [self postNotification:[HMUINavigationBar STYLE_CHANGED]];
}

- (void)setDefaultNavigationBarColor:(UIColor *)defaultNavigationBarColor{
    
    [_defaultNavigationBarColor release];
    _defaultNavigationBarColor = [defaultNavigationBarColor retain];
    
    [[UINavigationBar appearance] setBarTintColor:defaultNavigationBarColor];
//    [self setDefaultNavigationBarImage:nil];
    
    [self postNotification:[HMUINavigationBar STYLE_CHANGED]];
}


- (void)setDefaultNavigationBarOriginalColor:(UIColor *)defaultNavigationBarOriginalColor{
    
    [_defaultNavigationBarOriginalColor release];
    _defaultNavigationBarOriginalColor = [defaultNavigationBarOriginalColor retain];
    
    UIImage *transparentBackground = [UIImage imageForColor:defaultNavigationBarOriginalColor scale:[UIScreen mainScreen].scale size:CGSizeMake(1, 1)];
    
//    [self setDefaultNavigationBarColor:defaultNavigationBarOriginalColor];
    [self setDefaultNavigationBarImage:transparentBackground];
    [self setDefaultNavigationBarTranslucent:NO];
}

- (void)setDefaultNavigationBarTranslucent:(BOOL)defaultNavigationBarTranslucent{
    _defaultNavigationBarTranslucent = defaultNavigationBarTranslucent;
    [self postNotification:[HMUINavigationBar STYLE_CHANGED]];
}

- (void)dealloc
{
    self.localizable = nil;
    self.defaultNavigationBarImage = nil;
    self.defaultNavigationBarColor = nil;
    self.defaultNavigationTitleColor = nil;
    HM_SUPER_DEALLOC();
}


@end

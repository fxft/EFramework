//
//  HMUIWindow.h
//  CarAssistant
//
//  Created by Eric on 14-3-11.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMMacros.h"
#import "HMFoundation.h"


@interface HMUIWindow : UIWindow
AS_SINGLETON( HMUIWindow )

- (void)prepareShow;
- (void)prepareHide;

- (void)show;
- (void)hide;

- (void)showWithAnimate;

@end

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
#if (__ON__ == __HM_DEVELOPMENT__)

@interface HMDEBUGWindow : UIWindow

AS_SINGLETON(HMDEBUGWindow)

@end

#pragma mark -

@interface UIWindow(ServiceInspector)

AS_NOTIFICATION( TOUCH_BEGAN );
AS_NOTIFICATION( TOUCH_MOVED );
AS_NOTIFICATION( TOUCH_ENDED );

+ (void)hook;
+ (void)block:(BOOL)flag;

@end

#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
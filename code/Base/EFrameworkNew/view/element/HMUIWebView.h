//
//  HMUIWebView.h
//  GPSService
//
//  Created by Eric on 14-4-18.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HMMacros.h"
#import "HMEvent.h"

#define ON_WebView( signal) ON_SIGNAL2(HMUIWebView, signal)
@protocol ON_WebView_handle <NSObject>

ON_WebView( signal);

@end

@protocol HMUIWebViewProgressDelegate <NSObject>
@optional
- (void) webView:(UIWebView*)webView didReceiveResourceNumber:(int)resourceNumber totalResources:(int)totalResources;
@end


@interface HMUIWebView : UIWebView


AS_SIGNAL( WILL_START )		// 准备加载
AS_SIGNAL( DID_START )		// 开始加载
AS_SIGNAL( DID_LOAD_FINISH )		// 加载成功
AS_SIGNAL( DID_LOAD_FAILED )		// 加载失败
AS_SIGNAL( DID_LOAD_CANCELLED )	// 加载取消

AS_SIGNAL( DID_SCROLLDOWN )//向下滚动
AS_SIGNAL( DID_SCROLLUP )//向上滚动
AS_SIGNAL( DID_SCROLL )
AS_SIGNAL( DID_SCROLLEND )
AS_SIGNAL( DID_LOADING_PERSENT ) // 加载的进度 0-1


@property (nonatomic, HM_STRONG) NSString *				loadingURL;
@property (nonatomic, HM_STRONG) NSURL *				baseURL;
@property (nonatomic, HM_STRONG) NSError *					lastError;

@property (nonatomic, assign) UIWebViewNavigationType	navigationType;
@property (nonatomic, readonly) BOOL					isLinkClicked;
@property (nonatomic, readonly) BOOL					isFormSubmitted;
@property (nonatomic, readonly) BOOL					isFormResubmitted;
@property (nonatomic, readonly) BOOL					isBackForward;
@property (nonatomic, readonly) BOOL					isReload;

@property (nonatomic,assign) BOOL enableLog;

@property (nonatomic, HM_WEAK) NSString *	html;
@property (nonatomic, HM_WEAK) NSString *	file;
@property (nonatomic, HM_WEAK) NSString *	resource;
@property (nonatomic, HM_WEAK) NSString *	url;
//@property (nonatomic, HM_WEAK) id<HMUIWebViewProgressDelegate,UIWebViewDelegate> delegate;

@property (nonatomic, assign) int resourceCount;
@property (nonatomic, assign) int resourceCompletedCount;
@end

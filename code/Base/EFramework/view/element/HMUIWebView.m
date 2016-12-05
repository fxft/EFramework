//
//  HMUIWebView.m
//  GPSService
//
//  Created by Eric on 14-4-18.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIWebView.h"

@interface UIWebView ()
-(id)webView:(id)view identifierForInitialRequest:(id)initialRequest fromDataSource:(id)dataSource;
-(void)webView:(id)view resource:(id)resource didFinishLoadingFromDataSource:(id)dataSource;
-(void)webView:(id)view resource:(id)resource didFailLoadingWithError:(id)error fromDataSource:(id)dataSource;
@end

@interface HMUIWebView ()<UIWebViewDelegate,UIScrollViewDelegate,HMUIWebViewProgressDelegate>

@end

@implementation HMUIWebView
{
    NSString *	_loadingURL;
    NSError *	_lastError;
    BOOL		_inited;
    CGPoint     _scrollPoint;
}
DEF_SIGNAL( WILL_START )	// 准备加载
DEF_SIGNAL( DID_START )		// 开始加载
DEF_SIGNAL( DID_LOAD_FINISH )	// 加载成功
DEF_SIGNAL( DID_LOAD_FAILED )	// 加载失败
DEF_SIGNAL( DID_LOAD_CANCELLED )	// 加载取消

DEF_SIGNAL( REACH_TOP )
DEF_SIGNAL( REACH_BOTTOM )

DEF_SIGNAL( DID_SCROLLDOWN )
DEF_SIGNAL( DID_SCROLLUP )
DEF_SIGNAL( DID_SCROLL )
DEF_SIGNAL( DID_SCROLLEND )

DEF_SIGNAL( DID_LOADING_PERSENT )	// 加载进度 0-1


@synthesize loadingURL = _loadingURL;
@synthesize lastError = _lastError;

@synthesize navigationType = _navigationType;
@dynamic isLinkClicked;
@dynamic isFormSubmitted;
@dynamic isFormResubmitted;
@dynamic isBackForward;
@dynamic isReload;

@synthesize html;
@synthesize file;
@synthesize resource=_resource;
@synthesize url;
@synthesize baseURL;

@synthesize resourceCount;
@synthesize resourceCompletedCount;
//@synthesize delegate=_delegate;

- (void)initSelfDefault
{
    if ( NO == _inited )
    {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.scalesPageToFit = YES;
        self.allowsInlineMediaPlayback = YES;
        self.mediaPlaybackAllowsAirPlay = YES;
        self.mediaPlaybackRequiresUserAction = YES;
        self.scrollView.delegate = self;
        
        for ( UIView * subView in self.subviews )
        {
            for ( UIView * subView2 in subView.subviews )
            {
                if ( [subView2 isKindOfClass:[UIImageView class]] )
                {
                    subView2.hidden = YES;
                }
            }
        }
        
        _inited = YES;
    }
}

- (id)init
{
    if( (self = [super initWithFrame:CGRectZero]) )
    {

    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if( (self = [super initWithFrame:frame]) )
    {
        [self initSelfDefault];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self initSelfDefault];
}


- (void)dealloc
{
    self.loadingURL = nil;
    self.lastError = nil;
    self.baseURL = nil;
    HM_SUPER_DEALLOC();
}

#pragma mark -

- (void)setHtml:(NSString *)string
{
    [self loadHTMLString:string baseURL:self.baseURL];
}

- (void)setFile:(NSString *)path
{
    NSData * data = [NSData dataWithContentsOfFile:path];
    if ( data )
    {
        [self loadData:data MIMEType:@"text/html" textEncodingName:@"UTF8" baseURL:self.baseURL];
    }
}

- (void)setResource:(NSString *)path
{
    NSString * extension = [path pathExtension];
    NSString * fullName = [path substringToIndex:(path.length - extension.length - 1)];
    
    NSString * path2 = [[NSBundle mainBundle] pathForResource:fullName ofType:extension];
    NSData * data = [NSData dataWithContentsOfFile:path2];
    if ( data )
    {
        [self loadData:data MIMEType:@"text/html" textEncodingName:@"UTF8" baseURL:self.baseURL];
    }
}

- (void)setUrl:(NSString *)path
{
    if ( nil == path )
        return;
    
    NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    
    for ( NSHTTPCookie * cookie in cookies )
    {
        if ([path rangeOfString:cookie.domain].location==NSNotFound) {
            continue;
        }
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]]];
}

#pragma mark -

- (BOOL)isLinkClicked
{
    return UIWebViewNavigationTypeLinkClicked == _navigationType ? YES : NO;
}

- (BOOL)isFormSubmitted
{
    return UIWebViewNavigationTypeFormSubmitted == _navigationType ? YES : NO;
}

- (BOOL)isFormResubmitted
{
    return UIWebViewNavigationTypeFormResubmitted == _navigationType ? YES : NO;
}

- (BOOL)isBackForward
{
    return UIWebViewNavigationTypeBackForward == _navigationType ? YES : NO;
}

- (BOOL)isReload
{
    return UIWebViewNavigationTypeReload == _navigationType ? YES : NO;
}

#pragma mark -

-(id)webView:(id)view identifierForInitialRequest:(id)initialRequest fromDataSource:(id)dataSource
{
    NSURLRequest *request = initialRequest;
    
    INFO(request.URL,@"\n",request.allHTTPHeaderFields,@"\n",[request.HTTPBody asNSString]);
    resourceCount++;
    return [super webView:view identifierForInitialRequest:initialRequest fromDataSource:dataSource];
    
//    return [NSNumber numberWithInt:resourceCount++];
}

- (void)webView:(id)view resource:(id)resource didFailLoadingWithError:(id)error fromDataSource:(id)dataSource {
    [super webView:view resource:resource didFailLoadingWithError:error fromDataSource:dataSource];
    resourceCompletedCount++;
    if ([self.delegate respondsToSelector:@selector(webView:didReceiveResourceNumber:totalResources:)]) {
        [self.delegate webView:self didReceiveResourceNumber:resourceCompletedCount totalResources:resourceCount];
    }else
        [self sendSignal:[HMUIWebView DID_LOADING_PERSENT] withObject:@((CGFloat)resourceCompletedCount/resourceCount)];
}

-(void)webView:(id)view resource:(id)resource didFinishLoadingFromDataSource:(id)dataSource
{
    [super webView:view resource:resource didFinishLoadingFromDataSource:dataSource];
    resourceCompletedCount++;
    if ([self.delegate respondsToSelector:@selector(webView:didReceiveResourceNumber:totalResources:)]) {
        [self.delegate webView:self didReceiveResourceNumber:resourceCompletedCount totalResources:resourceCount];
    }else
    [self sendSignal:[HMUIWebView DID_LOADING_PERSENT] withObject:@((CGFloat)resourceCompletedCount/resourceCount)];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    self.loadingURL		= request.URL.absoluteString;
    self.navigationType	= navigationType;
    
    if ( nil == self.loadingURL || 0 == self.loadingURL.length )
    {
        ERROR( @"Invalid url" );
        return NO;
    }
    
//    	INFO( @"Loading url '%@'", self.loadingURL );
    
    HMSignal * signal = [self sendSignal:HMUIWebView.WILL_START];
    if ( nil == signal.returnValue )
        return YES;
    
    return [signal boolValue];
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self sendSignal:HMUIWebView.DID_START];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self sendSignal:HMUIWebView.DID_LOAD_FINISH];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.lastError = error;
    
    if ( [[error domain] isEqualToString:NSURLErrorDomain] )
    {
        if ( NSURLErrorCancelled == [error code] )
        {
            [self sendSignal:HMUIWebView.DID_LOAD_CANCELLED withObject:nil];
            return;
        }
    }
    
    if ( [error.domain isEqual:@"WebKitErrorDomain"] && error.code == 102 )
    {
        // 据说这个错误可以忽略掉
    }
    else
    {
        ERROR( @"%@", error );
        
        if ( error.code != 204 )
        {
            [self sendSignal:HMUIWebView.DID_LOAD_FAILED withObject:error];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self sendSignal:HMUIWebView.DID_SCROLL];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self sendSignal:HMUIWebView.DID_SCROLLEND];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [self sendSignal:HMUIWebView.DID_SCROLLEND];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _scrollPoint = scrollView.contentOffset;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    _scrollPoint = scrollView.contentOffset;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    CGPoint tt = *targetContentOffset;
//    INFO(@"%.1f_%.1f_%.1f",scrollView.contentOffset.y,_scrollPoint.y,tt.y);
    if (_scrollPoint.y - tt.y > 50) {
        [self sendSignal:HMUIWebView.DID_SCROLLUP];
    }else if (_scrollPoint.y - tt.y < -50&&tt.y!=0){
        [self sendSignal:HMUIWebView.DID_SCROLLDOWN];
    }
}


@end

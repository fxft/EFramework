//
//  HMUIImageView.m
//  CarAssistant
//
//  Created by Eric on 14-3-27.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIImageView.h"
#import "HMFoundation.h"


@implementation UIImage (UIImageView)

+ (UIImage *)imageCachedWithURL:(NSURL *)URL{
    return [UIImage imageCachedWithURL:URL defaultImage:nil];
}

+ (BOOL)imageCachedWithURL:(NSURL *)URL defaultImage:(UIImage*)image block:(void(^)(UIImage *))block{
    return [HMHTTPRequestOperation imageDataCachedWithURL:URL block:^(NSData *data) {
        UIImage *loadImage = image;
        if ([data isKindOfClass:[NSData class]]) {
            
            UIImage *_image= [UIImage imageWithDataAtScale:data scale:[UIScreen mainScreen].scale];
            if (_image) {
                [HMHTTPRequestOperation cachedImage:_image withURL:URL];
                loadImage = _image;
            }
            
        }else if ([data isKindOfClass:[UIImage class]]){
            loadImage = (id)data;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            block(loadImage);
        });
    }];
}

+ (UIImage *)imageCachedWithURL:(NSURL *)URL defaultImage:(UIImage*)image{
    NSData *data = [HMHTTPRequestOperation imageDataCachedWithURL:URL];
    if (data) {
        if ([data isKindOfClass:[UIImage class]]) {
            return (id)data;
        }
        UIImage *_image= [UIImage imageWithDataAtScale:data scale:[UIScreen mainScreen].scale];
        if (_image) {
            [HMHTTPRequestOperation cachedImage:_image withURL:URL];
            return _image;
        }
    }
    return image;
}

@end

@implementation UIImageView (HMUIImageView)

#pragma mark - swizzle
+ (void)load
{
    Method method1 = class_getInstanceMethod([self class], NSSelectorFromString(@"dealloc"));
    Method method2 = class_getInstanceMethod([self class], @selector(deallocSwizzle));
    method_exchangeImplementations(method1, method2);
}

- (void)deallocSwizzle
{
    
    [self disableHttpRespondersByTagString:nil];
    [self deallocSwizzle];
}


@dynamic gifPlay;

static int __gifPlayKEY;
-  (BOOL)gifPlay
{
    return [objc_getAssociatedObject( self, &__gifPlayKEY ) boolValue];
}

- (void)setGifPlay:(BOOL)gifPlay
{
    objc_setAssociatedObject( self, &__gifPlayKEY, [NSNumber numberWithBool:gifPlay], OBJC_ASSOCIATION_RETAIN_NONATOMIC );
    [self setImageWithImage:(self.gifImage==nil?self.image:self.gifImage)];
    
}

@dynamic gifImage;

static int __gifImageKEY;
-  (UIImage*)gifImage
{
    return objc_getAssociatedObject( self, &__gifImageKEY );
}

- (void)setGifImage:(UIImage*)gifImage
{
    objc_setAssociatedObject( self, &__gifImageKEY, gifImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

static int __defaultImageKEY;
-  (UIImage*)defaultImage
{
    return objc_getAssociatedObject( self, &__defaultImageKEY );
}

- (void)setDefaultImage:(UIImage *)defaultImage
{
    objc_setAssociatedObject( self, &__defaultImageKEY, defaultImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

static int __breakImageKEY;
-  (UIImage*)breakImage
{
    return objc_getAssociatedObject( self, &__breakImageKEY );
}

- (void)setBreakImage:(UIImage *)breakImage
{
    objc_setAssociatedObject( self, &__breakImageKEY, breakImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

@dynamic showProgress;

static int __showProgressKEY;
-  (BOOL)showProgress
{
    return [objc_getAssociatedObject( self, &__showProgressKEY ) boolValue];
}

- (void)setShowProgress:(BOOL)showProgress
{
    
    if (!showProgress) {
        self.progressView.hidden = YES;
        self.progressView.progress=0.f;
        [self.progressView removeFromSuperview];
    }else {
        self.progressView.hidden = NO;
        self.progressView.progress=0.f;
    }
    
    objc_setAssociatedObject( self, &__showProgressKEY, [NSNumber numberWithBool:showProgress], OBJC_ASSOCIATION_RETAIN_NONATOMIC );
    
}

static int __successBlockKEY;
-  (void (^)(AFHTTPRequestOperation *, id))successBlock
{
    return objc_getAssociatedObject( self, &__successBlockKEY );
}

- (void)setSuccessBlock:(void (^)(AFHTTPRequestOperation *, id))successBlock
{
    objc_setAssociatedObject( self, &__successBlockKEY, successBlock, OBJC_ASSOCIATION_COPY_NONATOMIC );
}

static int __failureBlockKEY;
-  (void (^)(AFHTTPRequestOperation *, NSError *))failureBlock
{
    return objc_getAssociatedObject( self, &__failureBlockKEY );
}

- (void)setFailureBlock:(void (^)(AFHTTPRequestOperation *, NSError *))failureBlock
{
    objc_setAssociatedObject( self, &__failureBlockKEY, failureBlock, OBJC_ASSOCIATION_COPY_NONATOMIC );
}


- (BOOL)isGif{
    if (self.image.images.count>1) {
        return YES;
    }
    return NO;
}

+ (instancetype)imageViewFor:(UIImage *)image{
    UIImageView *imageV = [[[self class] alloc]initWithImage:image];
    imageV.size = image.size;
    return [imageV autorelease];
}

- (instancetype)setImageViewFrame:(CGRect)rect{
    self.frame  = rect;
    return self;
}

- (instancetype)setImageViewContentMode:(UIViewContentMode)mode{
    self.contentMode = mode;
    return self;
}


- (HMUIProgressView *)progressView{
    HMUIProgressView *progress = nil;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[HMUIProgressView class]]&&view.tag==876874232) {
            progress = (id)view;
            break;
        }
    }
    if (progress==nil) {
        progress = [[[HMUIProgressView alloc]initWithFrame:CGRectMakeBound(30, 30)]autorelease];
        progress.roundedCorners = YES;
        progress.contentMode = UIViewContentModeCenter;
        progress.hidden = YES;
        progress.tag = 876874232;
    }
    progress.center = self.center;
    if (progress.superview!=self) {
        [self addSubview:progress];
    }
    
    return progress;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"frame"]) {
        if (self.showProgress) {
            self.progressView.center = self.center;
        }
    }
}

- (HMHTTPRequestOperation * )setImageWithURLString:(NSString *)url{
    return [self setImageWithURLString:url placeholderImage:nil];
}

- (HMHTTPRequestOperation * )setImageWithURLString:(NSString *)url placeholderImage:(UIImage *)placeholderImage{
    return [self setImageWithURLString:url placeholderImage:placeholderImage Success:nil failure:nil];
}

- (HMHTTPRequestOperation *)setImageWithURLString:(NSString *)url useCache:(BOOL)cache placeholderImage:(UIImage *)placeholderImage{
    return  [self setImageWithURLString:url placeholderImage:placeholderImage useCache:cache Success:nil failure:nil];
}
- (void)setImageWithImage:(UIImage *)image{
    
    if (image&&![image isKindOfClass:[UIImage class]]) {
        return;
    }
    if (!self.gifPlay&&image.images.count>0) {
        self.image = image.images.firstObject;
        self.gifImage = image;
        return;
    }
    self.image = image;
}

- (HMHTTPRequestOperation * )setImageWithURLString:(NSString *)url
                                  placeholderImage:(UIImage *)placeholderImage
                                           Success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    return  [self setImageWithURLString:url placeholderImage:placeholderImage useCache:YES Success:success failure:failure];
}

- (HMHTTPRequestOperation * )setImageWithURLString:(NSString *)url
                                  placeholderImage:(UIImage *)placeholderImage
                                          useCache:(BOOL)cache
                                           Success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
    if (![url notEmpty]) {
        if (placeholderImage) {
            self.defaultImage = placeholderImage;
            self.image = placeholderImage;
        }
        return nil;
    }
    
//    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSCharacterSet *URLCombinedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@" \"#%/:<>?@[\\]^`{|}"] invertedSet];
//    [url stringByAddingPercentEncodingWithAllowedCharacters:URLCombinedCharacterSet];
    
    NSURL *URL = [NSURL URLWithString:url];
    
    UIImage *localImage = [UIImage imageNamed:url];
    if (localImage==nil) {
        localImage = [UIImage imageWithContentsOfFile:[HMSandbox pathWithbundleName:nil fileName:url]];
    }
    if (localImage!=nil) {
        [self setImageWithImage:localImage];
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(nil,localImage);
            });
            
        }
        self.showProgress=NO;
        return nil;
    }
    
    if ([self.urlMap notEmpty]&&![self.urlMap isEqualToString:url]) {
        NSString *stringUrl = [[self.urlMap copy] autorelease];
        if (stringUrl) {
            [[HMHTTPRequestOperationManager sharedImageInstance] disableResponder:self  byStringUrl:stringUrl];
        }
    }
    
    self.urlMap = url;
    BOOL ret = NO;
    
    if (placeholderImage) {
        self.defaultImage = placeholderImage;
    }
//    LogTimeCostBegin(1)
    
    ret = [UIImage imageCachedWithURL:URL defaultImage:self.defaultImage block:^(UIImage *img) {
        [self setImageWithImage:img];
//        LogTimeCostEndTo(2, 1, @"加载图片花费时间")
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(nil,img);
            });
        }
    }];
    if (![url notEmpty]) {
        ret=YES;
    }
    if (ret) {
        self.showProgress=NO;
        return nil;
    }
    
    HMHTTPRequestOperation * operation = [self attemptingForURLString:url];
    if (operation) {
        if (self.showProgress) {
            [self.progressView setProgress:operation.uploadPercent animated:NO];
            operation.attentRecvProgress = YES;
        }
        operation.queuePriority = NSOperationQueuePriorityVeryHigh;
        return operation;
    }
    NSTimeInterval timeout = 60;
    if ([[[url pathExtension] lowercaseString] rangeOfString:@"gif"].location != NSNotFound) {
        timeout = 120;
    }
    
    operation = [[HMHTTPRequestOperationManager sharedImageInstance] GET_HTTP:url parameters:nil responder:self timeOut:timeout];
    
    if (self.showProgress) {
        self.progressView.center = self.center;
        operation.attentRecvProgress = YES;
    }
    operation.queuePriority = NSOperationQueuePriorityHigh;
    [operation setResponseType:HTTPResponseType_IMAGE];
    operation.order= AFDataCacheKeyFromURLRequest(URL);
    operation.useCache = cache;
    operation.shouldResume = YES;
    operation.refreshCache = YES;
    operation.badURLCheckAllow = YES;
    
    self.successBlock = success;
    self.failureBlock = failure;
    return  operation;
}

- (void)handleRequest:(HMHTTPRequestOperation *)request
{
    
    if ( request.recvProgressed )
    {
        if (self.showProgress) {
            if (![self.urlMap isEqualToString:request.url]) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progressView.center = self.center;
                
                [self.progressView setProgress:request.downloadPercent animated:YES];
            });
            
        }
    }
    else if ( request.sendProgressed )
    {
        if (self.showProgress) {
            if (![self.urlMap isEqualToString:request.url]) {
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progressView.center = self.center;
                [self.progressView setProgress:request.uploadPercent animated:YES];
            });
        }
    }
    else if ( request.created )
    {
        // TODO:
    }
    else if ( request.sending )
    {
        
    }
    else if ( request.recving )
    {
    }
    else if ( request.beCancelled )
    {
        if (self.showProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.showProgress = NO;
            });
        }
        if (self.failureBlock) {
            self.failureBlock(request,request.error);
        }
        self.failureBlock = nil;
        
    }
    else if ( request.paused )
    {
        
    }
    else if ( request.failed )
    {
        
        if ( request.timeOut)
        {
            
        }else{
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.showProgress = NO;
        });
        if (self.failureBlock) {
            self.failureBlock(request,request.error);
        }
        self.failureBlock = nil;
        UIImage *_image = nil;
        if (self.breakImage) {
            _image = self.breakImage;
        }else if (self.defaultImage){
            _image = self.defaultImage;
        }
        if (_image!=self.image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setImageWithImage:_image];
            });
        }
    }
    else if ( request.succeed )
    {
        if (request.responseObject) {
            
            if (![self.urlMap isEqualToString:request.url]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.showProgress = NO;
                });
                return;
            }
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                UIImage *_image= [UIImage imageWithDataAtScale:request.responseData scale:[UIScreen mainScreen].scale];
                NSURL *URL = [NSURL URLWithString:request.url];
                if (_image) {
                    [HMHTTPRequestOperation cachedImage:_image withURL:URL];
                }else{
                    [[HMMemoryCache sharedInstance] removeObjectForKey:AFDataCacheKeyFromURLRequest(URL)];
                    [[HMFileCache sharedInstance] removeObjectForKey:AFDataCacheKeyFromURLRequest(URL) branch:@"images"];
                    if (self.breakImage) {
                        _image = self.breakImage;
                    }else if (self.defaultImage){
                        _image = self.defaultImage;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setImageWithImage:_image];
                });
            });
            if (self.successBlock) {
                self.successBlock(request,request.responseData);
            }
            self.successBlock = nil;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.showProgress = NO;
        });
    }
    
}

@end

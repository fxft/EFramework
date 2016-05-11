//
//  HMUIImageView.h
//  CarAssistant
//
//  Created by Eric on 14-3-27.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMMacros.h"

@interface UIImage (UIImageView)

+ (UIImage *)imageCachedWithURL:(NSURL *)URL;
+ (UIImage *)imageCachedWithURL:(NSURL *)URL defaultImage:(UIImage*)image;
//先告诉你有数据，然后异步加载数据后用block回传
+ (BOOL)imageCachedWithURL:(NSURL *)URL defaultImage:(UIImage*)image block:(void(^)(UIImage *))block;
@end

@class AFHTTPRequestOperation;

@interface UIImageView (HMUIImageView)

/*if using gifplay  you must call - (void)setImageWithImage:(UIImage *)image  install of self.image = ?*/

@property (nonatomic, assign) BOOL	gifPlay;
/**/
@property (nonatomic, assign) BOOL	showProgress;

@property (nonatomic, HM_STRONG) UIImage *gifImage;

@property (nonatomic, HM_STRONG) UIImage *breakImage;

@property (nonatomic, HM_STRONG) UIImage *defaultImage;

@property (nonatomic, copy) void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject);
@property (nonatomic, copy) void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error);
///--------------------
/// @name Setting Image
///--------------------
/**
 涉及到网络请求图片，需要处理野指针问题 请在启动image下载时指定 tagString,并在imageView被销毁前调用 [self disableHttpRespondersByTagString:#tagString];
 */
/**
 Asynchronously downloads an image from the specified URL, and sets it once the request is finished. Any previous image request for the receiver will be cancelled.
 
 If the image is cached locally, the image is set immediately, otherwise the specified placeholder image will be set immediately, and then the remote image will be set once the request is finished.
 
 By default, URL requests have a `Accept` header field value of "image / *", a cache policy of `NSURLCacheStorageAllowed` and a timeout interval of 30 seconds, and are set not handle cookies. To configure URL requests differently, use `setImageWithURLRequest:placeholderImage:success:failure:`
 
 @param url The URL used for the image request.
 */
- (HMHTTPRequestOperation *)setImageWithURLString:(NSString *)url;

/**
 Asynchronously downloads an image from the specified URL, and sets it once the request is finished. Any previous image request for the receiver will be cancelled.
 
 If the image is cached locally, the image is set immediately, otherwise the specified placeholder image will be set immediately, and then the remote image will be set once the request is finished.
 
 By default, URL requests have a `Accept` header field value of "image / *", a cache policy of `NSURLCacheStorageAllowed` and a timeout interval of 30 seconds, and are set not handle cookies. To configure URL requests differently, use `setImageWithURLRequest:placeholderImage:success:failure:`
 
 @param url The URL used for the image request.
 @param placeholderImage The image to be set initially, until the image request finishes. If `nil`, the image view will not change its image until the image request finishes.
 */
- (HMHTTPRequestOperation * )setImageWithURLString:(NSString *)url
       placeholderImage:(UIImage *)placeholderImage;
/**
 *  设置网络图片
 *
 *  @param url 是完整的地址
 *  @param state
 *  note 注意释放控件前请积极调用 [self disableHttpRespondersByTagString:@"imgTagstring"]
 */
- (HMHTTPRequestOperation * )setImageWithURLString:(NSString *)url useCache:(BOOL)cache placeholderImage:(UIImage *)placeholderImage;

- (HMHTTPRequestOperation * )setImageWithURLString:(NSString *)url placeholderImage:(UIImage *)placeholderImage Success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (HMHTTPRequestOperation * )setImageWithURLString:(NSString *)url
             placeholderImage:(UIImage *)placeholderImage
                     useCache:(BOOL)cache
                      Success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)setImageWithImage:(UIImage*)image;
- (BOOL)isGif;

+ (instancetype)imageViewFor:(UIImage*)image;
- (instancetype)setImageViewContentMode:(UIViewContentMode)mode;
- (instancetype)setImageViewFrame:(CGRect)rect;

@end


//
//  HMServiceTencentWB.h
//  CarAssistant
//
//  Created by Eric on 14-4-29.
//  Copyright (c) 2014年 Eric. All rights reserved.
//
//Social.Security.Accounts for wb+

#import <Foundation/Foundation.h>

enum TCMediaType{
    TCMediaTypeImage  = 0,        /**< 分享图片    */
    TCMediaTypeMusic = 1,        /**< 分享音乐      */
    TCMediaTypeVideo = 2,        /**< 分享视屏       */
    TCMediaTypeWebpage  = 3,        /**< 分享页面    */
    TCMediaTypeText  = 7,        /**< 分享文本    */
    TCMediaTypeReplenish  = 100,        /**< 自定义    */

};

@interface HMServiceTencentWB : NSObject
AS_SINGLETON(HMServiceTencentWB)

@property (nonatomic, readonly) BOOL							installed;

@end

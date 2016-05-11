//
//  HMServiceWeChat.h
//  CarAssistant
//
//  Created by Eric on 14-4-28.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    WXTypeSceneSession  = 0,        /**< 聊天界面    */
    WXTypeSceneTimeline = 1,        /**< 朋友圈      */
    WXTypeSceneFavorite = 2,        /**< 收藏       */
}WXShareType;

typedef enum {
    WXSendTypeReq  = 0,        /**< 请求    */
    WXSendTypeResp = 1,        /**< 应答      */
}WXSendType;

enum WXMediaType{
    WXMediaTypeImage  = 0,        /**< 分享图片    */
    WXMediaTypeMusic = 1,        /**< 分享音乐      */
    WXMediaTypeVideo = 2,        /**< 分享视屏       */
    WXMediaTypeWebpage  = 3,        /**< 分享页面    */
    WXMediaTypeEmoticon = 4,        /**< 分享表情，jpg,png,gif等      */
    WXMediaTypeFile = 5,        /**< 分享文件       */
    WXMediaTypeAppExtend  = 6,        /**< 微信app扩展 NSData,其他分享均采用url方式  */
    WXMediaTypeText  = 7,        /**< 分享文本    */
};

@interface HMServiceWeChat : NSObject

AS_SINGLETON( HMServiceWeChat )

@property (nonatomic, readonly) BOOL							installed;

@property (nonatomic, assign)   WXShareType     shareType;
@property (nonatomic, assign)   WXSendType      sendType;

@end

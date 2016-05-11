//
//  HMServiceEmail.m
//  WestLuckyStar
//
//  Created by Eric on 14-5-13.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMServiceEmail.h"
#import <MessageUI/MessageUI.h>

@interface HMServiceEmail ()<MFMailComposeViewControllerDelegate>

@end

@implementation HMServiceEmail
DEF_SINGLETON(HMServiceEmail)

+ (void)registerApp:(NSString *)appid{
    
}

- (BOOL)installed{
    return [MFMailComposeViewController canSendMail];
}

- (void)shareBody:(HMShareItemObject *)body{
    if (self.installed) {
        MFMailComposeViewController *mailPicker = [[[MFMailComposeViewController alloc] init]autoreleaseARC];
        mailPicker.mailComposeDelegate = self;
        
        //设置主题
        if (body.title) {
            [mailPicker setSubject: body.title];
        }
        
//        //添加收件人
//        NSArray *toRecipients = [NSArray arrayWithObject: @"first@example.com"];
//        [mailPicker setToRecipients: toRecipients];
//        //添加抄送
//        NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
//        [mailPicker setCcRecipients:ccRecipients];
//        //添加密送
//        NSArray *bccRecipients = [NSArray arrayWithObjects:@"fourth@example.com", nil];
//        [mailPicker setBccRecipients:bccRecipients];
        
        // 添加一张图片
//        UIImage *addPic = [UIImage imageNamed: @"Icon@2x.png"];
//        NSData *imageData = UIImagePNGRepresentation(addPic);            // png
//        //关于mimeType：http://www.iana.org/assignments/media-types/index.html
//        [mailPicker addAttachmentData: imageData mimeType: @"" fileName: @"Icon.png"];
        if (body.thumb) {
            NSData *imageData = UIImagePNGRepresentation(body.thumb);            // png
            //关于mimeType：http://www.iana.org/assignments/media-types/index.html
            
            if (imageData) {
                [mailPicker addAttachmentData: imageData mimeType: @"" fileName: @"image.png"];
            }
        }
        //添加一个pdf附件
//        NSString *file = [self fullBundlePathFromRelativePath:@"高质量C++编程指南.pdf"];
//        NSData *pdf = [NSData dataWithContentsOfFile:file];
//        [mailPicker addAttachmentData: pdf mimeType: @"" fileName: @"高质量C++编程指南.pdf"];
        
//        NSString *emailBody = @"<font color='red'>eMail</font> 正文";
        if (body.description) {
            [mailPicker setMessageBody:body.description isHTML:NO];
        }        
        [HMShareService presentController:mailPicker];
        
//        [self postNotification:[HMShareService HMShareServiceRespone]
//                    withObject:[HMShareServiceResult spawnWith:HMShareTypeEmail
//                                                         state:HMPublishContentStateBegan
//                                                    statusInfo:nil
//                                                     errorCode:HMSuccess]];
        
    }else{
        [self postNotification:[HMShareService HMShareServiceRespone]
                    withObject:[HMShareServiceResult spawnWith:HMShareTypeEmail
                                                         state:HMPublishContentStateFail
                                                    statusInfo:nil
                                                     errorCode:HMErrCodeUnsupport]];
    }
}


#pragma mark - 实现 MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
   
    NSString *msg;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = @"用户取消编辑邮件";
            [self postNotification:[HMShareService HMShareServiceRespone]
                        withObject:[HMShareServiceResult spawnWith:HMShareTypeEmail
                                                             state:HMPublishContentStateCancel
                                                        statusInfo:msg
                                                         errorCode:HMErrCodeUserCancel]];

            break;
        case MFMailComposeResultSaved:
            msg = @"用户成功保存邮件";
            [self postNotification:[HMShareService HMShareServiceRespone]
                        withObject:[HMShareServiceResult spawnWith:HMShareTypeEmail
                                                             state:HMPublishContentStateCancel
                                                        statusInfo:msg
                                                         errorCode:HMErrCodeUserCancel]];
            break;
        case MFMailComposeResultSent:
            msg = @"用户点击发送，将邮件放到队列中，还没发送";
            [self postNotification:[HMShareService HMShareServiceRespone]
                        withObject:[HMShareServiceResult spawnWith:HMShareTypeEmail
                                                             state:HMPublishContentStateSuccess
                                                        statusInfo:msg
                                                         errorCode:HMSuccess]];
            break;
        case MFMailComposeResultFailed:
            msg = @"用户试图保存或者发送邮件失败";
            [self postNotification:[HMShareService HMShareServiceRespone]
                        withObject:[HMShareServiceResult spawnWith:HMShareTypeEmail
                                                             state:HMPublishContentStateFail
                                                        statusInfo:msg
                                                         errorCode:HMErrCodeSentFail]];
            break;
        default:
            msg = @"";
            break;
    }
    //关闭邮件发送窗口
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
    [HMShareService dismiss];
}

@end

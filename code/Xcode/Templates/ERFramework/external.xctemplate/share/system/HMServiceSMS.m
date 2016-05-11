//
//  HMServiceSMS.m
//  WestLuckyStar
//
//  Created by Eric on 14-5-13.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMServiceSMS.h"
#import <MessageUI/MessageUI.h>

@interface HMServiceSMS ()<HMShareServiceProtocol,MFMessageComposeViewControllerDelegate>

@end

@implementation HMServiceSMS
DEF_SINGLETON(HMServiceSMS)

+ (void)registerApp:(NSString *)appid{
    
}

- (BOOL)installed{
    return [MFMessageComposeViewController canSendText];
}

- (void)shareBody:(HMShareItemObject *)body{
    if (self.installed) {
        
        MFMessageComposeViewController *picker = [[[MFMessageComposeViewController alloc] init]autoreleaseARC];
        picker.messageComposeDelegate = self;
        NSString *smsBody = body.description==nil?body.title:body.description ;
        picker.body=smsBody;
        
//        [body.rootController presentViewController:picker animated:YES completion:nil ];
        [HMShareService presentController:picker];
        
//        [[HMShareService sharedInstance].window.rootViewController.view addSubview:picker.view];
//        [[HMShareService sharedInstance].window.rootViewController addChildViewController:picker];
//        
        [self postNotification:[HMShareService HMShareServiceRespone]
                    withObject:[HMShareServiceResult spawnWith:HMShareTypeSMS
                                                         state:HMPublishContentStateBegan
                                                    statusInfo:nil
                                                     errorCode:HMSuccess]];
        
    }else{
        [self postNotification:[HMShareService HMShareServiceRespone]
                    withObject:[HMShareServiceResult spawnWith:HMShareTypeSMS
                                                         state:HMPublishContentStateFail
                                                    statusInfo:nil
                                                     errorCode:HMErrCodeUnsupport]];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            
            [self postNotification:[HMShareService HMShareServiceRespone]
                        withObject:[HMShareServiceResult spawnWith:HMShareTypeSMS
                                                             state:HMPublishContentStateCancel
                                                        statusInfo:nil
                                                         errorCode:HMErrCodeUserCancel]];
            
            break;
        case MessageComposeResultSent:
            
            [self postNotification:[HMShareService HMShareServiceRespone]
                        withObject:[HMShareServiceResult spawnWith:HMShareTypeSMS
                                                             state:HMPublishContentStateSuccess
                                                        statusInfo:nil
                                                         errorCode:HMSuccess]];
            
            break;
        case MessageComposeResultFailed:
            
            [self postNotification:[HMShareService HMShareServiceRespone]
                        withObject:[HMShareServiceResult spawnWith:HMShareTypeSMS
                                                             state:HMPublishContentStateFail
                                                        statusInfo:nil
                                                         errorCode:HMErrCodeSentFail]];
            
            break;
        default:
            break;
    }
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
    [HMShareService dismiss];
    
}

@end

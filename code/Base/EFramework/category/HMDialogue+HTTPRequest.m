//
//  HMDialogue+HTTPRequest.m
//  CarAssistant
//
//  Created by Eric on 14-2-26.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMDialogue+HTTPRequest.h"
#import "HMHTTPRequestOperationManager.h"

@implementation HMDialogue (HTTPRequest)
//同步进行，防止异步operation会被释放，可能导致 dial的handle 处理request时出现野指针
- (void)handleRequest:(HMHTTPRequestOperation *)request
{
    
	if ( request.created )
	{
		// TODO:
	}
	else if ( request.sending )
	{
        [self internalNotifyActive];
      if ( request.sendProgressed )
      {
          [self internalNotifyProgressUpdated];
      }
	}
	else if ( request.recving )
	{
        [self internalNotifyActive];
      if ( request.recvProgressed )
      {
          [self internalNotifyProgressUpdated];
      }
	}
	else if ( request.beCancelled )
	{
        
        self.errorDomain = HMDialogue.ERROR_DOMAIN_CLIENT;
        self.errorCode = request.error.code;
        self.errorDesc = nil;

        self.cancelled = YES;
	}
    else if ( request.paused )
    {
//        self.paused = YES;
	}
    else if ( request.failed )
	{
       
        if ( self.timeout || request.timeOut)
		{
			self.errorDomain = HMDialogue.ERROR_DOMAIN_SERVER;
			self.errorCode = HMDialogue.ERROR_CODE_TIMEOUT;
			self.errorDesc = @"timeout";
            if (self.timeout) {
                request.timeOut = YES;
            }
            self.timeout = YES;
            
            
		}else{
            self.errorDomain = HMDialogue.ERROR_DOMAIN_NETWORK;
            self.errorCode = request.errorCode;
            self.errorDesc = request.errorDesc;
        }
        self.failed = YES;
	}
	else if ( request.succeed )
	{
        self.succeed = YES;
    }else if ( request.succeedOld )
    {
        self.succeed = YES;
    }
    
}

@end

@implementation NSObject (SafeForResponder)

- (void)selfWillRemoveOrCancel:(BOOL)RorC{
    
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( @"SafeDN",@"%@ responder for %@",RorC?@"remove":@"cancel",[self class]);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    if (RorC) {
        
        [HMDialogueQueue disableResponder:self];
        
        [HMHTTPRequestOperationManager disableResponder:self];
        
    }else{
        
        [HMDialogueQueue cancelDialogueByResponder:self];
        [HMHTTPRequestOperationManager cancelRequestByResponder:self];
        
    }
}

@end

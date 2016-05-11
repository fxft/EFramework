//
//  UserApi.m
//  EFExtend
//
//  Created by mac on 16/3/24.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "UserApi.h"

#define kENCRYPTKey @"d985ca5f92e3ed87a71753bbc4fbf5c9"
#define kENCRYPTIv  @"AFDFSDFSDFDSDSFE"

static NSDictionary * defaultHeader = nil;

@interface UserApi ()

@end

@implementation UserApi

#pragma mark - base

ON_WebAPI(dlg){
    
    if (dlg.sending) {
        [self callbackListenter:dlg.name bean:nil state:APIProcessLoading userinfo:[dlg webUserinfo] error:nil];
    }else if (dlg.succeed){
        
        NSDictionary *params = [dlg.output objectForKey:[HMWebAPI params]];
        WebAPIResult *result = [params objectForClass:[WebAPIResult class]];
        
        if (result.successI) {
            
            Class clazz = [self classForCommand:dlg.command];
            
            INFO(dlg.command,@"ouput is:",clazz);
            
            result.resultClass = clazz;
            
            [self callbackListenter:dlg.name bean:result state:APIProcessSucced userinfo:[dlg webUserinfo] error:nil];
            
        }else{
            
            [self callbackListenter:dlg.name bean:result state:APIProcessFailed userinfo:dlg error:nil];
        }
        
    }else if (dlg.failed){
        NSInteger state = APIProcessFailed;
        UserWebAPIResult *result = [[UserWebAPIResult alloc]init];
        result.success  = @(0);
        
        if (dlg.timeout) {
            state = APIProcessTimeOut;
            result.message = @"网络连接超时";
            result.error_code = @(-409);
        }else{
            result.message = @"网络连接失败";
            result.error_code = @(-408);
        }
        
        [self callbackListenter:dlg.name bean:result state:state userinfo:[dlg webUserinfo] error:nil];
        
    }else if (dlg.cancelled){
        
    }else if (dlg.progressed){
        
        [self callbackListenter:dlg.name bean:@(dlg.ownRequest.downloadPercent) state:APIProcessDataAppending userinfo:[dlg webUserinfo] error:nil];
    }
}


+ (void)setDefaultHeader:(NSDictionary *)header{
    defaultHeader = header;
    
}

#pragma mark - do it
- (HMDialogue *)postOrGet:(BOOL)ispost paras:(id)dic to:(NSString *)command alias:(NSString *)alias encrypt:(BOOL)encrypt asData:(dataType)asData form:(id<APICallBackProtocol>)receiver{
    [self observeListener:receiver forCommand:alias];
    
    Class cls = [[UserModel classNames] valueForKey:command];
    
    [self registerClassName:cls forCommand:command];
    
    NSData * encryptedData = dic;
    
    if (asData!=dataTypeAsPara&&![dic isKindOfClass:[NSData class]]) {
        
        encryptedData = [[dic isKindOfClass:[NSString class]]?(NSString*)dic:[dic JSONString] dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    if (encrypt&&[encryptedData isKindOfClass:[NSData class]]) {
        encryptedData = [[StringEncryption alloc] encrypt:encryptedData key:kENCRYPTKey iv:kENCRYPTIv];
    }
    
    HMDialogue *dia = [[[self webApiWithCommand:command timeout:20.f] setWebName:alias] setWebMethod:ispost?@"POST":@"GET"];
    
    if (dic) {
        [dia setWebUserinfo:dic];
    }
    
    
    if ([encryptedData isKindOfClass:[NSData class]]) {
        if (asData==dataTypeAsForm) {
            [dia setWebUploadBlock:^(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileData:encryptedData name:@"img" fileName:@"file" mimeType:@"application/form-data;"];
            }];
        }else{
            [dia setWebData:encryptedData];
        }
        
    }else if ([encryptedData isKindOfClass:[NSDictionary class]]){
        [dia setWebParams:dic];
    }
    
    if (defaultHeader) {
        [dia setWebHeaders:defaultHeader];
    }
    
    [dia send];
    return dia;
}

#pragma mark -

@end

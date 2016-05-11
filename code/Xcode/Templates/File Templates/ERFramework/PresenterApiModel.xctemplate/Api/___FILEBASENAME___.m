//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import "___FILEBASENAME___.h"

#define kENCRYPTKey @"d985ca5f92e3ed87a71753bbc4fbf5c9"
#define kENCRYPTIv  @"AFDFSDFSDFDSDSFE"

static NSDictionary * defaultHeader = nil;

@interface ___FILEBASENAMEASIDENTIFIER___ ()

@end

@implementation ___FILEBASENAMEASIDENTIFIER___

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
            
            [self callbackListenter:dlg.name bean:result state:APIProcessFailed userinfo:[dlg webUserinfo] error:nil];
        }
        
    }else if (dlg.failed){
        NSInteger state = APIProcessFailed;
        WebAPIResult *result = [[WebAPIResult alloc]init];
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
        
    }
}


+ (void)setDefaultHeader:(NSDictionary *)header{
    defaultHeader = header;
    
}

#pragma mark - do it
- (HMDialogue *)postOrGet:(BOOL)ispost paras:(id)dic to:(NSString *)command alias:(NSString *)alias encrypt:(BOOL)encrypt asData:(dataType)asData asform:(HTTPUploadDataBlock)block form:(id<APICallBackProtocol>)receiver{
    
    [self observeListener:receiver forCommand:alias];
    
    Class cls = [[Model classNames] valueForKey:command];
    
    [self registerClassName:cls forCommand:command];
    
    NSData * encryptedData = dic;
    
    //以二进制数据上传,数据将放到body里面
    if (asData==dataTypeAsData&&![dic isKindOfClass:[NSData class]]) {
        
        encryptedData = [[dic isKindOfClass:[NSString class]]?(NSString*)dic:[dic JSONString] dataUsingEncoding:NSUTF8StringEncoding];
    }
    //加密,只支持二进制数据
    if (encrypt&&[encryptedData isKindOfClass:[NSData class]]) {
        encryptedData = [[StringEncryption alloc] encrypt:encryptedData key:kENCRYPTKey iv:kENCRYPTIv];
    }
    
    HMDialogue *dia = [[[self webApiWithCommand:command timeout:20.f] setWebName:alias] setWebMethod:ispost?(asData==dataTypeAsForm?@"UPLOAD":@"POST"):@"GET"];
    
    if (dic) {
        [dia setWebUserinfo:dic];
    }
    
    if (asData==dataTypeAsData){
        
        [dia setWebData:encryptedData];
        
    }if (asData==dataTypeAsForm) {
        
        [dia setWebUploadBlock:^(id<AFMultipartFormData> formData) {
            
            if (block) {
                block(formData);
            }else if ([dic isKindOfClass:[NSDictionary class]]) {
                for (NSString *key in dic) {
                    NSString *value = [dic valueForKey:key];
                    NSError *error = nil;
                    if ([value isKindOfClass:[NSURL class]]) {
                        
                        [formData appendPartWithFileURL:(NSURL*)value name:key fileName:key mimeType:@"application/form-data;" error:&error];
                        if (error) {
                            CC(@"HTTP",error);
                        }
                    }else if (![value isKindOfClass:[NSString class]]&&[value respondsToSelector:@selector(description)]){
                        
                        value = [value description];
                        
                    }else if (![value isKindOfClass:[NSString class]]){
                        CC(@"HTTP",@"error",command,key);
                        continue;
                    }
                    
                    [formData appendPartWithFormData:[NSData dataWithBytes:[value UTF8String] length:value.length] name:key];
                    
                }
            }
            
        }];
        
    }else{
        
        [dia setWebParams:dic];
        
    }
    
    if (defaultHeader) {
        [dia setWebHeaders:defaultHeader];
    }
    
    [dia send];
    return dia;
}

- (HMDialogue *)postOrGet:(BOOL)ispost paras:(id)dic to:(NSString *)command alias:(NSString *)alias encrypt:(BOOL)encrypt asData:(dataType)asData form:(id<APICallBackProtocol>)receiver{
    
    return [self postOrGet:ispost paras:dic to:command alias:alias encrypt:encrypt asData:asData asform:nil form:receiver];
    
}

- (HMDialogue *)postParas:(id)dic to:(NSString *)command alias:(NSString *)alias encrypt:(BOOL)encrypt asform:(HTTPUploadDataBlock)block form:(id<APICallBackProtocol>)receiver{
    
    return [self postOrGet:YES paras:dic to:command alias:alias encrypt:encrypt asData:dataTypeAsForm asform:block form:receiver];
    
}


#pragma mark -

@end

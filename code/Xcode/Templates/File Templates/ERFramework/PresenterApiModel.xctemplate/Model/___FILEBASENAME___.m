//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import "___FILEBASENAME___.h"
#pragma mark - base

@implementation WebAPIResult{
    id            _resultObject;
    Class         _resultClass;
}

@synthesize message;
@synthesize error_code;
@synthesize success;
@synthesize result=_result;
@synthesize resultClass=_resultClass;
@synthesize resultObject = _resultObject;
@synthesize successI;
@synthesize error_codeI;

- (void)setResult:(NSObject *)Result{
    
    _result = nil;
    if (![Result isKindOfClass:[NSNull class]]) {
        _result = Result ;
    }
}

- (void)setResultClass:(Class)resultClass{
    if (self.result) {
        NSString *ss = NSStringFromClass(resultClass);
        if ([ss isEqualToString:@"NSNull"]) {
            self.resultObject = self.result;
            return;
        }
        if ([self.result isKindOfClass:[NSDictionary class]]) {
            self.resultObject = [(NSDictionary*)self.result objectForClass:resultClass];
        }else if ([self.result isKindOfClass:[NSArray class]]){
            self.resultObject = [resultClass objectsFromArray:self.result];
        }else if ([self.result isKindOfClass:[NSNull class]]){
            self.resultObject = nil;
        }else{
            self.resultObject = self.result;
        }
    }
}

- (BOOL)successI{
    return [self.success boolValue];
}

- (NSInteger)error_codeI{
    return [self.error_code integerValue];
}

- (void)dealloc
{
    self.message = nil;
    self.result = nil;
    self.success = nil;
    self.error_code = nil;
    self.resultObject = nil;
    HM_SUPER_DEALLOC();
}

@end

#pragma mark - model base
@implementation NSString (ModelMock)

- (id)valueForUndefinedKey:(NSString *)key{
    
    if ([self rangeOfString:[HMWebAPI methodMock]].location!=NSNotFound) {
        id respondObject = nil;
        /*
         //message = "";
         //result =     {
         //    user = "\U767b\U5f55\U6210\U529f";
         //    pwd = 3;
         //};
         //error_code = 1;
         //success = 1;
         */
        NSDictionary *resultDic = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"ModelResultClass" withExtension:@"plist"]];
        NSDictionary *data = [resultDic objectForKey:key];
        
        if ([self isEqualToString:[HMWebAPI methodMock]]||[self isEqualToString:[HMWebAPI methodMockSuccess]]) {
            NSString *output = [data objectForKey:@"output"];
            
            respondObject = @{@"message": @"",@"error_code":@(0),@"success":@(1),@"result":[output notEmpty]?[output JSONObject]:[NSNull null]};
            
        }else if ([self isEqualToString:[HMWebAPI methodMockFail]]) {
            NSString *output = [data objectForKey:@"outputFail"];
            
            respondObject = @{@"message": [NSString stringWithFormat:@"%@ 发生错误",key],@"error_code":@(1),@"success":@(0),@"result":[output notEmpty]?[output JSONObject]:[NSNull null]};
            
        }else if ([self isEqualToString:[HMWebAPI methodMockTimeOut]]) {
            
            respondObject = @{@"message": @"服务器超时",@"error_code":@(-121),@"success":@(0),@"result":[NSNull null]};
        }
        
        return respondObject;
    }else{
        return [super valueForUndefinedKey:key];
    }
}

@end


@implementation ___FILEBASENAME___

+(void)logModel{
#if (__ON__ == __HM_DEVELOPMENT__)
    NSDictionary *resultDic = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"ModelResultClass" withExtension:@"plist"]];
    
    for (NSString *command in resultDic.allKeys) {
        
        NSDictionary *data = [resultDic objectForKey:command];
        NSDictionary *sample = [[data objectForKey:@"output"] JSONObject];
        NSDictionary *input = [[data objectForKey:@"input"] JSONObject];
        BOOL ok = [[data objectForKey:@"ok"] boolValue];
        if (ok) {
            continue;
        }
        
        CC( [self.class description],@"#pragma mark - ===========prit===========  ",command,@"",@"\n/*%@%@*/",[data objectForKey:@"des"],[data objectForKey:@"input"]);
        
        NSString *markend = @"\n*/\n\n";
        NSString *markstart = @"\n\n/*\n";
        //打印定义操作名
        NSMutableString *as_string = [NSMutableString stringWithFormat:@"#pragma mark %@\nAS_STRING(%@)\n",command,command];
        //打印实现操作名
        NSMutableString *def_string = [NSMutableString stringWithFormat:@"#pragma mark %@\nDEF_STRING(%@,@\"%@\")\n",command,command,command];
        //打印初始化方法
        NSMutableString *restore_string = [NSMutableString stringWithFormat:@"#pragma mark %@ methd\n- (void)doReset%@Attributes:(NSArray *)attributeBinded{",command,command];
        //打印验证方法
        NSMutableString *verity_string = [NSMutableString stringWithFormat:@"- (BOOL)doVerity%@Attributes:(NSArray*)attributeBinded{%@1、进行数据有效性判断\n2、给出必要的提示或不提示\n使用者均可使用[ verityThem:forsomething:]进行判断%@",command,markstart,markend];
        NSMutableString *verity_string_midle = [NSMutableString stringWithFormat:@"\n"];
        //打印操作执行方法
        NSMutableString *do_string = [NSMutableString stringWithFormat:@"- (id)do%@Attributes:(NSDictionary *)attributeBinded{\n\n",command];
        
        NSMutableString *send_string = [NSMutableString stringWithFormat:@"\nNSDictionary *dic = @{\n"];
        NSMutableString *test_string = [NSMutableString stringWithFormat:@"\n#ifdef DEBUG\n"];
        
        
        [restore_string appendFormat:@"%@1、可以初始化视图\n2、可以初始化数据\n使用者均可使用[ fillThem:forsomething:]初始化操作\n\nUITextField *input = [self getOutput:self.xxxIO_xxx];\ninput.txt = @\"test\"\n%@",markstart,markend];
        
        NSString * send_string_bg = [NSString stringWithFormat:@"};\nreturn [self.api postOrGet:NO paras:dic to:@\"%@\" alias:[self %@] encrypt:NO asData:dataTypeAsPara form:self];\n}\n\n",command,command];
        
        //实现api协议回调
        NSString *  api_string = [NSString stringWithFormat:@"\n- (BOOL)do%@Api:(API *)api doSome:(NSString *)something bean:(id)bean state:(APIProcess)state userinfo:(id)userinfo error:(NSError *)error{\n\nif (state == APIProcessSucced||state == APIProcessOldData) {\n\n[self showMessageTip:nil detail:@\"登陆成功\" timeOut:1.5f];\n\n}else if (state == APIProcessLoading) {\n[self showMessageTip:nil detail:@\"正在登陆...\" timeOut:30.f];\n}else if (state == APIProcessTimeOut) {\n[self showMessageTip:nil detail:@\"超时\" timeOut:1.5];\n}else if (state == APIProcessFailed) {\n[self showMessageTip:nil detail:@\"失败\" timeOut:1.5f];\n}else{\n[self showMessageTip:nil detail:bean.message timeOut:1.5f];\n}\nreturn YES;\n}\n\n",command];
        
        //拼接属性
        for (NSString *key in input.allKeys) {
            [as_string appendFormat:@"AS_STRING(%@IO_%@)\n",command,key];
            [def_string appendFormat:@"DEF_STRING(%@IO_%@,@\"%@IO_%@\")\n",command,key,command,key];
            [verity_string appendFormat:@"NSString *  %@ = [self doReStore:self.%@IO_%@];\n",key,command,key];
            [verity_string_midle appendFormat:@"if (![%@ notEmpty]&&[attributeBinded containsObject:self.%@IO_%@]) {\n[self showMessageTip:nil detail:@\"没有%@\" timeOut:1.5f];\nreturn NO;\n}\n\n",key,command,key,key];
            [do_string appendFormat:@"NSString *  %@ = [self doReStore:self.%@IO_%@];\n",key,command,key];
            [test_string appendFormat:@"%@ = @\"%@\";\n",key,[input valueForKey:key]];
            [send_string appendFormat:@"@\"%@\":%@,\n",key,key];
        }
        
        [restore_string appendString:@"\n}\n\n"];
        [verity_string appendString:verity_string_midle];
        [verity_string appendString:@"\n return YES;\n}\n\n"];
        [test_string appendString:@"#endif\n"];
        
        [do_string appendString:test_string];
        [do_string appendString:send_string];
        [do_string appendString:send_string_bg];
        
#if (__ON__ == __HM_DEVELOPMENT__)
        CC( [self.class description],
           @"=====asstring=====\n",
           as_string,
           @"=====defstring=====\n",
           def_string,
           restore_string,
           verity_string,
           do_string,
           api_string);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
        if (!ok) {
            [sample pritfMemberForClassName:command coding:NO numberAnalysis:NO];
        }
        
    }
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
}


+ (NSDictionary*)classNames{
    return @{@"api.do?register":[NSNull class],
             @"api.do?resetPwd":[NSNull class],
             @"api.do?changePwd":[NSNull class],
             @"api.do?logout":[NSNull class]
             };
}
@end

#pragma mark -

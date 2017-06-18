//
//  APIGateway.m
//  EFDemo
//
//  Created by mac on 16/5/26.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "APIGateway.h"
#import "AliEncryption.h"

@interface APIGateway ()

@end

@implementation APIGateway

- (void)dealloc
{
   
    HM_SUPER_DEALLOC();
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.customNavLeftBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [self.customNavLeftBtn setFrame:CGRectMakeBound(32, 32)];
    
    [self.customNavRightBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [self.customNavRightBtn setFrame:CGRectMakeBound(32, 32)];

    
    [self initDatas];
    
    [self initSubviews];
}

- (void)initDatas{
    
}

- (void)initSubviews{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

ON_Button(signal){
    UIButten *btn = signal.source;
    if ([signal is:[UIButten TOUCH_UP_INSIDE]]) {
        if ([btn is:@"leftBtn"]) {//customNavLeftBtn
            [self backAndRemoveWithAnimate:YES];
        }else if ([btn is:@"rightBtn"]){//customNavRightBtn
            [self testiot];
        }
    }
}

//#define POSTFORM //通过表单的方式上传
#define POSTBODY //通过body的方式上传

- (void)test{


    
    
    NSMutableDictionary *requestHeaders = [NSMutableDictionary dictionaryWithCapacity:0];
    
    //阿里云需要的数据
    [requestHeaders setValue:@"23368163" forKey:X_CA_KEY];
//    [requestHeaders setValue:@"23371405" forKey:X_CA_KEY];
    
    //设置Http标准头
#ifdef POSTFORM
    NSString *boundary = CONTENT_TYPE_BOUNDARY;
    //使用了AFNerworking，有个变态的做法（详见请求部分）
    [requestHeaders setValue:CONTENT_TYPE_FORM(boundary) forKey:HTTP_HEADER_CONTENT_TYPE];
    
#else
    [requestHeaders setValue:CONTENT_TYPE_QUERY forKey:HTTP_HEADER_CONTENT_TYPE];
#endif
    
    
    [requestHeaders setValue:@"application/json" forKey:HTTP_HEADER_ACCEPT];
    
    
    //可选Api网关头部
    [requestHeaders setValue:[AliEncryption timestamp] forKey:X_CA_TIMESTAMP];//API调用者传递时间戳，为时间转换为毫秒的值，也就是从1970年1月1日起至今的时间转换为毫秒，可选，默认15分钟内有效
    
    [requestHeaders setValue:[AliEncryption nonce] forKey:X_CA_NONCE];//API调用者生成UUID，结合时间戳进行防重放，可选
    
//    [requestHeaders setValue:X_CA_STAGE_TEST forKey:X_CA_STAGE];//请求API所属Stage，目前仅支持test和release，默认release。
    
    //业务需要的头部
    NSDictionary *headDic = @{
                              @"token":@"",
                              @"version":@"1.0",
                              @"appkey":@"123456789",
//                              @"appkey2":[@"我怎么了" formatURLEnocde],//中文要转码
                              };
    
    [requestHeaders setValuesForKeysWithDictionary:headDic];
    //业务需要的参数
    NSDictionary *paramDic = @{@"status":@"1",@"test2":@"2344"};
    paramDic = @{
                  @"username":@"13489184949",
                  @"password":[@"pppppp".MD5String lowercaseString],
                  @"deviceToken":@""
                  };
    NSDictionary *signParam = paramDic;
    
    //如果POST数据是二进制数据，可以计算出Content_MD5，不建议使用该方式（主要是AF的Session不支持）
    NSData *body = [NSData data];//需要post的数据,请按实际情况替换
#ifdef POSTBODY
    
    body = [[AliEncryption queryString:paramDic] dataUsingEncoding:NSUTF8StringEncoding];
#endif
    if (body.length) {
        const char *bytes = [body bytes];
        NSString *content_MD5 = [[NSString stringWithCString:bytes encoding:NSUTF8StringEncoding] MD5String];
        
        [requestHeaders setValue:content_MD5 forKey:HTTP_HEADER_CONTENT_MD5];//当请求Body非Form表单时，可以计算Body的MD5值传递给云网关进行Body MD5校验
    }

    /**
     *  扰乱加密串
     */
//    [Encryption sharedInstance].secretForApiGateway = @"3c0f6fba687fa2aaad125a223c7f1a09";
//    
//    NSString *path = @"/ttt";
//    NSString *method = @"GET";
    
//    [AliEncryption sharedInstance].secretForApiGateway = @"c20755aa46160b05474925f27dd82cdb";
//    
//    NSString *path = @"/UnUseCouponList";//
//    NSString *method = @"POST";//
    
    [AliEncryption sharedInstance].secretForApiGateway = @"3c8814f38187d52d78e671edeb563eb4";
    
    NSString *path = @"/Api/User/Login";//
    NSString *method = @"POST";//
    
    NSString *signatureKey = nil;
    NSString *signStr = [AliEncryption signature:[AliEncryption prepareAPIGatewayForSignWithMethod:method headers:requestHeaders param:signParam path:path signHeaderKey:&signatureKey]];
    
    //设置参与签名的头部
    [requestHeaders setValue:signStr forKey:X_CA_SIGNATURE];//签名字符串,将计算的签名放到Request的Header中，Key为：X-Ca-Signature
    [requestHeaders setValue:signatureKey forKey:X_CA_SIGNATURE_HEADERS];//将所有参与加签的Header的Key使用英文逗号分割放到Request的Header中，不区分顺序，Key为：X-Ca-Signature-Headers
    
    INFO(@"=====signStr: %@ \n=====signatureKey:%@",signStr,signatureKey);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer.acceptableContentTypes = nil;
    //设置Http头部
    for (NSString *key in requestHeaders) {
        [manager.requestSerializer setValue:[requestHeaders valueForKey:key] forHTTPHeaderField:key];
    }
    
    NSString *url = @"http://apitest.jjicar.com/UnUseCouponList";
    url = @"http://apitest.jjicar.com/Api/User/Login";
//    url = @"http://api.jjicar.com/User/Login";
#ifdef POSTFORM
    [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSObject *fff = (id)formData;
        //通过表单的方式必须使用这个方式修改AFNetworking
        if (![fff respondsToSelector:NSSelectorFromString(@"boundary")]) {
            NSAssert(false, @"AF formData have no boundary");
        }
        [fff setValue:boundary forKey:@"boundary"];
        for (NSString *key in paramDic.allKeys) {
            [formData appendPartWithFormData:[[paramDic valueForKey:key] dataUsingEncoding:NSUTF8StringEncoding] name:key];
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, NSData*  _Nonnull responseObject) {
        NSLog(@"%@",task.currentRequest.allHTTPHeaderFields);
        NSLog(@"lalalal%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"--------%@",error.description);
    }];
#else
    [manager POST:url parameters:paramDic success:^(NSURLSessionDataTask * _Nonnull task, NSData*  _Nonnull responseObject) {
        NSLog(@"lalalal%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"--------%@",error.description);
    }];
#endif
}


- (void)testiot{
    
    
    
    
    NSMutableDictionary *requestHeaders = [NSMutableDictionary dictionaryWithCapacity:0];
    
    //阿里云需要的数据
    [requestHeaders setValue:@"fxft44Bo32D5dYu" forKey:X_CA_KEY];
    //    [requestHeaders setValue:@"23371405" forKey:X_CA_KEY];

    
    
    //可选Api网关头部
    [requestHeaders setValue:[AliEncryption timestamp] forKey:X_CA_TIMESTAMP];//API调用者传递时间戳，为时间转换为毫秒的值，也就是从1970年1月1日起至今的时间转换为毫秒，可选，默认15分钟内有效
    
    [requestHeaders setValue:[AliEncryption nonce] forKey:X_CA_NONCE];//API调用者生成UUID，结合时间戳进行防重放，可选
    
    [requestHeaders setValue:@"1494409040000" forKey:X_CA_TIMESTAMP];
    [requestHeaders setValue:@"6A40AC1D823DFB4C52E781E1C7EC49BD1494409040000" forKey:X_CA_NONCE];
    
    [requestHeaders setValue:@"1494574236346" forKey:X_CA_TIMESTAMP];
    [requestHeaders setValue:@"389ef1b4-1a29-4bce-8d42-f93edd5729cd" forKey:X_CA_NONCE];
    
    //    [requestHeaders setValue:X_CA_STAGE_TEST forKey:X_CA_STAGE];//请求API所属Stage，目前仅支持test和release，默认release。
    
    //业务需要的参数
    NSDictionary *paramDic = @{@"status":@"1",@"test2":@"2344"};
    paramDic = @{
                 @"cNo":@"1064890809999"
                 };
//    paramDic = nil;
//    paramDic = @{
//                 @"cNo2":@"1064890809999"
//                 };
    NSDictionary *signParam = paramDic;
    
    //如果POST数据是二进制数据，可以计算出Content_MD5，不建议使用该方式（主要是AF的Session不支持）
    NSString *body= nil;// = [NSData data];//需要post的数据,请按实际情况替换
#ifdef POSTBODY
    
    body = [AliEncryption queryString:paramDic];//[[AliEncryption queryString:paramDic] dataUsingEncoding:NSUTF8StringEncoding];
#endif
    if (body.length) {
//        const char *bytes = [body bytes];
        NSString *bodystring = body;//[NSString stringWithCString:bytes encoding:NSUTF8StringEncoding];
        NSString *content_MD5 = [[bodystring MD5String] lowercaseString];
       NSString *content_MD5_Base64 = [[NSData dataWithBytes:content_MD5.UTF8String length:content_MD5.length] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        [requestHeaders setValue:content_MD5_Base64 forKey:HTTP_HEADER_CONTENT_MD5];//当请求Body非Form表单时，可以计算Body的MD5值传递给云网关进行Body MD5校验
    }else{
        
        [requestHeaders setValue:@"ZDQxZDhjZDk4ZjAwYjIwNGU5ODAwOTk4ZWNmODQyN2U=" forKey:HTTP_HEADER_CONTENT_MD5];
    }
    
    /**
     *  扰乱加密串
     */
    //    [Encryption sharedInstance].secretForApiGateway = @"3c0f6fba687fa2aaad125a223c7f1a09";
    //
    //    NSString *path = @"/ttt";
    //    NSString *method = @"GET";
    
    //    [AliEncryption sharedInstance].secretForApiGateway = @"c20755aa46160b05474925f27dd82cdb";
    //
    //    NSString *path = @"/UnUseCouponList";//
    //    NSString *method = @"POST";//
    
    [AliEncryption sharedInstance].secretForApiGateway = @"36687f2ad296836c158aecc2459c200a";
    
    NSString *path = @"http://iot.fxftcar.com/Api/CardState";//
    NSString *method = @"POST";//@"GET";//
    
    NSString *signatureKey = nil;
    NSString *signStr = [AliEncryption signature:[AliEncryption prepareIotAPIGatewayForSignWithMethod:method headers:requestHeaders param:signParam path:path signHeaderKey:&signatureKey]];
    
    //设置参与签名的头部
    [requestHeaders setValue:signStr forKey:X_CA_SIGNATURE];//签名字符串,将计算的签名放到Request的Header中，Key为：X-Ca-Signature
//    [requestHeaders setValue:signatureKey forKey:X_CA_SIGNATURE_HEADERS];//将所有参与加签的Header的Key使用英文逗号分割放到Request的Header中，不区分顺序，Key为：X-Ca-Signature-Headers
    
    INFO(@"=====signStr: %@ \n=====signatureKey:%@",signStr,signatureKey);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer.acceptableContentTypes = nil;
    //设置Http头部
    for (NSString *key in requestHeaders) {
        [manager.requestSerializer setValue:[requestHeaders valueForKey:key] forHTTPHeaderField:key];
    }
    
    NSString *url = @"http://apitest.jjicar.com/UnUseCouponList";
    url = @"http://iot.fxftcar.com/Api/CardState";
    //    url = @"http://api.jjicar.com/User/Login";
    
    
    //设置Http标准头
#ifdef POSTFORM
    NSString *boundary = CONTENT_TYPE_BOUNDARY;
    //使用了AFNerworking，有个变态的做法（详见请求部分）
    [requestHeaders setValue:CONTENT_TYPE_FORM(boundary) forKey:HTTP_HEADER_CONTENT_TYPE];
    
#else
    [requestHeaders setValue:CONTENT_TYPE_QUERY forKey:HTTP_HEADER_CONTENT_TYPE];
#endif
    
    
    [requestHeaders setValue:@"application/json" forKey:HTTP_HEADER_ACCEPT];
    
    //业务需要的头部
    NSDictionary *headDic = @{
                              @"token":@"",
                              @"version":@"1.0",
                              @"appkey":@"123456789",
                              //                              @"appkey2":[@"我怎么了" formatURLEnocde],//中文要转码
                              };
    
    [requestHeaders setValuesForKeysWithDictionary:headDic];
    
#ifdef POSTFORM
    [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSObject *fff = (id)formData;
        //通过表单的方式必须使用这个方式修改AFNetworking
        if (![fff respondsToSelector:NSSelectorFromString(@"boundary")]) {
            NSAssert(false, @"AF formData have no boundary");
        }
        [fff setValue:boundary forKey:@"boundary"];
        for (NSString *key in paramDic.allKeys) {
            [formData appendPartWithFormData:[[paramDic valueForKey:key] dataUsingEncoding:NSUTF8StringEncoding] name:key];
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, NSData*  _Nonnull responseObject) {
        NSLog(@"%@",task.currentRequest.allHTTPHeaderFields);
        NSLog(@"lalalal%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"--------%@",error.description);
    }];
#else
    
    if ([method isEqualToString:@"GET"]) {
        [manager GET:url parameters:paramDic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSLog(@"%@\n,%s\n,%@\n",task.currentRequest.URL,task.originalRequest.HTTPBody.bytes,task.currentRequest.allHTTPHeaderFields);
            NSLog(@"lalalal%@",responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"--------%@",error.description);
        }];

    }else{
        [manager POST:url parameters:paramDic success:^(NSURLSessionDataTask * _Nonnull task, NSData*  _Nonnull responseObject) {
            NSLog(@"%@\n,%s\n,%@\n",task.currentRequest.URL,task.originalRequest.HTTPBody.bytes,task.currentRequest.allHTTPHeaderFields);
            NSLog(@"lalalal%@",responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"--------%@",error.description);
        }];
    }
    
#endif
    
}

@end

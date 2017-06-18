//
//  API.m
//  EFExtend
//
//  Created by mac on 15/3/27.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import "API.h"

@interface API ()
@property (nonatomic,HM_STRONG)NSMutableDictionary *listenters;
@property (nonatomic,HM_STRONG)NSMutableDictionary *clazzes;

@end

@implementation API
@synthesize listenters;
@synthesize delegate;
@synthesize clazzes;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.listenters = [NSMutableDictionary dictionary];
        self.clazzes = [NSMutableDictionary dictionary];
    }
    return self;
}
- (void)dealloc
{
    self.listenters = nil;
    self.clazzes = nil;
    self.delegate = nil;
    [self webApiCancelAndDisableName:nil];
    
    HM_SUPER_DEALLOC();
}

+ (instancetype)api{
    API *api = [[[[self class] alloc]init]autorelease];
    
    return api;
}

- (void)registerCommand:(NSString *)command{
    @synchronized(self.listenters){
        if (![command empty]) {
            NSMutableArray *arry = [self.listenters objectForKey:command];
            if (arry==nil) {
                arry= [NSMutableArray nonRetainingArray];
                [self.listenters setObject:arry forKey:command];
            }
        }
    }
}

- (Class)classForCommand:(NSString*)command{
    return [self.clazzes valueForKey:command];
}

- (void)registerClassName:(Class)clazz forCommand:(NSString *)command{
    [self registerCommand:command];
    if (!clazz) {
        return;
    }
    @synchronized(self.clazzes){
        [self.clazzes setValue:clazz forKey:command];
    }
}

- (NSArray *)observeListenersForCommand:(NSString *)command{
    @synchronized(self.listenters){
        if (![command empty]) {
            NSMutableArray *arry = [self.listenters objectForKey:command];
            return arry;
        }
    }
    
    return nil;
}

- (void)unobserveListenersForCommand:(NSString *)command{
    @synchronized(self.listenters){
        if (![command empty]) {
            [self.listenters removeObjectForKey:command];
        }else{
            [self.listenters removeAllObjects];
        }
    }
}

- (void)unobserveListener:(id<APICallBackProtocol>)Listener forCommand:(NSString *)command{
    if (Listener) {
        @synchronized(self.listenters){
            if (![command empty]) {
                NSMutableArray *arry = [self.listenters objectForKey:command];
                if ([arry containsObject:Listener]) {
                    [arry removeObject:Listener];
                }
            }else{
                for (NSMutableArray *array in self.listenters.allValues) {
                    if ([array containsObject:Listener]) {
                        [array removeObject:Listener];
                    }
                }
            }
        }
    }
}

- (void)observeListener:(id<APICallBackProtocol>)Listener forCommand:(NSString *)command{
    if (Listener) {
        @synchronized(self.listenters){
            if (![command empty]) {
                NSMutableArray *arry = [self.listenters objectForKey:command];
                if (arry==nil) {
                    arry= [NSMutableArray nonRetainingArray];
                    [self.listenters setObject:arry forKey:command];
                }
                if (![arry containsObject:Listener]) {
                    [arry addObject:Listener];
                }
            }else{
                for (NSMutableArray *array in self.listenters.allValues) {
                    if (![array containsObject:Listener]) {
                        [array addObject:Listener];
                    }
                }
            }
        }
    }
}

- (void)callbackListenter:(NSString*)command bean:(id)bean state:(APIProcess)state error:(NSError *)error{
    [self callbackListenter:command bean:bean state:state userinfo:nil error:error];
}

- (void)callbackListenter:(NSString*)command bean:(id)bean state:(APIProcess)state userinfo:(id)userinfo error:(NSError *)error{
    @synchronized(self.listenters){
        if (![command empty]) {
            NSMutableArray *arry = [self.listenters objectForKey:command];
            for (id<APICallBackProtocol>call in arry) {
                
                if ([call respondsToSelector:@selector(api:doSome:bean:state:userinfo:error:)]) {
                    [call api:self doSome:command bean:bean state:state userinfo:userinfo error:error];
                }
                
            }
        }
    }
}

@end

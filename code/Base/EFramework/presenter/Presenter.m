//
//  Presenter.m
//  EFExtend
//
//  Created by mac on 15/3/27.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import "Presenter.h"


@implementation PresenterCallbackBlockItem
@synthesize callback;
@synthesize tag;

- (void)dealloc{
    self.callback = nil;
    self.tag = nil;
    HM_SUPER_DEALLOC();
}

@end

@interface Presenter ()
@property (nonatomic,HM_STRONG)NSMutableDictionary *inputs;
@property (nonatomic,HM_STRONG)NSMutableDictionary *outputs;
@property (nonatomic,HM_STRONG)NSMutableDictionary *storeds;
@property (nonatomic,HM_STRONG)NSMutableDictionary *listenters;
@property (nonatomic,HM_STRONG)NSMutableDictionary *callbacks;
@end


@implementation Presenter
@synthesize inputs;
@synthesize outputs;
@synthesize delegate;
@synthesize storeds;
@synthesize listenters;

+ (instancetype)presenter{
    Presenter* presenter = [[[[self class] alloc]init]autorelease];
    
    return presenter;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.inputs = [NSMutableDictionary dictionary];
        self.outputs = [NSMutableDictionary dictionary];
        self.storeds = [NSMutableDictionary dictionary];
        self.listenters = [NSMutableDictionary dictionary];
        self.callbacks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    self.inputs = nil;
    self.outputs = nil;
    self.storeds = nil;
    HM_SUPER_DEALLOC();
}

- (void)bindInput:(UIView *)Input forAttribute:(NSString *)attribute{
    NSAssert([attribute notEmpty], @"bindInput attribute can not be nil or @"" ");
    if ([attribute notEmpty]) {
        @synchronized(self.inputs){
            [self.inputs setObject:Input forKey:attribute];
        }
    }
}

- (void)bindInputOutput:(UIView *)IOput forAttribute:(NSString *)attribute{
    NSAssert([attribute notEmpty], @"bindInputOutput attribute can not be nil or @"" ");
    if ([attribute notEmpty]) {
        [self bindInput:IOput forAttribute:attribute];
        [self bindOutput:IOput forAttribute:attribute];
    }
}

- (void)bindOutput:(UIView *)Output forAttribute:(NSString *)attribute{
    NSAssert([attribute notEmpty], @"bindOutput attribute can not be nil or @"" ");
    if ([attribute notEmpty]) {
        
        @synchronized(self.outputs){
            [self.outputs setObject:Output forKey:attribute];
        }
    }
}

- (id)getInput:(NSString *)attribute{
    NSAssert([attribute notEmpty], @"getInput attribute can not be nil or @"" ");
    if (![attribute notEmpty]) {
        return nil;
    }
    @synchronized(self.inputs){
        return [self.inputs objectForKey:attribute];
    }
}

- (id)getOutput:(NSString *)attribute{
    NSAssert([attribute notEmpty], @"getOutput attribute can not be nil or @"" ");
    if (![attribute notEmpty]) {
        return nil;
    }
    @synchronized(self.outputs){
        return [self.outputs objectForKey:attribute];
    }
}

- (void)unbindAll{
    @synchronized(self.outputs){
        [self.outputs removeAllObjects];
    }
    
    @synchronized(self.inputs){
        [self.inputs removeAllObjects];
    }
}

- (void)unbindInputOutput:(NSString *)attribute{
    [self unbindOutput:attribute];
    [self unbindIutput:attribute];
}

- (void)unbindIutput:(NSString *)attribute{
    NSAssert([attribute notEmpty], @"unbindIutput attribute can not be nil or @"" ");
    if (![attribute notEmpty]) {
        return;
    }
    
    @synchronized(self.inputs){
        [self.inputs removeObjectForKey:attribute];
    }
}

- (void)unbindOutput:(NSString *)attribute{
    NSAssert([attribute notEmpty], @"unbindOutput attribute can not be nil or @"" ");
    if (![attribute notEmpty]) {
        return;
    }
    
    @synchronized(self.outputs){
        [self.outputs removeObjectForKey:attribute];
    }
}

- (void)fillThem:(NSArray *)attributeBinded forSomething:(NSString *)something{
    INFO([self class],@"I may not dealwith fillThem",something,@"for",attributeBinded);
}

- (BOOL)verityThem:(NSArray *)attributeBinded forSomething:(NSString *)something{
    INFO([self class],@"I may not dealwith verityThem",something,@"for",attributeBinded);
    return YES;
}

- (id)doSomething:(NSString *)something attributes:(NSArray *)attributeBinded{
    INFO([self class],@"I may not dealwith doSomething",something,@"for",attributeBinded);
    return nil;
}


- (void)doStore:(NSString *)something attributes:(id)attributeBinded{
    @synchronized(self.storeds){
        if (attributeBinded==nil) {
            [self.storeds removeObjectForKey:something];
        }else{
            [self.storeds setObject:attributeBinded forKey:something];
        }
    }
}

- (id)doReStore:(NSString *)something{
    @synchronized(self.storeds){
       return [self.storeds objectForKey:something];
    }
}

#pragma mark listener

- (NSArray *)observeListenersForCommand:(NSString *)command{
    @synchronized(self.listenters){
        if ([command notEmpty]) {
            NSMutableArray *arry = [self.listenters objectForKey:command];
            return arry;
        }
    }
    
    return nil;
}

- (void)unobserveListenersForCommand:(NSString *)command{
    @synchronized(self.listenters){
        if ([command notEmpty]) {
            [self.listenters removeObjectForKey:command];
        }else{
            [self.listenters removeAllObjects];
        }
    }
}

- (void)unobserveForCommand:(NSString *)command listener:(id<PresenterCallBackProtocol>)Listener{
    if (Listener) {
        @synchronized(self.listenters){
            if ([command notEmpty]) {
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

- (void)observeForCommand:(NSString *)command listener:(id<PresenterCallBackProtocol>)Listener{
    if (Listener) {
        @synchronized(self.listenters){
            if ([command notEmpty]) {
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

#pragma mark block

- (NSArray *)observeBlockItemsForCommand:(NSString *)command{
    @synchronized(self.callbacks){
        if ([command notEmpty]) {
            NSMutableArray *arry = [self.callbacks objectForKey:command];
            return arry;
        }
    }
    
    return nil;
}

- (void)unobserveBlockItemsForCommand:(NSString *)command{
    [self unobserveForCommand:command withTag:nil];
}

- (void)unobserveForCommand:(NSString *)command withTag:(NSString *)tag{
    
    @synchronized(self.callbacks){
        if (![command empty]) {
            NSMutableArray *arry = [self.callbacks objectForKey:command];
            
            [self deleBlockFor:arry tag:tag];
            
        }else{
            for (NSMutableArray *array in self.callbacks.allValues) {
                [self deleBlockFor:array tag:tag];
            }
        }
    }

}

- (void)observeForCommand:(NSString *)command withTag:(NSString *)tag block:(PresenterCALLBACK)callback{
    if (callback) {
        @synchronized(self.callbacks){
            
            NSAssert(tag!=nil,@"tag is nil");
            
            if ([command notEmpty]) {
                NSMutableArray *arry = [self.callbacks objectForKey:command];
                if (arry==nil) {
                    arry= [NSMutableArray array];
                    [self.callbacks setObject:arry forKey:command];
                }
                [self addBlockFor:arry tag:tag block:callback];
                
            }else{
                for (NSMutableArray *array in self.callbacks.allValues) {
                    [self addBlockFor:array tag:tag block:callback];
                }
            }
            
        }
    }
}

- (void)deleBlockFor:(NSMutableArray*)arry tag:(NSString*)tag{
    
    NSMutableArray *items = [NSMutableArray array];
    if (![tag notEmpty]) {
        [arry removeAllObjects];
    }else{
        for (PresenterCallbackBlockItem *item in arry) {
            if ([item.tag isEqualToString:tag]) {
                [items addObject:item];
            }
        }
        if (items.count) {
            [arry removeObjectsInArray:items];
        }
    }
   
}

- (void)addBlockFor:(NSMutableArray*)arry tag:(NSString*)tag block:(PresenterCALLBACK)callback{
    PresenterCallbackBlockItem *item = nil;
    for (PresenterCallbackBlockItem *block in arry) {
        if ([block.tag isEqualToString:tag]) {
            item = block;
            break;
        }
    }
    if (item==nil) {
        item = [[[PresenterCallbackBlockItem alloc]init] autorelease];
        [arry addObject:item];
    }
    item.tag = tag;
    item.callback = callback;
    
}


- (void)callbackListenter:(NSString *)something bean:(id)bean state:(PresenterProcess)state error:(NSError *)error{
    @synchronized(self.listenters){
        if ([something notEmpty]) {
            NSMutableArray *arry = [self.listenters objectForKey:something];
            for (id<PresenterCallBackProtocol>call in arry) {
                
                if ([call respondsToSelector:@selector(presenter:doSome:bean:state:error:)]) {
                    [call presenter:self doSome:something bean:bean state:state error:error];
                }
                
            }
            
        }
    }
    @synchronized(self.callbacks){
        if ([something notEmpty]) {
            NSMutableArray * arry = [self.callbacks objectForKey:something];
            
            for (PresenterCallbackBlockItem *item in arry) {
                PresenterCALLBACK callback = item.callback;
                callback(self,something,item.tag,bean,state,error);
            }
        }
    }

}

@end

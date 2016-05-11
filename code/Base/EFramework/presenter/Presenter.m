//
//  Presenter.m
//  EFExtend
//
//  Created by mac on 15/3/27.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import "Presenter.h"

@interface Presenter ()
@property (nonatomic,HM_STRONG)NSMutableDictionary *inputs;
@property (nonatomic,HM_STRONG)NSMutableDictionary *outputs;
@property (nonatomic,HM_STRONG)NSMutableDictionary *storeds;
@property (nonatomic,HM_STRONG)NSMutableDictionary *callbacks;
@end

@implementation Presenter
@synthesize inputs;
@synthesize outputs;
@synthesize delegate;
@synthesize storeds;

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

@end

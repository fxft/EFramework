//
//  NSArray+HMExtension.h
//  CarAssistant
//
//  Created by Eric on 14-2-23.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark -

typedef NSMutableArray *	(^NSArrayAppendBlock)( id obj );
typedef NSMutableArray *	(^NSMutableArrayAppendBlock)( id obj );

#pragma mark -

@interface NSArray(HMExtension)

@property (nonatomic, readonly) NSArrayAppendBlock			APPEND;
@property (nonatomic, readonly) NSMutableArray *			mutableArray;

- (NSArray *)head:(NSUInteger)count;//从头获取count个
- (NSArray *)tail:(NSUInteger)count;//从尾获取count个

- (id)safeObjectAtIndex:(NSInteger)index;
- (NSArray *)safeSubarrayWithRange:(NSRange)range;

//json转换
- (NSData *)JSONData;
- (NSString *)JSONString;
//数组过滤 eg. [@[@{@"age":@(2)},@{@"age":@(20)}] filterWithFormat:@"age > %d",10];
- (NSArray*)filterWithFormat:(NSString *)format,...;
//获取数组中某个属性的不重复集合
- (NSArray *)distinctUnionOfObjectsForKey:(NSString*)key;
//获取数组中某个属性的所有集合
- (NSArray *)unionOfObjectsForKey:(NSString*)key;

@end

#pragma mark -
@interface NSMutableArray(HMExtension)

@property (nonatomic, readonly) NSMutableArrayAppendBlock	APPEND;

+ (NSMutableArray *)nonRetainingArray;			// copy from Three20

- (NSMutableArray *)pushHead:(NSObject *)obj;
- (NSMutableArray *)pushHeadN:(NSArray *)all;
- (NSMutableArray *)popTail;
- (NSMutableArray *)popTailN:(NSUInteger)n;

- (NSMutableArray *)pushTail:(NSObject *)obj;
- (NSMutableArray *)pushTailN:(NSArray *)all;
- (NSMutableArray *)popHead;
- (NSMutableArray *)popHeadN:(NSUInteger)n;

- (NSMutableArray *)keepHead:(NSUInteger)n;
- (NSMutableArray *)keepTail:(NSUInteger)n;

//引用计数不变
- (void)insertObjectNoRetain:(id)anObject atIndex:(NSUInteger)index;
- (void)addObjectNoRetain:(NSObject *)obj;
- (void)removeObjectNoRelease:(NSObject *)obj;
- (void)removeAllObjectsNoRelease;

@end
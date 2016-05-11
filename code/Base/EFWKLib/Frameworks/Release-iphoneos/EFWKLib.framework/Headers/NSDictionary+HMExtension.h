//
//  NSDictionary+HMExtension.h
//  GPSService
//
//  Created by Eric on 14-4-3.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSDictionary *	(^NSDictionaryAppendBlock)( NSString * key, id value );


@interface NSDictionary (HMExtension)

@property (nonatomic, readonly) NSDictionaryAppendBlock	APPEND;
//json转换
- (NSData *)JSONData;
- (NSString *)JSONString;
@end


@interface NSMutableDictionary (HMExtension)

@property (nonatomic, readonly) NSDictionaryAppendBlock	APPEND;

+ (NSMutableDictionary *)nonRetainingDictionary;			// copy from Three20

@end
//
//  NSData+HMExtension.h
//  GPSService
//
//  Created by Eric on 14-4-13.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (HMExtension)

//获取json对象
- (id)objectFromJson;
- (id)objectFromJSONData;

//判断是否为gif数据，0x47开头
- (BOOL)sd_isGIF;

@end

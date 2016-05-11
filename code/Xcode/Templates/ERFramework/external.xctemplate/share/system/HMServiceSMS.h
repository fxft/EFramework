//
//  HMServiceSMS.h
//  WestLuckyStar
//
//  Created by Eric on 14-5-13.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMServiceSMS : NSObject
AS_SINGLETON(HMServiceSMS)

@property (nonatomic, readonly) BOOL							installed;

@end

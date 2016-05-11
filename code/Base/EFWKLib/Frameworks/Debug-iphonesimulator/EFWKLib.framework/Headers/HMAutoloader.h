//
//  HMAutoloader.h
//  CarAssistant
//
//  Created by Eric on 14-2-23.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMAutoLoader : NSObject


@end
/**
 *  自启动对象的父类，需要重写autoLoad方法
 */
@interface HMAutoLoad : NSObject

+ (BOOL)autoLoad;
- (void)load;
- (void)unload;

@end

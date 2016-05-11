//
//  NSData+HMExtension.m
//  GPSService
//
//  Created by Eric on 14-4-13.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "NSData+HMExtension.h"
#import "HMMacros.h"

@implementation NSData (HMExtension)

- (id)objectFromJson{
    NSError *serializationError = nil;
    id object = [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingMutableContainers error:&serializationError];
    if (serializationError) {
#if (__ON__ == __HM_DEVELOPMENT__)
        CC( @"JSON",serializationError);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    }
    return object;
}

- (id)objectFromJSONData{
    return [self objectFromJson];
}

- (BOOL)sd_isGIF
{
    BOOL isGIF = NO;
    
    uint8_t c;
    [self getBytes:&c length:1];
    
    switch (c)
    {
        case 0x47:  // probably a GIF
            isGIF = YES;
            break;
        default:
            break;
    }
    
    return isGIF;
}
@end

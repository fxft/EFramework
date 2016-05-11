//
//  ZXingBoard.h
//  GLuckyTransport
//
//  Created by mac on 15/7/20.
//  Copyright (c) 2015年 mac. All rights reserved.
//


@class ZXCapture;

#define ON_ZXing( signal) ON_SIGNAL2(ZXingBoard, signal)

@interface ZXingBoard : HMUIBoard
AS_SIGNAL(ZXingRead)

@property (nonatomic, assign)   NSInteger type;
@property (nonatomic, HM_STRONG) ZXCapture *capture;

@end

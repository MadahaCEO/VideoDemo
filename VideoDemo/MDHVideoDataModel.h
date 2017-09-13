//
//  MDHVideoDataModel.h
//  VideoDemo
//
//  Created by Apple on 2017/9/12.
//  Copyright © 2017年 马大哈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface MDHVideoDataModel : NSObject


@property (nonatomic, assign) BOOL      alreadyPlay;  // 已经播放了

@property (nonatomic, assign) BOOL      isForward;  // 继续播放（或回退）

@property (nonatomic, assign) CGFloat   totalSecond;    // 视频总共时间，单位 s
@property (nonatomic, assign) CGFloat   currentSecond;  // 视频当前播放到多少秒  单位s
@property (nonatomic, assign) CGFloat   playProgress;       // 视频当前播放进度   0.0 ~ 1.0
@property (nonatomic, assign) CGFloat   bufferProgress;       // 视频当前播放进度   0.0 ~ 1.0

@property (nonatomic, copy) NSString *totalTimeString;    // 视频总时长字符串（1:32:50）
@property (nonatomic, copy) NSString *currentTimeString;  // 视频当前播放到的时间字符串（00:12:50）
@property (nonatomic, copy) NSString *forwardBackTimeString;  // 快进快退字符串（12:50/00:12）



+ (instancetype)sharedInstance;

@end

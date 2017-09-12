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

//@property (nonatomic, assign) BOOL   isReady;    // 是否 准备好 播放  （视频缓冲）
@property (nonatomic, assign) BOOL   isStarted;  // 是否 “启动” 播放 （视频缓冲好，一直没有点击播放按钮）
@property (nonatomic, assign) BOOL   isPlaying;  // 是否 “正在” 播放 （已经启动播放了，播放过程中暂停了或者一直在播放）

//@property (nonatomic, assign) BOOL   isddd;

@property (nonatomic, assign) NSInteger   totalSecond;    // 视频总共时间，单位 s
@property (nonatomic, assign) NSInteger   currentSecond;  // 视频当前播放到多少秒  单位s
@property (nonatomic, assign) CGFloat     progress;       // 视频当前播放进度   0.0 ~ 1.0


@property (nonatomic, copy) NSString *totalTimeString;    // 视频总时长字符串（1:32:50）
@property (nonatomic, copy) NSString *currentTimeString;  // 视频当前播放到的时间字符串（00:12:50）
@property (nonatomic, copy) NSString *forwardBackTimeString;  // 快进快退字符串（12:50/00:12）



+ (instancetype)sharedInstance;

@end

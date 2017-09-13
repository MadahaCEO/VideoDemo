//
//  MDHVideoControlView.h
//  VideoDemo
//
//  Created by Apple on 2017/9/12.
//  Copyright © 2017年 马大哈. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MDHVideoControlView;
@protocol MDHVideoControlViewDelegate <NSObject>

@optional

// 控制播放、暂停
- (void)MDHVideoControlView:(MDHVideoControlView *)controlView play:(BOOL)play;
// 控制重新播放（播放结束后，显示重新播放按钮）
- (void)MDHVideoControlViewRePlay:(MDHVideoControlView *)controlView;
// 控制跳转播放（快进、快退等操作结束）
- (void)MDHVideoControlView:(MDHVideoControlView *)controlView seekToTime:(CGFloat)skipTime;
// 控制全屏播放
- (void)MDHVideoControlViewFullScreen:(MDHVideoControlView *)controlView;


@end



@interface MDHVideoControlView : UIView

@property (nonatomic, weak) id <MDHVideoControlViewDelegate> delegate;


/**
 *  启动加载动画
 */
- (void)startAnimating;

/**
 *  结束加载动画
 */
- (void)stopAnimating;

/**
 *  更新当前播放时长
 *
 *  @param ready        准备播放
 *
 */
- (void)readyToPlay:(BOOL)ready;

/**
 *  播放结束
 */
- (void)playToEnd;

/**
 *  更新总时长（实质是更新MDHVideoToolBar相关控件）
 */
- (void)updateTotalTime;

/**
 *  更新当前时长（实质是更新MDHVideoToolBar相关控件）
 */
- (void)updateCurrentTime;

/**
 *  更新缓冲（实质是更新MDHVideoToolBar相关控件）
 *
 *  @param progress       缓冲进度
 */
- (void)updateBufferProgress:(CGFloat)progress;

@end

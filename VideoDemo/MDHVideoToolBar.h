//
//  MDHVideoToolBar.h
//  VideoDemo
//
//  Created by Apple on 2017/9/12.
//  Copyright © 2017年 马大哈. All rights reserved.
//



/********************************** 参考效果图 ************************************/

/*———————————————————————————————————————————————————————————————————————————
 |   _____    _______                                   _______    _______   |
 |  |     |  |       |   progressView & slider         |       |  |      |   |
 |  |play |  | time  |  ____________________________   | time  |  |screen|   |
 |  |_____|  |_______|                                 |_______|  |______|   |
 |___________________________________________________________________________*/



#import <UIKit/UIKit.h>


@class MDHVideoToolBar;
@protocol MDHVideoToolBarDelegate <NSObject>

@optional

//playButton 播放、暂停
- (void)MDHVideoToolBar:(MDHVideoToolBar *)videoToolBar play:(BOOL)play;
//slider 开始拖动
- (void)MDHVideoToolBarBeginDragSlider:(MDHVideoToolBar *)videoToolBar;
//slider 正在拖动
- (void)MDHVideoToolBarDragingSlider:(MDHVideoToolBar *)videoToolBar;
//slider 停止拖动
- (void)MDHVideoToolBarFinishDragSlider:(MDHVideoToolBar *)videoToolBar;
//fullScreenButton 全屏
- (void)MDHVideoToolBarFullScreen:(MDHVideoToolBar *)videoToolBar;


@end



@interface MDHVideoToolBar : UIView

@property (nonatomic, weak) id <MDHVideoToolBarDelegate> customDelegate;
@property (nonatomic, assign) CGFloat sliderValue; // slider 当前值


/**
 *  更新总时长
 *
 *  @param totalTime          总时长（单位秒）
 *  @param timeString         总时长格式字符串
 *
 */
- (void)updateTotalTime:(CGFloat)totalTime timeString:(NSString *)timeString;


/**
 *  更新当前播放时长
 *
 *  @param currentTime        当前播放时长（单位秒）
 *  @param timeString         当前播放时长格式字符串
 *
 */
- (void)updateCurrentTime:(CGFloat)currentTime timeString:(NSString *)timeString;


/**
 *   更新缓冲进度
 *
 *  @param progress        更新缓冲进度
 *
 */
- (void)updateBufferProgress:(CGFloat)progress;


@end

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

- (void)MDHVideoToolBar:(MDHVideoToolBar *)videoToolBar play:(BOOL)play;


//- (void)videoToolBarSliderDidDraging:(MDHVideoToolBar *)videoToolBar;
//- (void)videoToolBar:(MDHVideoToolBar *)videoToolBar changeVideoStatus:(BOOL)play;
//- (void)videoToolBar:(MDHVideoToolBar *)videoToolBar seekToTime:(CGFloat)skipTime;
//- (void)videoToolBar:(MDHVideoToolBar *)videoToolBar switchScreen:(BOOL)fullScreen;

@end



@interface MDHVideoToolBar : UIView



@property (nonatomic, strong) UIButton         *playBtn;              // 播放/暂停按钮
@property (nonatomic, strong) UILabel          *currentTimeLabel;     // 当前播放时间
@property (nonatomic, strong) UILabel          *totalTimeLabel;       // 视频总时长
@property (nonatomic, strong) UIProgressView   *bufferProgressView;   // 缓冲进度条
@property (nonatomic, strong) UISlider         *slider;               // 滑竿
@property (nonatomic, strong) UIButton         *fullScreenBtn;        // 全屏

@property (nonatomic, assign) CGFloat          totalDuration;          // 总时长，单位 s
@property (nonatomic, assign) BOOL             draging;                // 是否正在拖动
@property (nonatomic, assign) BOOL             playing;                // 是否正在播放
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, weak) id <MDHVideoToolBarDelegate> customDelegate;



- (void)updateTotalTime:(CGFloat)totalTime timeString:(NSString *)timeString;
- (void)updateCurrentTime:(CGFloat)currentTime timeString:(NSString *)timeString;

- (void)updateBufferProgress:(CGFloat)progress;


@end

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

- (void)MDHVideoControlView:(MDHVideoControlView *)controlView play:(BOOL)play;
//- (void)videoToolBar:(VideoToolBar *)videoToolBar seekToTime:(CGFloat)skipTime;
//- (void)videoToolBar:(VideoToolBar *)videoToolBar switchScreen:(BOOL)fullScreen;

@end



@interface MDHVideoControlView : UIView

@property (nonatomic, weak) id <MDHVideoControlViewDelegate> delegate;
@property (nonatomic, assign) BOOL   firstPlay;



- (void)startAnimating;
- (void)stopAnimating;

- (void)readyToPlay:(BOOL)ready;
- (void)playToEnd;

- (void)updateTotalTime;
- (void)updateCurrentTime;


@end

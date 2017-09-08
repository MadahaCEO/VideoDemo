//
//  VideoToolBar.h
//  MDHProject
//
//  Created by Apple on 2017/9/7.
//  Copyright © 2017年 马大哈. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoToolBar;
@protocol VideoToolBarDelegate <NSObject>

@optional

- (void)videoToolBar:(VideoToolBar *)videoToolBar changeVideoStatus:(BOOL)play;
- (void)videoToolBar:(VideoToolBar *)videoToolBar seekToTime:(CGFloat)skipTime;

@end


@interface VideoToolBar : UIToolbar

@property (nonatomic, assign) BOOL draging;
@property (nonatomic, weak) id <VideoToolBarDelegate> customDelegate;

- (void)updateTotalDuration:(CGFloat)duration;
- (void)updateBufferProgress:(CGFloat)progress;
- (void)updatePlayProgress:(CGFloat)progress;


@end

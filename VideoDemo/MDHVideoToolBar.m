//
//  MDHVideoToolBar.m
//  VideoDemo
//
//  Created by Apple on 2017/9/12.
//  Copyright © 2017年 马大哈. All rights reserved.
//

#import "MDHVideoToolBar.h"
#import "Masonry.h"


@interface MDHVideoToolBar ()


@end


#define MDHDelegateCallback(cDelegate, aSelector)  (cDelegate && [cDelegate respondsToSelector:aSelector])


static const CGFloat KButtonWidth     = 40; // 播放按钮、全屏按钮
static const CGFloat KTimeLabelWidth  = 50; // 时间label 宽度
static const CGFloat KControlPadding  = 10; // 各个控件 间隔 10


@implementation MDHVideoToolBar


- (void)dealloc {
    
}



- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        
        [self addSubview: self.playBtn];
        [self addSubview: self.currentTimeLabel];
        [self addSubview: self.bufferProgressView];
        [self addSubview: self.slider];
        [self addSubview: self.totalTimeLabel];
        [self addSubview: self.fullScreenBtn];
        
        
        
        /*
         1. 排 playBtn
         2. 排 currentTimeLabel
         3. 排 fullScreenBtn
         4. 排 totalTimeLabel
         5. 排 bufferProgressView
         6. 排 slider
         */
        [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(@(KControlPadding));
            make.top.bottom.equalTo(@0);
            make.width.equalTo(@(KButtonWidth));
        }];
        
        
        [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self.playBtn.mas_right).offset(KControlPadding);
            make.top.bottom.equalTo(@0);
            make.width.equalTo(@(KTimeLabelWidth));
        }];
        
        [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.right.equalTo(self.mas_right).offset(-KControlPadding);
            make.top.bottom.equalTo(@0);
            make.width.equalTo(@(KButtonWidth));
            
        }];
        
        
        [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.right.equalTo(self.fullScreenBtn.mas_left).offset(-KControlPadding);
            make.top.bottom.equalTo(@0);
            make.width.equalTo(@(KTimeLabelWidth));
        }];
        
        
        [self.bufferProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self.currentTimeLabel.mas_right).offset(KControlPadding);
            make.right.equalTo(self.totalTimeLabel.mas_left).offset(-KControlPadding);
            make.centerY.equalTo(self.mas_centerY);
        }];
        
        [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.left.bottom.right.equalTo(self.bufferProgressView);
            
        }];
        
    }
    
    return  self;
}




#pragma mark - Layz load

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}


- (UIButton *)playBtn {
    
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _playBtn.backgroundColor = [UIColor clearColor];
        [_playBtn setImage: [UIImage imageNamed:@"mdh_video_tool_pauseBtn"]
                  forState: UIControlStateNormal];
        [_playBtn setImage: [UIImage imageNamed:@"mdh_video_tool_playBtn"]
                  forState: UIControlStateSelected];
        _playBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_playBtn addTarget: self
                     action: @selector(playBtnClick:)
           forControlEvents: UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UILabel *)currentTimeLabel {
    
    if (!_currentTimeLabel) {
        
        _currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _currentTimeLabel.backgroundColor = [UIColor grayColor];
        _currentTimeLabel.text = @"asdfasdf";
    }
    
    return _currentTimeLabel;
}


- (UIProgressView *)bufferProgressView {
    
    if (!_bufferProgressView) {
        
        // slider 默认高度 2
        _bufferProgressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
        _bufferProgressView.progressViewStyle = UIProgressViewStyleDefault;
        _bufferProgressView.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _bufferProgressView.trackTintColor    = [UIColor clearColor];
        
    }
    
    return _bufferProgressView;
}

- (UISlider *)slider {
    
    if (!_slider) {
        
        // slider 默认高度 31
        _slider = [[UISlider alloc] initWithFrame:CGRectZero];
        _slider.minimumTrackTintColor = [UIColor whiteColor];
        _slider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
        [_slider addTarget: self
                    action: @selector(dragSlider)
          forControlEvents: UIControlEventValueChanged];
        [_slider addTarget: self
                    action: @selector(skipToTime:)
          forControlEvents: UIControlEventTouchUpInside];
        [_slider addTarget: self
                    action: @selector(skipToTime:)
          forControlEvents: UIControlEventTouchUpOutside];
        _slider.value = 0;
    }
    
    return _slider;
}


- (UILabel *)totalTimeLabel {
    
    if (!_totalTimeLabel) {
        
        _totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _totalTimeLabel.backgroundColor = [UIColor grayColor];
        _totalTimeLabel.text = @"xxxxxx";
    }
    
    return _totalTimeLabel;
}


- (UIButton *)fullScreenBtn {
    
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullScreenBtn.backgroundColor = [UIColor clearColor];
        [_fullScreenBtn setImage: [UIImage imageNamed:@"mdh_video_tool_fullscreen"]
                        forState: UIControlStateNormal];
        [_fullScreenBtn setImage: [UIImage imageNamed:@"mdh_video_tool_shrinkscreen"]
                        forState: UIControlStateSelected];
        _fullScreenBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_fullScreenBtn addTarget:self action:@selector(fullScreenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenBtn;
}



#pragma mark - Button method

- (void)playBtnClick:(UIButton *)button {
    
    button.selected = !button.selected;
    
    if (MDHDelegateCallback(self.customDelegate, @selector(MDHVideoToolBar:play:))) {
        
        [self.customDelegate MDHVideoToolBar: self
                                        play: !button.selected];
    }
}

- (void)fullScreenBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    
//    if (MDHDelegateCallback(self.customDelegate, @selector(videoToolBar:switchScreen:))) {
//        
//        [self.customDelegate videoToolBar: self
//                             switchScreen: YES];
//    }
}



#pragma mark - Helper


#pragma mark - For outer

- (void)updateTotalTime:(CGFloat)totalTime timeString:(NSString *)timeString {
    
//    self.totalDuration = totalTime;
    self.totalTimeLabel.text = timeString;
    
    self.slider.minimumValue = 0;
    self.slider.maximumValue = totalTime;
    
}
- (void)updateCurrentTime:(CGFloat)currentTime timeString:(NSString *)timeString {
    
    if (self.draging) {
        
    } else {
        
        self.playing = YES;
        
        self.slider.value = currentTime;
        
        self.currentTimeLabel.text = timeString;
    }
}


- (void)updateBufferProgress:(CGFloat)progress {
    
    self.bufferProgressView.progress = progress;
    
}




#pragma mark - Slider method

- (void)dragSlider {
    
    NSLog(@"正在拖动slider");
    
//    self.currentTimeLabel.text = [self convertTime: self.slider.value];
    
//    if (MDHDelegateCallback(self.customDelegate, @selector(videoToolBarSliderDidDraging:))) {
//        
//        [self.customDelegate videoToolBarSliderDidDraging: self];
//    }
    
    self.draging = YES;
}

- (void)skipToTime:(UISlider *)control {
    
    NSLog(@"停止拖动slider");
    
    self.draging = NO;
    
//    if (MDHDelegateCallback(self.customDelegate, @selector(videoToolBar:seekToTime:))) {
//        
//        [self.customDelegate videoToolBar: self
//                               seekToTime: control.value];
//        
//    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

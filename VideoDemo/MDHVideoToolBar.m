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

@property (nonatomic, strong) UIButton         *playBtn;              // 播放/暂停按钮
@property (nonatomic, strong) UILabel          *currentTimeLabel;     // 当前播放时间
@property (nonatomic, strong) UILabel          *totalTimeLabel;       // 视频总时长
@property (nonatomic, strong) UIProgressView   *bufferProgressView;   // 缓冲进度条
@property (nonatomic, strong) UISlider         *slider;               // 滑竿
@property (nonatomic, strong) UIButton         *fullScreenBtn;        // 全屏
@property (nonatomic, assign) BOOL             draging;                // 是否正在拖动

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
        
        self.backgroundColor = [UIColor clearColor];
        
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
        _currentTimeLabel.backgroundColor = [UIColor clearColor];
        _currentTimeLabel.textColor = [UIColor whiteColor];
    }
    
    return _currentTimeLabel;
}


- (UIProgressView *)bufferProgressView {
    
    if (!_bufferProgressView) {
        
        // slider 默认高度 2
        _bufferProgressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
        _bufferProgressView.progressViewStyle = UIProgressViewStyleDefault;
//        _bufferProgressView.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _bufferProgressView.progressTintColor = [UIColor redColor];
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
                    action: @selector(beginDragSlider:)
          forControlEvents: UIControlEventTouchDown];
        [_slider addTarget: self
                    action: @selector(dragingSlider:)
          forControlEvents: UIControlEventValueChanged];
        [_slider addTarget: self
                    action: @selector(endDragSlider:)
          forControlEvents: UIControlEventTouchUpInside];
        [_slider addTarget: self
                    action: @selector(endDragSlider:)
          forControlEvents: UIControlEventTouchUpOutside];
        _slider.value = 0;
    }
    
    return _slider;
}


- (UILabel *)totalTimeLabel {
    
    if (!_totalTimeLabel) {
        
        _totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _totalTimeLabel.backgroundColor = [UIColor clearColor];
        _totalTimeLabel.textColor = [UIColor whiteColor];
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
    
    if (MDHDelegateCallback(self.customDelegate, @selector(MDHVideoToolBarFullScreen:))) {
        
        [self.customDelegate MDHVideoToolBarFullScreen: self];
    }
}



#pragma mark - Helper


#pragma mark - For outer

- (void)updateTotalTime:(CGFloat)totalTime timeString:(NSString *)timeString {
    
    self.totalTimeLabel.text = timeString;
    
    self.slider.minimumValue = 0;
    self.slider.maximumValue = totalTime;
    
}
- (void)updateCurrentTime:(CGFloat)currentTime timeString:(NSString *)timeString {
    
    if (self.draging) {
        
    } else {
        
        self.slider.value = currentTime;
    }
    
    self.currentTimeLabel.text = timeString;
}


- (void)updateBufferProgress:(CGFloat)progress {
    
    NSLog(@"\n\n缓冲进度  %f\n\n",progress);

    self.bufferProgressView.progress = progress;
}



#pragma mark - Slider method

- (void)beginDragSlider:(UISlider *)control {
    NSLog(@"接触、开始拖动slider");

    if (MDHDelegateCallback(self.customDelegate, @selector(MDHVideoToolBarBeginDragSlider:))) {
        
        [self.customDelegate MDHVideoToolBarBeginDragSlider: self];
    }
}

- (void)dragingSlider:(UISlider *)control {
    
    NSLog(@"正在拖动slider");
    
    self.draging     = YES;
    self.sliderValue = control.value;
    
    if (MDHDelegateCallback(self.customDelegate, @selector(MDHVideoToolBarDragingSlider:))) {
        
        [self.customDelegate MDHVideoToolBarDragingSlider: self];
    }
    
}

- (void)endDragSlider:(UISlider *)control {
    
    NSLog(@"停止拖动slider");
    self.sliderValue = control.value;

    self.draging = NO;
    
    if (MDHDelegateCallback(self.customDelegate, @selector(MDHVideoToolBarFinishDragSlider:))) {
        
        [self.customDelegate MDHVideoToolBarFinishDragSlider: self];
        
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  VideoToolBar.m
//  MDHProject
//
//  Created by Apple on 2017/9/7.
//  Copyright © 2017年 马大哈. All rights reserved.
//

#import "VideoToolBar.h"

@interface VideoToolBar ()


@property (nonatomic, assign) CGFloat          totalDuration;

@property (nonatomic, strong) UILabel          *playProgressLabel; // 视频当前播放进度
@property (nonatomic, strong) UIView           *progressView; // 视频当前播放进度
@property (nonatomic, strong) UISlider         *slider;           // 滑竿
@property (nonatomic, strong) UIProgressView   *bufferView;     // 缓冲进度条
@property (nonatomic, strong) UILabel          *videoDurationLabel;     // 视频总时长

@end



@implementation VideoToolBar

- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        
        //        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]
        //                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
        //                                      target:nil action:nil];
        UIBarButtonItem *playPause = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                      target:self
                                      action:@selector(playButton)];
        
        

        
        UIBarButtonItem *progress = [[UIBarButtonItem alloc] initWithCustomView: self.playProgressLabel];
        UIBarButtonItem *progressView = [[UIBarButtonItem alloc] initWithCustomView: self.progressView];
        UIBarButtonItem *duration = [[UIBarButtonItem alloc] initWithCustomView: self.videoDurationLabel];

        NSArray *arr1 = @[playPause, progress, progressView,  duration];
        self.items = arr1;

        
    }
    
    return  self;
}

- (UILabel *)playProgressLabel {
    
    if (!_playProgressLabel) {
        
        _playProgressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        _playProgressLabel.backgroundColor = [UIColor grayColor];
    }
    
    return _playProgressLabel;
}

- (UIView *)progressView {
    
    if (!_progressView) {
        
        _progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, 40)];
        _progressView.backgroundColor = [UIColor blackColor];
        
        [_progressView addSubview:self.slider];
        [_progressView addSubview:self.bufferView];

    }
    
    return _progressView;
}

- (UIProgressView *)bufferView {
    
    if (!_bufferView) {
        
        _bufferView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 5, 500, 10)];
        _bufferView.progressViewStyle = UIProgressViewStyleDefault;
        _bufferView.progressTintColor = [UIColor redColor];
        _bufferView.trackTintColor = [UIColor yellowColor];
    }
    
    return _bufferView;
}

- (UISlider *)slider {

    if (!_slider) {
        
        _slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 500, 40)];
        [_slider addTarget: self
                    action: @selector(dragSlider)
          forControlEvents: UIControlEventValueChanged];
        [_slider addTarget: self
                    action: @selector(skipToTime:)
          forControlEvents: UIControlEventTouchUpInside];

    }
    
    return _slider;
}


- (UILabel *)videoDurationLabel {
    
    if (!_videoDurationLabel) {
        
        _videoDurationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        _videoDurationLabel.backgroundColor = [UIColor grayColor];
    }
    
    return _videoDurationLabel;
}



- (void)playButton {
    
    
    if (self.customDelegate && [self.customDelegate respondsToSelector: @selector(videoToolBar:changeVideoStatus:)]) {
       
        [self.customDelegate videoToolBar: self
                        changeVideoStatus: YES];
    }
}



- (void)updateTotalDuration:(CGFloat)duration {

    self.totalDuration = duration;
    self.videoDurationLabel.text = [NSString stringWithFormat:@"%.0f",duration];
    
    self.slider.minimumValue = 0;
    self.slider.maximumValue = self.totalDuration;

}

- (void)updateBufferProgress:(CGFloat)progress {

    
    self.bufferView.progress = progress;

}

- (void)updatePlayProgress:(CGFloat)progress {
 
    if (self.draging) {
        
    } else {
    
        self.slider.value = progress;
        
        self.playProgressLabel.text = [NSString stringWithFormat:@"%.0f",progress];
    }
}


- (void)dragSlider {

    self.draging = YES;
}

- (void)skipToTime:(UISlider *)control {

    self.draging = NO;

    if (self.customDelegate && [self.customDelegate respondsToSelector: @selector(videoToolBar:seekToTime:)]) {
        
        [self.customDelegate videoToolBar: self
                               seekToTime: control.value];
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

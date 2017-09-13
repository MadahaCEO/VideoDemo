//
//  MDHVideoControlView.m
//  VideoDemo
//
//  Created by Apple on 2017/9/12.
//  Copyright © 2017年 马大哈. All rights reserved.
//

#import "MDHVideoControlView.h"

// 系统+第三方头文件
#import "Masonry.h"

// 自定义类头文件
#import "MDHVideoFastForwardBackView.h"
#import "MDHVideoToolBar.h"
#import "MDHVideoDataModel.h"




@interface MDHVideoControlView ()
<MDHVideoToolBarDelegate>


@property (nonatomic, strong) UIActivityIndicatorView       *indicatorView;       // 菊花
@property (nonatomic, strong) UIButton                      *readyToPlayBtn;      // 启动播放
@property (nonatomic, strong) UIButton                      *rePlayBtn;           // 重新播放
@property (nonatomic, strong) MDHVideoFastForwardBackView   *fastForwardBackView; // 快进、退View
@property (nonatomic, strong) MDHVideoToolBar               *toolBar;             // 底部工具View

@property (nonatomic, assign) BOOL   toolBarHiden;
@property (nonatomic, assign) BOOL   HorizontalMoved; // 水平运动
@property (nonatomic, assign) BOOL   alreadyPlayed;   // 已经播放了

@property (nonatomic, assign) CGFloat                sumTime;


@end


static const CGFloat KReadyToPlayBtnWidth        = 60;  // 启动播放按钮宽度（高度）正方形
static const CGFloat KFastForwardBackViewWidth   = 125; // 快进提示View宽度
static const CGFloat KFastForwardBackViewHeight  = 100; // 快进提示View高度
static const CGFloat KToolBarHeight              = 40;  // 工具View高度
static const CGFloat KPanGestureParam            = 400; // 手势滑动配置参数


@implementation MDHVideoControlView



- (void)dealloc {
    
}



- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
    
        [self addSubview: self.indicatorView];
        [self addSubview: self.readyToPlayBtn];
        [self addSubview: self.rePlayBtn];
        [self addSubview: self.fastForwardBackView];
        [self addSubview: self.toolBar];
        
        self.readyToPlayBtn.hidden      = YES;
        self.rePlayBtn.hidden           = YES;
        self.fastForwardBackView.hidden = YES;
        self.toolBar.hidden             = YES;
        
        [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.center.equalTo(self);
            make.width.height.equalTo(@50);
            
        }];
        
        [self.readyToPlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.center.equalTo(self);
            make.width.height.equalTo(@(KReadyToPlayBtnWidth));
           
        }];
        
        [self.rePlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.center.equalTo(self);
            make.width.height.equalTo(@(KReadyToPlayBtnWidth));
            
        }];
        
        [self.fastForwardBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.center.equalTo(self);
            make.width.equalTo(@(KFastForwardBackViewWidth));
            make.height.equalTo(@(KFastForwardBackViewHeight));

        }];
        
        [self.toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.right.equalTo(@0);
            make.bottom.equalTo(@(-10));
            make.height.equalTo(@(KToolBarHeight));
            
        }];

        [self.indicatorView startAnimating];

        
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget: self
                                                                                  action: @selector(panDirection:)];
//        gesture.delegate = self;
        [gesture setMaximumNumberOfTouches:1];
        [gesture setDelaysTouchesBegan:YES];
        [gesture setDelaysTouchesEnded:YES];
        [gesture setCancelsTouchesInView:YES];
        [self addGestureRecognizer:gesture];

    }
    
    return  self;
}



#pragma mark - For outer

- (void)startAnimating {

    [self.indicatorView startAnimating];
}

- (void)stopAnimating {
    
    [self.indicatorView stopAnimating];
}

- (void)readyToPlay:(BOOL)ready {

    // 准备播放的时候 展示按钮，点击启动播放
    self.readyToPlayBtn.hidden = !ready;
    
    if (ready) {
        [self stopAnimating];
    }
}

- (void)playToEnd {

    self.readyToPlayBtn.hidden = YES;
    self.rePlayBtn.hidden      = NO;
    self.toolBar.hidden        = YES;
}


- (void)updateTotalTime {
    
    [self.toolBar updateTotalTime: [MDHVideoDataModel sharedInstance].totalSecond
                       timeString: [MDHVideoDataModel sharedInstance].totalTimeString];
    
}

- (void)updateCurrentTime {
    
    [self.toolBar updateCurrentTime: [MDHVideoDataModel sharedInstance].currentSecond
                         timeString: [MDHVideoDataModel sharedInstance].currentTimeString];
}

- (void)updateBufferProgress:(CGFloat)progress {

    [self.toolBar updateBufferProgress:progress];
}



#pragma mark - Layz load


- (UIActivityIndicatorView *)indicatorView {
    
    if (!_indicatorView) {
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        
    }
    
    return _indicatorView;
}

- (UIButton *)readyToPlayBtn {
    
    if (!_readyToPlayBtn) {
        _readyToPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _readyToPlayBtn.backgroundColor = [UIColor clearColor];
        [_readyToPlayBtn setImage: [UIImage imageNamed:@"mdh_video_tool_StartPlay"]
                  forState: UIControlStateNormal];
        _readyToPlayBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_readyToPlayBtn addTarget: self
                     action: @selector(readyToPlayBtnClick:)
           forControlEvents: UIControlEventTouchUpInside];
    }
    return _readyToPlayBtn;
}

- (UIButton *)rePlayBtn {
    
    if (!_rePlayBtn) {
        _rePlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rePlayBtn.backgroundColor = [UIColor clearColor];
        [_rePlayBtn setImage: [UIImage imageNamed:@"mdh_video_tool_replayBtn"]
                         forState: UIControlStateNormal];
        _rePlayBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_rePlayBtn addTarget: self
                       action: @selector(rePlayBtnClick:)
             forControlEvents: UIControlEventTouchUpInside];
    }
    return _rePlayBtn;
}

- (MDHVideoToolBar *)toolBar {
    
    if (!_toolBar) {
        
        _toolBar = [[MDHVideoToolBar alloc] initWithFrame:CGRectZero];
        _toolBar.customDelegate = self;
    }
    
    return _toolBar;
}

- (MDHVideoFastForwardBackView *)fastForwardBackView {
    
    if (!_fastForwardBackView) {
        
        _fastForwardBackView = [[MDHVideoFastForwardBackView alloc] initWithFrame:CGRectZero];
        _fastForwardBackView.backgroundColor     = [UIColor colorWithRed: 0/255.0f
                                                                   green: 0/255.0f
                                                                    blue: 0/255.0f
                                                                   alpha: 0.8];
        _fastForwardBackView.layer.cornerRadius  = 10;
        _fastForwardBackView.layer.masksToBounds = YES;
    }
    
    return _fastForwardBackView;
}



#pragma mark - Button method

- (void)readyToPlayBtnClick:(UIButton *)button {
    
    self.alreadyPlayed         = YES;
    self.readyToPlayBtn.hidden = YES;
    self.toolBar.hidden        = NO;

    if (self.delegate && [self.delegate respondsToSelector: @selector(MDHVideoControlView:play:)]) {
        
        [self.delegate MDHVideoControlView: self
                                      play: YES];
    }
}

- (void)rePlayBtnClick:(UIButton *)button {
    
    self.rePlayBtn.hidden = YES;
    self.toolBar.hidden   = NO;

    if (self.delegate && [self.delegate respondsToSelector: @selector(MDHVideoControlViewRePlay:)]) {
        
        [self.delegate MDHVideoControlViewRePlay: self];
    }
}



#pragma mark - MDHVideoToolBarDelegate

- (void)MDHVideoToolBar:(MDHVideoToolBar *)videoToolBar play:(BOOL)play {

    if (self.delegate && [self.delegate respondsToSelector: @selector(MDHVideoControlView:play:)]) {
        
        [self.delegate MDHVideoControlView: self
                                      play: play];
    }
}


- (void)MDHVideoToolBarBeginDragSlider:(MDHVideoToolBar *)videoToolBar {
    
    self.fastForwardBackView.hidden = NO;
    
    if (self.delegate && [self.delegate respondsToSelector: @selector(MDHVideoControlView:play:)]) {
        
        [self.delegate MDHVideoControlView: self
                                      play: NO];
    }
}

- (void)MDHVideoToolBarDragingSlider:(MDHVideoToolBar *)videoToolBar {

    [MDHVideoDataModel sharedInstance].currentSecond = videoToolBar.sliderValue;
   
    [self updateCurrentTime];

    [self.fastForwardBackView updateImage: [MDHVideoDataModel sharedInstance].isForward
                                 progress: [MDHVideoDataModel sharedInstance].playProgress
                                alertTime: [MDHVideoDataModel sharedInstance].forwardBackTimeString];
    
    
}

- (void)MDHVideoToolBarFinishDragSlider:(MDHVideoToolBar *)videoToolBar {

    self.fastForwardBackView.hidden = YES;
    
    if (self.delegate && [self.delegate respondsToSelector: @selector(MDHVideoControlView:seekToTime:)]) {
        
        [self.delegate MDHVideoControlView: self
                                seekToTime: videoToolBar.sliderValue];
    }
}

- (void)MDHVideoToolBarFullScreen:(MDHVideoToolBar *)videoToolBar {
    
    if (self.delegate && [self.delegate respondsToSelector: @selector(MDHVideoControlViewFullScreen:)]) {
        
        [self.delegate MDHVideoControlViewFullScreen: self];
    }
}



#pragma mark - Touches

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    if (self.alreadyPlayed) {
        
        self.toolBarHiden   = !self.toolBarHiden;
        self.toolBar.hidden = self.toolBarHiden;
    }
}



#pragma mark - UIPanGestureRecognizer

- (void)panDirection:(UIPanGestureRecognizer *)pan {
    
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [pan velocityInView:self];
    
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{ // 开始移动
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { // 水平移动
                
                self.sumTime = [MDHVideoDataModel sharedInstance].currentSecond;

                self.HorizontalMoved = YES;
                
                self.fastForwardBackView.hidden = NO;
                
                if (self.delegate && [self.delegate respondsToSelector: @selector(MDHVideoControlView:play:)]) {
                    
                    [self.delegate MDHVideoControlView: self
                                                  play: NO];
                }
                
                [MDHVideoDataModel sharedInstance].currentSecond = self.sumTime;
                [self updateCurrentTime];
                [self.fastForwardBackView updateImage: [MDHVideoDataModel sharedInstance].isForward
                                             progress: [MDHVideoDataModel sharedInstance].playProgress
                                            alertTime: [MDHVideoDataModel sharedInstance].forwardBackTimeString];

            } else if (x < y){ // 垂直移动
                
                self.HorizontalMoved = NO;
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            
            if (self.HorizontalMoved) { // 水平运动
                
                // 每次滑动需要叠加时间 KPanGestureParam > 例如 200 滑动距离差50的话就增加1秒， 400的话距离差100才增加1秒
                self.sumTime += veloctyPoint.x / KPanGestureParam;
                
                // 需要限定sumTime的范围
                CGFloat totalMovieDuration = [MDHVideoDataModel sharedInstance].totalSecond;
                if (self.sumTime > totalMovieDuration) {
                    self.sumTime = totalMovieDuration;
                }
                if (self.sumTime < 0) {
                    self.sumTime = 0;
                }

                [MDHVideoDataModel sharedInstance].currentSecond = self.sumTime;
                [self updateCurrentTime];
                [self.fastForwardBackView updateImage: [MDHVideoDataModel sharedInstance].isForward
                                             progress: [MDHVideoDataModel sharedInstance].playProgress
                                            alertTime: [MDHVideoDataModel sharedInstance].forwardBackTimeString];

            }
            break;
        }
        case UIGestureRecognizerStateEnded:{ // 移动停止
            
            self.fastForwardBackView.hidden = YES;
            
            if (self.delegate && [self.delegate respondsToSelector: @selector(MDHVideoControlView:seekToTime:)]) {
                
                [self.delegate MDHVideoControlView: self
                                        seekToTime: self.sumTime];
            }
        }
        default:
            break;
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

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


@end


static const CGFloat KReadyToPlayBtnWidth        = 60;  // 启动播放按钮宽度（高度）正方形
static const CGFloat KFastForwardBackViewWidth   = 125; // 快进提示View宽度
static const CGFloat KFastForwardBackViewHeight  = 100; // 快进提示View高度
static const CGFloat KToolBarHeight              = 40;  // 工具View高度


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
            
            make.left.right.bottom.equalTo(@0);
            make.height.equalTo(@(KToolBarHeight));
            
        }];

        [self.indicatorView startAnimating];

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






#pragma mark - Layz load


- (UIActivityIndicatorView *)indicatorView {
    
    if (!_indicatorView) {
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        
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
    return _readyToPlayBtn;
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
    
    self.firstPlay             = YES;
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

    
//    self.firstPlay             = YES;
//    self.readyToPlayBtn.hidden = YES;
//    self.toolBar.hidden        = NO;
//    
//    if (self.delegate && [self.delegate respondsToSelector: @selector(MDHVideoControlView:play:)]) {
//        
//        [self.delegate MDHVideoControlView: self
//                                      play: YES];
//    }
}



#pragma mark - MDHVideoToolBarDelegate

- (void)MDHVideoToolBar:(MDHVideoToolBar *)videoToolBar play:(BOOL)play {

    if (self.delegate && [self.delegate respondsToSelector: @selector(MDHVideoControlView:play:)]) {
        
        [self.delegate MDHVideoControlView: self
                                      play: play];
    }
}




#pragma mark - Touches

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    if (self.firstPlay) {
        
        self.toolBarHiden   = !self.toolBarHiden;
        self.toolBar.hidden = self.toolBarHiden;
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

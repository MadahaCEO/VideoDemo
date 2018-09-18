//
//  PlayerViewController.m
//  VideoDemo
//
//  Created by Apple on 2018/9/11.
//  Copyright © 2018年 马大哈. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>



static float const kTimeRefreshInterval = 0.5;

static NSString *const kStatus                   = @"status";
static NSString *const kLoadedTimeRanges         = @"loadedTimeRanges";
static NSString *const kPlaybackBufferEmpty      = @"playbackBufferEmpty";
static NSString *const kPlaybackLikelyToKeepUp   = @"playbackLikelyToKeepUp";
static NSString *const kPresentationSize         = @"presentationSize";


@interface PlayerViewController ()
{
    id _timeObserver;
    id _itemEndObserver;
}


@property (nonatomic, strong) UIButton  *playBtn;
@property (nonatomic, strong) UILabel   *currentTimeLabel;     // 当前播放时间
@property (nonatomic, strong) UIActivityIndicatorView  *activityView;
@property (nonatomic, strong) UISlider  *slider;
@property (nonatomic, strong) UIProgressView  *bufferProgressView;

@property (nonatomic, strong) AVURLAsset     *urlAsset;
@property (nonatomic, strong) AVPlayerItem   *playerItem;
@property (nonatomic, strong) AVPlayer       *player;
@property (nonatomic, strong) AVPlayerLayer  *playerLayer;

@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) NSTimeInterval totalTime;

@property (nonatomic, assign) BOOL isBuffering;  /* 正在缓冲 */
@property (nonatomic, assign) BOOL isPlaying;  /* 正在播放 */
@property (nonatomic, assign) BOOL isSliding;  /* 正在拖动 */
@property (nonatomic, assign) BOOL isOtherAudioPlaying;  /* 有其他音频播放 */


@end

@implementation PlayerViewController



- (UIProgressView *)bufferProgressView {
    
    if (!_bufferProgressView) {
        
        _bufferProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(50, 580, self.view.frame.size.width - 100, 20)];
        _bufferProgressView.progressViewStyle = UIProgressViewStyleDefault;
        _bufferProgressView.progressTintColor = [UIColor redColor];
        _bufferProgressView.trackTintColor    = [UIColor clearColor];
        
    }
    
    return _bufferProgressView;
}

- (UISlider *)slider {
    
    if (!_slider) {
        _slider = [[UISlider alloc] initWithFrame:CGRectMake(50, 550, self.view.frame.size.width - 100, 20)];
        [_slider addTarget:self action:@selector(sliderValueChanging:) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchUpInside];
        
        _slider.maximumValue = 1.0;
    }
    return _slider;
}

- (UIActivityIndicatorView *)activityView {
    
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return _activityView;
}

- (UIButton *)playBtn {
    
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _playBtn.frame = CGRectMake(0, 450, self.view.frame.size.width, 50);
        _playBtn.backgroundColor = [UIColor blackColor];
        [_playBtn setTitle:@"暂停" forState: UIControlStateNormal];
        [_playBtn setTitle:@"播放" forState: UIControlStateSelected];
        [_playBtn addTarget: self
                     action: @selector(playBtnClick:)
           forControlEvents: UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UILabel *)currentTimeLabel {
    
    if (!_currentTimeLabel) {
        
        _currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 500, self.view.frame.size.width, 50)];
        _currentTimeLabel.backgroundColor = [UIColor whiteColor];
        _currentTimeLabel.textColor = [UIColor blackColor];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _currentTimeLabel;
}


#pragma mark - action

- (void)play {
    
    [self.player play];
    self.isPlaying = YES;
    
    /*
     //注意更改播放速度要在视频开始播放之后才会生效
     相当于视频快进，加速播放，说话速度特别快。
     
    self.player.rate = 1.5;
*/
}

- (void)pause {
    
    [self.player pause];
    self.isPlaying = NO;
    
}

- (void)stop {

}


- (void)sliderValueChanging:(UISlider *)sli {
    
    self.isSliding = YES;
    
    float value = (sli.value <= 0) ? 0.0 : sli.value;
    value       =  (sli.value >= 1.0) ? 1.0 : sli.value;
    
    NSString *currentTimeString = [self convertTimeSecond:self.totalTime*value];
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%@ / %@",currentTimeString,[self convertTimeSecond:self.totalTime]];
}

- (void)sliderValueChanged:(UISlider *)sli {
    
    
    float value = (sli.value <= 0) ? 0.0 : sli.value;
    value       =  (sli.value >= 1.0) ? 1.0 : sli.value;
    
    
    __weak typeof(self)weakSelf = self;
    
    [self seekToTime:self.totalTime*value completionHandler:^(BOOL finished) {
        
        __strong typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.isSliding = NO;
        
        if (finished) {
            [strongSelf play];
        }
    }];
}

- (void)playBtnClick:(UIButton *)button {
    
    button.selected = !button.selected;
    
    if (button.selected) {
        
        [self pause];
        
    } else {
        
        [self play];
        
    }
}

- (void)enableAudioTracks:(BOOL)enable inPlayerItem:(AVPlayerItem*)playerItem {
    for (AVPlayerItemTrack *track in playerItem.tracks){
        if ([track.assetTrack.mediaType isEqual:AVMediaTypeVideo]) {
            track.enabled = enable;
        }
    }
}

- (void)switchSession {
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    if (session.otherAudioPlaying) {
        
        self.isOtherAudioPlaying = YES;
        
        NSError *error = nil;
        [session setCategory:AVAudioSessionCategoryPlayback error:&error];
        
        if (error) {
            [session setActive:YES error:&error];
            
            if (error) {
                NSLog(@"《《《《《《《《《《 播放会话建立失败 》》》》》》》》》》");
            }
        }
    }
}



#pragma mark - player info

- (void)updateTimeLabel {
    
    if (!self.isSliding) {
        
        self.currentTimeLabel.text = [NSString stringWithFormat:@"%@ / %@",[self convertTimeSecond:self.currentTime],[self convertTimeSecond:self.totalTime]];
        
        self.slider.value = self.currentTime / self.totalTime;
    }
}


- (NSString *)convertTimeSecond:(NSInteger)timeSecond {
    NSString *theLastTime = nil;
    long second = timeSecond;
    if (timeSecond < 60) {
        theLastTime = [NSString stringWithFormat:@"00:%02zd", second];
    } else if(timeSecond >= 60 && timeSecond < 3600){
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd", second/60, second%60];
    } else if(timeSecond >= 3600){
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd:%02zd", second/3600, second%3600/60, second%60];
    }
    return theLastTime;
}


- (NSTimeInterval)totalTime {
    NSTimeInterval sec = CMTimeGetSeconds(self.player.currentItem.duration);
    if (isnan(sec)) {
        return 0;
    }
    return sec;
}

- (NSTimeInterval)currentTime {
    NSTimeInterval sec = CMTimeGetSeconds(self.playerItem.currentTime);
    if (isnan(sec)) {
        return 0;
    }
    return sec;
}



#pragma mark - Player KVO

- (void)addKVO {
   
    /*
     播放状态：
     
     */
    [self.playerItem addObserver: self
                      forKeyPath: kStatus
                         options: NSKeyValueObservingOptionNew
                         context: nil];
   
    /*
     */
    [self.playerItem addObserver: self
                      forKeyPath: kPlaybackBufferEmpty
                         options: NSKeyValueObservingOptionNew
                         context: nil];
    /*
     */
    [self.playerItem addObserver: self
                      forKeyPath: kPlaybackLikelyToKeepUp
                         options: NSKeyValueObservingOptionNew
                         context: nil];
    /*
     */
    [self.playerItem addObserver: self
                      forKeyPath: kLoadedTimeRanges
                         options: NSKeyValueObservingOptionNew
                         context: nil];
    
    
    __weak typeof(self)weakSelf = self;
    
    /*
     
    typedef struct{
        CMTimeValue    value;     // 帧数
        CMTimeScale    timescale;  // 帧率（影片每秒有几帧）
        CMTimeFlags    flags;
        CMTimeEpoch    epoch;
    } CMTime;
   
     CMTime是以分数的形式表示时间，value表示分子，timescale表示分母，flags是位掩码，表示时间的指定状态。
     */
    // 更新频率，用于更新当前播放进度。
    CMTime interval = CMTimeMakeWithSeconds(kTimeRefreshInterval, NSEC_PER_SEC);
    
    _timeObserver = [self.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        
        NSArray *loadedRanges = strongSelf.playerItem.seekableTimeRanges;
        if (loadedRanges.count > 0) {
            
            [strongSelf updateTimeLabel];
        }
    }];
    
    /*
     视频是否播放完毕
     */
    _itemEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        

    }];
    
}

/**
 *  缓冲较差时候回调这里
 */
- (void)bufferingSomeSecond {
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    if (self.isBuffering) return;
    self.isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.player pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 如果此时用户已经暂停了，则不再需要开启播放了
        if (!self.isPlaying) {
            self.isBuffering = NO;
            return;
        }
        [self play];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        self.isBuffering = NO;
        if (!self.playerItem.isPlaybackLikelyToKeepUp) {
            
            [self bufferingSomeSecond];
        }
    });
}

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    CMTime seekTime = CMTimeMake(time, 1);
    [_playerItem cancelPendingSeeks];
    [_player seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:completionHandler];
}

/// Calculate buffer progress
- (NSTimeInterval)availableDuration {
    
//    NSArray *array = _playerItem.loadedTimeRanges;
//    CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
//    float startSeconds = CMTimeGetSeconds(timeRange.start);
//    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
//    NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
    
    // 已经缓存的时间集合
    NSArray *timeRangeArray = _playerItem.loadedTimeRanges;
    // 当前播放器的时间进度
    CMTime currentTime = [_player currentTime];
    BOOL foundRange = NO;
    CMTimeRange aTimeRange = {0};
    if (timeRangeArray.count > 0) {
        aTimeRange = [timeRangeArray.firstObject CMTimeRangeValue]; // 缓冲的时间范围（缓冲区域）
       
        // 缓冲的时间范围是否包含当前播放进度
        if (CMTimeRangeContainsTime(aTimeRange, currentTime)) {
            foundRange = YES;
        }
    }
    
    if (foundRange) {
        CMTime maxTime = CMTimeRangeGetEnd(aTimeRange);
        NSTimeInterval playableDuration = CMTimeGetSeconds(maxTime);
        if (playableDuration > 0) {
            return playableDuration;
        }
    }
    return 0;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        /*
         监听status属性，当status的状态变为AVPlayerStatusReadyToPlay时，说明视频就可以播放了，
         此时我们调用[self.player play]
         如果是AVPlayerStatusFailed说明视频加载失败，这时可以通过self.player.error.description属性来找出具体的原因。
         */
        if ([keyPath isEqualToString:kStatus]) {
            
            if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                
                [self.activityView stopAnimating];
                self.playBtn.hidden = NO;
                
                if (self.seekTime) {
                    [self seekToTime:self.seekTime completionHandler:nil];
                    self.seekTime = 0; // 滞空, 防止下次播放出错
                }
                if (self.isPlaying) {
                    [self play];
                }
                
                NSArray *loadedRanges = self.playerItem.seekableTimeRanges;
                if (loadedRanges.count > 0) {
                    [self updateTimeLabel];
                }
            } else if (self.player.currentItem.status == AVPlayerItemStatusFailed) {

                [self.activityView stopAnimating];
                self.playBtn.hidden = NO;
                
                NSError *error = self.player.currentItem.error;
                NSLog(@"播放状态失败-----------%@",error.description);
            }
        } else if ([keyPath isEqualToString:kPlaybackBufferEmpty]) {
           
            /*
             当前视频缓存是否充足，若缓冲太少继续缓冲，动画继续。
             */
            if (self.playerItem.playbackBufferEmpty) {

                [self.activityView startAnimating];
                self.playBtn.hidden = YES;
                
                [self bufferingSomeSecond];
            }
        } else if ([keyPath isEqualToString:kPlaybackLikelyToKeepUp]) {
           
            /*
             playbackLikelyToKeepUp和playbackBufferEmpty是一对，用于监听缓存足够播放的状态
             由于 AVPlayer 缓存不足就会自动暂停，所以缓存充足了需要手动播放，才能继续播放
             */
            if (self.playerItem.playbackLikelyToKeepUp) {

                [self.activityView stopAnimating];
                self.playBtn.hidden = NO;
                
            }
        } else if ([keyPath isEqualToString:kLoadedTimeRanges]) {
            
            /*
             loadedTimeRanges: 当前视频缓存情况
             */
            if (self.isPlaying && self.playerItem.playbackLikelyToKeepUp) {
                [self play];
            }
            NSTimeInterval bufferTime = [self availableDuration];
            self.bufferProgressView.progress = bufferTime / self.totalTime;
        }
    });
}


#pragma mark - add subviews

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
    [self switchSession];
    
    
    NSString *URLString = [@"http://flv3.bn.netease.com/videolib3/1709/05/nvGOU4436/SD/nvGOU4436-mobile.mp4" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    self.urlAsset    = [AVURLAsset assetWithURL:[NSURL URLWithString:URLString]];
    self.playerItem  = [AVPlayerItem playerItemWithAsset:self.urlAsset];
    self.player      = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    
    // 显示视频图像层
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self enableAudioTracks:YES inPlayerItem:_playerItem];
    
    self.playerLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 9/16);
    self.playerLayer.backgroundColor = [UIColor  blackColor].CGColor;
    [self.view.layer addSublayer:self.playerLayer];
    
    
    if (@available(iOS 9.0, *)) {
        /*
         新属性canUseNetworkResourcesForLiveStreamingWhilePaused， iOS9系统以前默认开启，iOS9默认关闭，
         如果需要减少性能消耗，在视频流暂停的时候，如果不需要使用播放状态可以把这个属性设为关闭。
         */
        self.playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = NO;
    }
    if (@available(iOS 10.0, *)) {
        
        /*
         preferredForwardBufferDuration
         播放之前先缓存一段时间
         
         automaticallyWaitsToMinimizeStalling
         当播放HLS媒体时,  automaticallyWaitsToMinimizeStalling 的值为 true.
         当播放基于文件的媒体, 包括逐渐下载的内容,  automaticallyWaitsToMinimizeStalling 的值为 false.
         */
        self.playerItem.preferredForwardBufferDuration = 1;
        self.player.automaticallyWaitsToMinimizeStalling = NO;
    }
    
    [self addKVO];
    
    [self play];
    
    
    
    [self.view addSubview:self.playBtn];
    
    [self.view addSubview:self.currentTimeLabel];
    
    
    [self.view addSubview:self.activityView];
    self.activityView.center = CGPointMake(self.playerLayer.frame.size.width / 2, self.playerLayer.frame.size.height / 2);
    
    [self.activityView startAnimating];
    self.playBtn.hidden = YES;
    
    
    [self.view addSubview:self.slider];
    
    [self.view addSubview:self.bufferProgressView];
    
    
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:_itemEndObserver
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:self.playerItem];
   
    [self.player removeTimeObserver:_timeObserver];
    _timeObserver = nil;
    
    [_playerItem removeObserver:self forKeyPath:kStatus];
    [_playerItem removeObserver:self forKeyPath:kPlaybackBufferEmpty];
    [_playerItem removeObserver:self forKeyPath:kPlaybackLikelyToKeepUp];
    [_playerItem removeObserver:self forKeyPath:kLoadedTimeRanges];
    _playerItem = nil;
    
    if (self.isOtherAudioPlaying) {
        
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    }
    NSLog(@"===============");
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

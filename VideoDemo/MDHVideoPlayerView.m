//
//  MDHVideoPlayerView.m
//  VideoDemo
//
//  Created by Apple on 2017/9/12.
//  Copyright © 2017年 马大哈. All rights reserved.
//

#import "MDHVideoPlayerView.h"

// 系统+第三方头文件
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"

// 自定义类头文件
#import "MDHVideoControlView.h"
#import "MDHVideoDataModel.h"


@interface MDHVideoPlayerView ()
<MDHVideoControlViewDelegate>

@property (nonatomic, strong) AVURLAsset     *urlAsset;
@property (nonatomic, strong) AVPlayer       *player;
@property (nonatomic, strong) AVPlayerItem   *playerItem;
@property (nonatomic, strong) AVPlayerLayer  *playerLayer;
@property (nonatomic, strong) NSObject       *playbackTimeObserver;


@property (nonatomic, assign) BOOL playing;
@property (nonatomic, assign) BOOL canDrag;
@property (nonatomic, assign) BOOL toobBarValid;

//@property (nonatomic, assign) BOOL toobBarValid;


@property (nonatomic, strong) MDHVideoControlView  *videoControlView;


@end



#define MDHNotificationCenter    [NSNotificationCenter defaultCenter]

#define CustomScheme    @"CustomScheme"

static NSString * const KObserverKeyPath_Status                  = @"status";
static NSString * const KObserverKeyPath_LoadedTimeRanges        = @"loadedTimeRanges";
static NSString * const KObserverKeyPath_PlaybackBufferEmpty     = @"playbackBufferEmpty";
static NSString * const KObserverKeyPath_PlaybackLikelyToKeepUp  = @"playbackLikelyToKeepUp";


@implementation MDHVideoPlayerView



- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playerItem removeObserver:self forKeyPath: KObserverKeyPath_Status];
    [self.playerItem removeObserver:self forKeyPath: KObserverKeyPath_LoadedTimeRanges];
    [self.playerItem removeObserver:self forKeyPath: KObserverKeyPath_PlaybackBufferEmpty];
    [self.playerItem removeObserver:self forKeyPath: KObserverKeyPath_PlaybackLikelyToKeepUp];
    [self.player     removeTimeObserver:self.playbackTimeObserver];
    self.playbackTimeObserver = nil;
    self.playerItem = nil;
    
}


- (instancetype)initWithFrame:(CGRect)frame videoAddress:(NSString *)urlString {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];

        NSURL *videoURL = nil;
        
        if (urlString && [urlString isKindOfClass:[NSString class]] && urlString.length > 0) {
            
            if ([urlString hasPrefix:@"http"]) {
                
                videoURL = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                
            } else {
            
                if ([[NSFileManager defaultManager] fileExistsAtPath:urlString]) {
                    
                    videoURL       = [NSURL fileURLWithPath:urlString];
                }
            }
        }
        
        if (videoURL) {
            
            self.urlAsset    = [AVURLAsset assetWithURL:videoURL];
            self.playerItem  = [AVPlayerItem playerItemWithAsset:self.urlAsset];
            self.player      = [AVPlayer playerWithPlayerItem:self.playerItem];
            self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
            
            self.playerLayer.frame = self.frame;
            [self.layer addSublayer:self.playerLayer];
            
            [self addNotification];
            [self addMonitoring];
            
            [self addSubview: self.videoControlView];
            
        }
    }
    
    return  self;
}



#pragma mark - For outer




#pragma mark - Layz load

- (MDHVideoControlView *)videoControlView {
    
    if (!_videoControlView) {
        
        _videoControlView = [[MDHVideoControlView alloc] initWithFrame: self.frame];
        _videoControlView.delegate = self;
    }
    
    return _videoControlView;
}


#pragma mark - Notification

- (void)addNotification {
    
    // 完全退入后台，暂停播放---点击home键退出程序
    [MDHNotificationCenter addObserver: self
                              selector: @selector(appDidEnterBackgroundNotifi)
                                  name: UIApplicationDidEnterBackgroundNotification
                                object: nil];
    
    // 应用挂起，暂停播放---双击 Home 键、来电话等操作
    [MDHNotificationCenter addObserver: self
                              selector: @selector(appDidEnterBackgroundNotifi)
                                  name: UIApplicationWillResignActiveNotification
                                object: nil];
    
    // 回到前台
    [MDHNotificationCenter addObserver: self
                              selector: @selector(appDidBecomeActiveNotifi)
                                  name: UIApplicationDidBecomeActiveNotification
                                object: nil];
    
    // 视频播放结束
    [MDHNotificationCenter addObserver: self
                              selector: @selector(videoDidPlayToEndNotifi:)
                                  name: AVPlayerItemDidPlayToEndTimeNotification
                                object: self.playerItem];
    
    // 视频播放卡顿
    [MDHNotificationCenter addObserver: self
                              selector: @selector(videoPlaybackStalledNotifi:)
                                  name: AVPlayerItemPlaybackStalledNotification
                                object: self.playerItem];
    
    // 设备插入耳机
    [MDHNotificationCenter addObserver: self
                              selector: @selector(audioRouteChangeListenerCallback:)
                                  name: AVAudioSessionRouteChangeNotification
                                object: nil];
}


- (void)appDidEnterBackgroundNotifi {
    
    [self.player pause];
    
    NSLog(@"app进入后台");

}

- (void)appDidBecomeActiveNotifi {
    
//    [self.player play];
   
    NSLog(@"app回到前台");
}

- (void)videoDidPlayToEndNotifi:(NSNotification *)notif {
    
    [self.videoControlView playToEnd];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"播放结束"
                                                    message: nil
                                                   delegate: nil
                                          cancelButtonTitle: @"退出"
                                          otherButtonTitles: nil];
    [alert show];
    
}

- (void)videoPlaybackStalledNotifi:(NSNotification *)notif {
    
//    [self.indicatorView startAnimating];
    
    NSLog(@" \n\n\n\n ********************视频卡顿********************  \n\n\n\n");
}

/** 声音线路改变
 *  耳机插入、拔出事件
 */
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification {
    
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason   = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // 耳机插入
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            // 耳机拔掉
            // 拔掉耳机继续播放
            //            [self play];
        }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}



#pragma mark - Monitoring (监听)

- (void)addMonitoring {
    
    [self.playerItem addObserver: self
                      forKeyPath: KObserverKeyPath_Status
                         options: NSKeyValueObservingOptionNew
                         context: nil];
    [self.playerItem addObserver: self
                      forKeyPath: KObserverKeyPath_LoadedTimeRanges
                         options: NSKeyValueObservingOptionNew
                         context: nil];
    [self.playerItem addObserver: self
                      forKeyPath: KObserverKeyPath_PlaybackBufferEmpty
                         options: NSKeyValueObservingOptionNew
                         context: nil];
    [self.playerItem addObserver: self
                      forKeyPath: KObserverKeyPath_PlaybackLikelyToKeepUp
                         options: NSKeyValueObservingOptionNew
                         context: nil];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    
    AVPlayerItem *item = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString: KObserverKeyPath_Status]) {
        if (item.status == AVPlayerItemStatusReadyToPlay) {
            
            CGFloat durationSeconds = CMTimeGetSeconds(item.duration);
            NSLog(@" \n\n视频总时间  %f\n\n",durationSeconds);
            [MDHVideoDataModel sharedInstance].totalSecond   = durationSeconds;
            [self.videoControlView updateTotalTime];
            
            __weak typeof(self) weakSelf = self;
            self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1)
                                                                                  queue:NULL
                                                                             usingBlock:^(CMTime time) {
                                                                               
                                                                                 [weakSelf monitoringPlayback:item];
                                                                                 
                                                                             }];

            
        } else if (item.status == AVPlayerItemStatusFailed ||
                   item.status == AVPlayerItemStatusUnknown) {
            
            [self.videoControlView stopAnimating];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"视频播放失败"
                                                            message: item.error.description
                                                           delegate: nil
                                                  cancelButtonTitle: @"退出"
                                                  otherButtonTitles: nil];
            [alert show];
        }
    } else if ([keyPath isEqualToString: KObserverKeyPath_LoadedTimeRanges]) {  //监听播放器的缓冲进度
        
        [self calculateDownloadProgress:item];
        
    } else if ([keyPath isEqualToString: KObserverKeyPath_PlaybackBufferEmpty]) { // 没有足够缓冲播放
        
        NSLog(@"缓冲不足暂停了");
        [self.videoControlView startAnimating];

        if (item.isPlaybackBufferEmpty) {
            
            [self bufferingSomeSecond];
        }
    } else if ([keyPath isEqualToString: KObserverKeyPath_PlaybackLikelyToKeepUp]) {
        
        if (item.playbackLikelyToKeepUp){
            NSLog(@"缓冲达到可播放程度了");

            NSLog(@" \n\n\n\n ********************playbackLikelyToKeepUp********************  \n\n\n\n");
            if (![MDHVideoDataModel sharedInstance].alreadyPlay && [MDHVideoDataModel sharedInstance].bufferProgress > 0.1) {
                
                [self.videoControlView readyToPlay: YES];
            }

            [self.videoControlView stopAnimating];

        }

    }
}



#pragma mark - Helper

- (void)monitoringPlayback:(AVPlayerItem *)item {
  
    CGFloat currentSec = item.currentTime.value/item.currentTime.timescale;
    [MDHVideoDataModel sharedInstance].currentSecond = currentSec;

    [self.videoControlView updateCurrentTime];
    
//    NSLog(@" \n\n视频每秒监听  %f\n\n",currentSec);
}


- (void)calculateDownloadProgress:(AVPlayerItem *)playerItem {
    
    NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
    CMTime duration = playerItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(duration);
    
    CGFloat progress = timeInterval / totalDuration;
    [MDHVideoDataModel sharedInstance].bufferProgress = progress;
    
    if (![MDHVideoDataModel sharedInstance].alreadyPlay && progress > 0.1) {
        
        [self.videoControlView readyToPlay: YES];
    }
    
    [self.videoControlView updateBufferProgress:timeInterval / totalDuration];
}


- (void)bufferingSomeSecond {
   
    self.playing = NO;
    [self.videoControlView startAnimating];

    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.player pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        //        isBuffering = NO;
        if (self.playerItem.isPlaybackLikelyToKeepUp) {
            
            [self.player play];
            [self.videoControlView stopAnimating];
            
        } else {
            
            [self bufferingSomeSecond];
        }
    });
}




#pragma mark - MDHVideoControlViewDelegate

- (void)MDHVideoControlView:(MDHVideoControlView *)controlView play:(BOOL)play {

    if (play) {
        
        [MDHVideoDataModel sharedInstance].alreadyPlay = YES;
        [self.player play];
        
    } else {
        
        [self.player pause];
    }
}

- (void)MDHVideoControlViewRePlay:(MDHVideoControlView *)controlView {
    
//    [self.videoControlView startAnimating];
//    [self.player pause];
//
//    __weak typeof(self) weakSelf = self;
//    
//    [self.player seekToTime: CMTimeMake(0, 1)
//            toleranceBefore: CMTimeMake(1,1)
//             toleranceAfter: CMTimeMake(1,1)
//          completionHandler: ^(BOOL finished) {
//              
//              if (weakSelf.playerItem.isPlaybackLikelyToKeepUp) {
//                  
//                  [weakSelf.player play];
//                  [weakSelf.videoControlView stopAnimating];
//              }
//          }];
}

- (void)MDHVideoControlView:(MDHVideoControlView *)controlView seekToTime:(CGFloat)skipTime {

    [self.videoControlView startAnimating];
    [self.player pause];
    
    NSLog(@"开始跳转播放");
    
    __weak typeof(self) weakSelf = self;
    
    [self.player seekToTime: CMTimeMake(skipTime, 1)
            toleranceBefore: CMTimeMake(1,1)
             toleranceAfter: CMTimeMake(1,1)
          completionHandler: ^(BOOL finished) {
        
              if (weakSelf.playerItem.isPlaybackLikelyToKeepUp) {
                  
                  NSLog(@"跳转完成启动播放");

                  [weakSelf.player play];
                  [weakSelf.videoControlView stopAnimating];
              }
    }];
}

- (void)MDHVideoControlViewFullScreen:(MDHVideoControlView *)controlView {


}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

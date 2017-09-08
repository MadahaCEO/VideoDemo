//
//  ViewController.m
//  VideoDemo
//
//  Created by Apple on 2017/9/7.
//  Copyright © 2017年 马大哈. All rights reserved.
//

#import "ViewController.h"

#import "VideoToolBar.h"


#define MDHNotificationCenter    [NSNotificationCenter defaultCenter]


@interface ViewController ()<VideoToolBarDelegate>

@property (nonatomic, strong) AVURLAsset     *urlAsset;
@property (nonatomic, strong) AVPlayer       *player;
@property (nonatomic, strong) AVPlayerItem   *playerItem;
@property (nonatomic, strong) AVPlayerLayer  *playerLayer;
@property (nonatomic, strong) NSObject       *playbackTimeObserver;

@property (nonatomic, strong) UIImageView    *coverPlanImageView;
@property (nonatomic, strong) UIActivityIndicatorView    *indicatorView;



@property (nonatomic, strong) VideoToolBar  *bottomToolbar;

@end

@implementation ViewController


- (void)dealloc {
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.player     removeTimeObserver:self.playbackTimeObserver];
    self.playbackTimeObserver = nil;
    self.playerItem = nil;
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //    NSString *test1 = @"行";
    //    NSString *test2 = @"李长行";
    //    MDHLog(@" %@====%@",test1.firstLetter, test2.toPinyin);
    //    @[@"X",@"H"]====@[@"li zhang xing",@"li zhang hang",@"li zhang heng",@"li chang xing",@"li chang hang",@"li chang heng"]
    
    
    NSURL *url = [NSURL URLWithString:[@"http://flv3.bn.netease.com/videolib3/1709/07/FCjLY8342/HD/FCjLY8342-mobile.mp4" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    self.urlAsset    = [AVURLAsset assetWithURL:url];
    self.playerItem  = [AVPlayerItem playerItemWithAsset:self.urlAsset];
    self.player      = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    self.playerLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 40 -64);
    
    [self.view.layer addSublayer:self.playerLayer];
    
    
    
    [self addNotification];
    [self addMonitoring];
    
    
    
    [self.view addSubview: self.coverPlanImageView];
    
    [self.view addSubview: self.bottomToolbar];
    
    [self.view addSubview: self.indicatorView];
    
    [self thumbnailImageOfVideo];
    
    [self.indicatorView startAnimating];
    
    /*
     
     _openButton = [UIButton buttonWithType:0];
     _openButton.backgroundColor = [UIColor redColor];
     _openButton.frame = CGRectMake(100, 100, 500, 100);
     _openButton.titleLabel.font = [UIFont systemFontOfSize:30];
     [_openButton setTitleColor:[UIColor whiteColor] forState:0];
     [_openButton setTitle: _T_(@"test", nil) forState:0];
     
     [_openButton addTarget:self action:@selector(switchCategoryView) forControlEvents:UIControlEventTouchUpInside];
     [self.view addSubview:_openButton];
     
     
     UIButton *dataButton = [UIButton buttonWithType:0];
     dataButton.backgroundColor = [UIColor blackColor];
     dataButton.frame = CGRectMake(300, 300, 100, 100);
     [dataButton addTarget:self action:@selector(dataButtonClicked) forControlEvents:UIControlEventTouchUpInside];
     [self.view addSubview:dataButton];
     
     
     [self notificationAction];
     
     */
}


- (void)thumbnailImageOfVideo {
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString *urlStr=@"http://flv3.bn.netease.com/videolib3/1709/07/FCjLY8342/HD/FCjLY8342-mobile.mp4";
        urlStr=[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url=[NSURL URLWithString:urlStr];
        
        
        //根据url创建AVURLAsset
        AVURLAsset *urlAsset=[AVURLAsset assetWithURL:url];
        //根据AVURLAsset创建AVAssetImageGenerator
        AVAssetImageGenerator *imageGenerator=[AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
        /*截图
         * requestTime:缩略图创建时间
         * actualTime:缩略图实际生成的时间
         */
        NSError *error=nil;
        CMTime time=CMTimeMakeWithSeconds(1, 10);//CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法)
        CMTime actualTime;
        CGImageRef cgImage= [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
        if(error){
            NSLog(@"截取视频缩略图时发生错误，错误信息：%@",error.localizedDescription);
            return;
        }
        CMTimeShow(actualTime);
        UIImage *image=[UIImage imageWithCGImage:cgImage];//转化为UIImage
        //保存到相册
        //    UIImageWriteToSavedPhotosAlbum(image,nil, nil, nil);
        CGImageRelease(cgImage);
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            weakSelf.coverPlanImageView.image = image;
            
        });
    });
    
    
    
}


- (UIActivityIndicatorView *)indicatorView {
    
    if (!_indicatorView) {
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, 40, 50, 50)];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        
    }
    
    return _indicatorView;
}

- (UIImageView *)coverPlanImageView {
    
    if (!_coverPlanImageView) {
        
        _coverPlanImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 40 -64)];
        _coverPlanImageView.backgroundColor = [UIColor clearColor];
        _coverPlanImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _coverPlanImageView;
}

- (UIToolbar *)bottomToolbar {
    
    
    if (!_bottomToolbar) {
        
        _bottomToolbar = [[VideoToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 120, self.view.frame.size.width, 40)];
        _bottomToolbar.barStyle = UIBarStyleDefault;
        _bottomToolbar.customDelegate = self;
        
    }
    
    return _bottomToolbar;
}





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
    
}


- (void)appDidEnterBackgroundNotifi {
    
    [self.player pause];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"APP进入后台"
                                                    message: nil
                                                   delegate: nil
                                          cancelButtonTitle: @"退出"
                                          otherButtonTitles: nil];
    [alert show];
}

- (void)appDidBecomeActiveNotifi {
    
    [self.player play];
    
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"APP回到前台"
    //                                                    message: nil
    //                                                   delegate: nil
    //                                          cancelButtonTitle: @"退出"
    //                                          otherButtonTitles: nil];
    //    [alert show];
}

- (void)videoDidPlayToEndNotifi:(NSNotification *)notif {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"播放结束"
                                                    message: nil
                                                   delegate: nil
                                          cancelButtonTitle: @"退出"
                                          otherButtonTitles: nil];
    [alert show];
    
}

- (void)videoPlaybackStalledNotifi:(NSNotification *)notif {
    
    [self.indicatorView startAnimating];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"视频卡顿"
                                                    message: nil
                                                   delegate: nil
                                          cancelButtonTitle: @"退出"
                                          otherButtonTitles: nil];
    [alert show];
}


- (void)addMonitoring {
    
    [self.playerItem addObserver:self
                      forKeyPath:@"status"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [self.playerItem addObserver:self
                      forKeyPath:@"loadedTimeRanges"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [self.playerItem addObserver:self
                      forKeyPath:@"playbackBufferEmpty"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [self.playerItem addObserver:self
                      forKeyPath:@"playbackLikelyToKeepUp"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    
    AVPlayerItem *item = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        if (item.status == AVPlayerStatusReadyToPlay) {
            
            [self monitoringPlayback:item];// 给播放器添加计时器
            
            
            
            float durationSeconds = CMTimeGetSeconds(item.duration);
            NSLog(@" \n\n视频总时间  %f\n\n",durationSeconds);
            [self.bottomToolbar updateTotalDuration:durationSeconds];
            
        } else if (item.status == AVPlayerStatusFailed ||
                   item.status == AVPlayerStatusUnknown) {
            
            //            [self stop];
        }
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {  //监听播放器的下载进度
        
        [self calculateDownloadProgress:item];
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) { //监听播放器在缓冲数据的状态
        
        if (item.isPlaybackBufferEmpty) {
            
            [self bufferingSomeSecond];
        }
        //        [[XCHudHelper sharedInstance] showHudOnView:_showView caption:nil image:nil acitivity:YES autoHideTime:0];
        //        if (playerItem.isPlaybackBufferEmpty) {
        //            self.state = TBPlayerStateBuffering;
        //            [self bufferingSomeSecond];
        //        }
    }
}


- (void)monitoringPlayback:(AVPlayerItem *)item {
    
    [self.indicatorView stopAnimating];
    
    [self.player play];
    self.coverPlanImageView.hidden = YES;
    __weak typeof(self) weakSelf = self;
    self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1)
                                                                          queue:NULL
                                                                     usingBlock:^(CMTime time) {
                                                                         
                                                                         NSLog(@"当前在第几秒 ： %lld",item.currentTime.value/item.currentTime.timescale);
                                                                         
                                                                         [weakSelf.bottomToolbar updatePlayProgress:item.currentTime.value/item.currentTime.timescale];
                                                                         
                                                                     }];
}



- (void)calculateDownloadProgress:(AVPlayerItem *)playerItem {
    
    NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
    CMTime duration = playerItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(duration);
    //    self.loadedProgress = timeInterval / totalDuration;
    //    [self.videoProgressView setProgress:timeInterval / totalDuration animated:YES];
    
    NSLog(@"\n\n缓冲进度  %f\n\n",timeInterval / totalDuration);
    
    [self.bottomToolbar updateBufferProgress:timeInterval / totalDuration];
}


- (void)bufferingSomeSecond
{
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    //    static BOOL isBuffering = NO;
    //    if (isBuffering) {
    //        return;
    //    }
    //    isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.player pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //        // 如果此时用户已经暂停了，则不再需要开启播放了
        //        if (self.isPauseByUser) {
        //            isBuffering = NO;
        //            return;
        //        }
        
        [self.player play];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        //        isBuffering = NO;
        if (!self.playerItem.isPlaybackLikelyToKeepUp) {
            [self bufferingSomeSecond];
        }
    });
}


#pragma mark - VideoToolBarDelegate

- (void)videoToolBar:(VideoToolBar *)videoToolBar changeVideoStatus:(BOOL)play {
    
    [self.player play];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"播放按钮"
                                                    message: nil
                                                   delegate: nil
                                          cancelButtonTitle: @"退出"
                                          otherButtonTitles: nil];
    [alert show];
    
}

- (void)videoToolBar:(VideoToolBar *)videoToolBar seekToTime:(CGFloat)skipTime {
    
    //    if (self.state == TBPlayerStateStopped) {
    //        return;
    //    }
    
    //    seconds = MAX(0, seconds);
    //    seconds = MIN(seconds, self.duration);
    
    [self.player pause];
    [self.player seekToTime:CMTimeMakeWithSeconds(skipTime, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        //        self.isPauseByUser = NO;
        [self.player play];
        if (!self.playerItem.isPlaybackLikelyToKeepUp) {
            //            self.state = TBPlayerStateBuffering;
            //            [[XCHudHelper sharedInstance] showHudOnView:_showView caption:nil image:nil acitivity:YES autoHideTime:0];
        }
        
    }];
    
}



/*
 - (void)notificationAction {
 
 [MDHNotificationCenter addObserver: self
 selector: @selector(changeLanguageNotif)
 name: MDHProjectChangeLanguageNotificationName
 object: nil];
 
 }
 
 - (void)changeLanguageNotif {
 
 [_openButton setTitle: _T_(@"test", nil) forState:0];
 
 }
 
 
 
 
 - (void)dataButtonClicked {
 
 WEAKSELF;
 
 NSDictionary *param = @{
 @"param"    : @"1111",
 @"callback" : ^(NSDictionary *dictionary) {
 
 [weakSelf showAlertView: dictionary];
 
 }
 };
 
 MDHBundleURI *uri = [MDHBundleURI bundleWithURI: @"data://com.madaha.MDHDiamond/calculate"
 parameters: param];
 [[MDHBundleAccessor defaultAccessor] resourceWithURI:uri];
 
 }
 
 - (void)showAlertView:(NSDictionary *)dictionary {
 
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"回调"
 message: dictionary.description
 delegate: nil
 cancelButtonTitle: @"ok"
 otherButtonTitles: nil];
 [alert show];
 }
 
 
 - (void)switchCategoryView {
 MDHBundleURI *uri = [MDHBundleURI bundleWithURI:@"ui://com.madaha.MDHDiamond/main" parameters:@{}];
 UIViewController *vc = [[MDHBundleAccessor defaultAccessor] resourceWithURI:uri];
 if (vc && [vc isKindOfClass:[UIViewController class]]) {
 
 [self.navigationController pushViewController:vc animated:YES];
 }
 }
 */


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
